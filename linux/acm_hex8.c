// SPDX-License-Identifier: GPL-2.0-only
#include <linux/fs.h>
#include <linux/bitops.h>
#include <linux/io.h>
#include <linux/miscdevice.h>
#include <linux/module.h>
#include <linux/mutex.h>
#include <linux/of.h>
#include <linux/platform_device.h>
#include <linux/uaccess.h>

#define ACM_HEX8_CONTROL     0x00
#define ACM_HEX8_SCAN_DIV    0x04
#define ACM_HEX8_SERIAL_DIV  0x08
#define ACM_HEX8_BRIGHTNESS  0x0c
#define ACM_HEX8_SEG03       0x10
#define ACM_HEX8_SEG47       0x14

#define ACM_HEX8_CTRL_ENABLE BIT(0)

struct acm_hex8 {
	void __iomem *base;
	struct miscdevice miscdev;
	struct mutex lock;
	char text[9];
};

static u8 acm_hex8_encode(char c)
{
	static const u8 hex[16] = {
		0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07,
		0x7f, 0x6f, 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71,
	};

	if (c >= '0' && c <= '9')
		return hex[c - '0'];
	if (c >= 'a' && c <= 'f')
		return hex[c - 'a' + 10];
	if (c >= 'A' && c <= 'F')
		return hex[c - 'A' + 10];
	if (c == '-')
		return 0x40;
	if (c == '_')
		return 0x08;
	return 0x00;
}

static void acm_hex8_update(struct acm_hex8 *hex8, const char *buf, size_t len)
{
	u8 seg[8] = { 0 };
	size_t i, digit = 0;

	for (i = 0; i < len && digit < 8; i++) {
		if (buf[i] == '.' && digit) {
			seg[digit - 1] |= 0x80;
			continue;
		}
		if (buf[i] == '\n' || buf[i] == '\r')
			continue;
		seg[digit++] = acm_hex8_encode(buf[i]);
	}

	writel((u32)seg[0] | (u32)seg[1] << 8 | (u32)seg[2] << 16 | (u32)seg[3] << 24,
	       hex8->base + ACM_HEX8_SEG03);
	writel((u32)seg[4] | (u32)seg[5] << 8 | (u32)seg[6] << 16 | (u32)seg[7] << 24,
	       hex8->base + ACM_HEX8_SEG47);
}

static ssize_t acm_hex8_write(struct file *file, const char __user *ubuf,
			      size_t len, loff_t *ppos)
{
	struct miscdevice *misc = file->private_data;
	struct acm_hex8 *hex8 = container_of(misc, struct acm_hex8, miscdev);
	char buf[16];
	size_t count = min(len, sizeof(buf));

	if (!count)
		return 0;
	if (copy_from_user(buf, ubuf, count))
		return -EFAULT;

	mutex_lock(&hex8->lock);
	memset(hex8->text, 0, sizeof(hex8->text));
	memcpy(hex8->text, buf, min_t(size_t, count, 8));
	acm_hex8_update(hex8, buf, count);
	mutex_unlock(&hex8->lock);
	return len;
}

static const struct file_operations acm_hex8_fops = {
	.owner = THIS_MODULE,
	.write = acm_hex8_write,
	.llseek = no_llseek,
};

static ssize_t text_show(struct device *dev, struct device_attribute *attr, char *buf)
{
	struct acm_hex8 *hex8 = dev_get_drvdata(dev);
	return sysfs_emit(buf, "%s\n", hex8->text);
}

static ssize_t text_store(struct device *dev, struct device_attribute *attr,
			  const char *buf, size_t count)
{
	struct acm_hex8 *hex8 = dev_get_drvdata(dev);
	mutex_lock(&hex8->lock);
	memset(hex8->text, 0, sizeof(hex8->text));
	memcpy(hex8->text, buf, min_t(size_t, count, 8));
	acm_hex8_update(hex8, buf, count);
	mutex_unlock(&hex8->lock);
	return count;
}
static DEVICE_ATTR_RW(text);

static ssize_t enable_show(struct device *dev, struct device_attribute *attr, char *buf)
{
	struct acm_hex8 *hex8 = dev_get_drvdata(dev);
	return sysfs_emit(buf, "%u\n",
			  !!(readl(hex8->base + ACM_HEX8_CONTROL) &
			     ACM_HEX8_CTRL_ENABLE));
}

