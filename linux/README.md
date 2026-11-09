# ACM-HEX8 Linux 驱动

该驱动匹配 `xiaomeige,acm-hex8-1.0`，控制 ACM-HEX8 AXI4-Lite Catalog IP。

## 构建

```sh
make -C /path/to/linux M=$PWD modules
```

把 `acm-hex8.dtsi` 的基地址改为 Vivado Address Editor 实际分配的地址，再合入设备树。加载驱动后可使用：

```sh
echo 1234AbCd > /dev/acm-hex8
echo 12.34 > /sys/bus/platform/devices/43c00000.display/text
echo 12.345678 > /dev/acm-hex8
echo 0 > /sys/bus/platform/devices/43c00000.display/enable
echo 128 > /sys/bus/platform/devices/43c00000.display/brightness
```

支持字符为 `0-9`、`A-F`、`a-f`、`-`、`_` 和空格；小数点会附着在前一个字符上。
`brightness` 的范围是 `0..255`。设备树属性 `default-brightness` 用于设置驱动
加载时的默认亮度。