static ssize_t enable_store(struct device *dev, struct device_attribute *attr,
			    const char *buf, size_t count)
{
	struct acm_hex8 *hex8 = dev_get_drvdata(dev);
	bool enable;
	u32 control;

	if (kstrtobool(buf, &enable))
		return -EINVAL;
	mutex_lock(&hex8->lock);
	control = readl(hex8->base + ACM_HEX8_CONTROL);
	if (enable)
		control |= ACM_HEX8_CTRL_ENABLE;
	else
		control &= ~ACM_HEX8_CTRL_ENABLE;
	writel(control, hex8->base + ACM_HEX8_CONTROL);
	mutex_unlock(&hex8->lock);
	return count;
}
static DEVICE_ATTR_RW(enable);

static ssize_t brightness_show(struct device *dev,
			       struct device_attribute *attr, char *buf)
{
	struct acm_hex8 *hex8 = dev_get_drvdata(dev);

	return sysfs_emit(buf, "%u\n",
			  readl(hex8->base + ACM_HEX8_BRIGHTNESS) & 0xff);
}

static ssize_t brightness_store(struct device *dev,
				struct device_attribute *attr,
				const char *buf, size_t count)
{
	struct acm_hex8 *hex8 = dev_get_drvdata(dev);
	unsigned int brightness;

	if (kstrtouint(buf, 0, &brightness) || brightness > 255)
		return -EINVAL;
	writel(brightness, hex8->base + ACM_HEX8_BRIGHTNESS);
	return count;
}
static DEVICE_ATTR_RW(brightness);

static struct attribute *acm_hex8_attrs[] = {
	&dev_attr_text.attr,
	&dev_attr_enable.attr,
	&dev_attr_brightness.attr,
	NULL,
};
ATTRIBUTE_GROUPS(acm_hex8);

static int acm_hex8_probe(struct platform_device *pdev)
{
	struct acm_hex8 *hex8;
	u32 value, control = ACM_HEX8_CTRL_ENABLE;
	int ret;

	hex8 = devm_kzalloc(&pdev->dev, sizeof(*hex8), GFP_KERNEL);
	if (!hex8)
		return -ENOMEM;
	hex8->base = devm_platform_ioremap_resource(pdev, 0);
	if (IS_ERR(hex8->base))
		return PTR_ERR(hex8->base);
	mutex_init(&hex8->lock);
	platform_set_drvdata(pdev, hex8);

	if (!of_property_read_u32(pdev->dev.of_node, "scan-divider", &value))
		writel(value, hex8->base + ACM_HEX8_SCAN_DIV);
	if (!of_property_read_u32(pdev->dev.of_node, "serial-divider", &value))
		writel(value, hex8->base + ACM_HEX8_SERIAL_DIV);
	if (of_property_read_u32(pdev->dev.of_node, "default-brightness", &value))
		value = 255;
	if (value > 255)
		return dev_err_probe(&pdev->dev, -EINVAL,
				     "default-brightness must be 0..255\n");
	writel(value, hex8->base + ACM_HEX8_BRIGHTNESS);
	writel(control, hex8->base + ACM_HEX8_CONTROL);

	hex8->miscdev.minor = MISC_DYNAMIC_MINOR;
	hex8->miscdev.name = "acm-hex8";
	hex8->miscdev.fops = &acm_hex8_fops;
	hex8->miscdev.parent = &pdev->dev;
	ret = misc_register(&hex8->miscdev);
	if (ret)
		return ret;

	ret = devm_device_add_groups(&pdev->dev, acm_hex8_groups);
	if (ret) {
		misc_deregister(&hex8->miscdev);
		return ret;
	}
	dev_info(&pdev->dev, "ACM-HEX8 display controller registered\n");
	return 0;
}

static int acm_hex8_remove(struct platform_device *pdev)
{
	struct acm_hex8 *hex8 = platform_get_drvdata(pdev);
	writel(readl(hex8->base + ACM_HEX8_CONTROL) &
	       ~ACM_HEX8_CTRL_ENABLE, hex8->base + ACM_HEX8_CONTROL);
	misc_deregister(&hex8->miscdev);
	return 0;
}

static const struct of_device_id acm_hex8_of_match[] = {
	{ .compatible = "xiaomeige,acm-hex8-1.0" },
	{ }
};
MODULE_DEVICE_TABLE(of, acm_hex8_of_match);

static struct platform_driver acm_hex8_driver = {
	.probe = acm_hex8_probe,
	.remove = acm_hex8_remove,
	.driver = {
		.name = "acm-hex8",
		.of_match_table = acm_hex8_of_match,
	},
};
module_platform_driver(acm_hex8_driver);

MODULE_AUTHOR("ACM-HEX8 AXI contributors");
MODULE_DESCRIPTION("Xiaomeige ACM-HEX8 display controller");
MODULE_LICENSE("GPL");
