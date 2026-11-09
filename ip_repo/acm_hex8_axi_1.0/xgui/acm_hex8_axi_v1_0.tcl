proc acm_hex8_zh {escaped} {
  return [subst $escaped]
}

proc init_gui {IPINST} {
  ipgui::add_param $IPINST -name Component_Name
  set page [ipgui::add_page $IPINST -name {ACM-HEX8 Configuration}]

  set mode [ipgui::add_param $IPINST -name OUTPUT_MODE -parent $page -widget comboBox]
  set_property display_name {Output Mode} $mode
  set_property tooltip [acm_hex8_zh {Parallel \u4e3a 11 \u4f4d\u5e76\u884c\u63a5\u53e3\uff1bSerial \u4e3a 3 \u4f4d 74HC595 \u4e32\u884c\u63a5\u53e3\u3002\u9700\u4e0e\u6a21\u5757\u62e8\u52a8\u5f00\u5173\u4e00\u81f4\u3002}] $mode

  set scan [ipgui::add_param $IPINST -name DEFAULT_SCAN_DIV -parent $page]
  set_property display_name {Power-on Digit Step Divider (50 MHz / N)} $scan
  set_property tooltip [acm_hex8_zh {6250 \u5bf9\u5e94 8 kHz \u4f4d\u5207\u6362\u9891\u7387\u548c 1 kHz \u516b\u4f4d\u5b8c\u6574\u5237\u65b0\u7387\uff1b\u8f6f\u4ef6\u53ef\u901a\u8fc7\u5bc4\u5b58\u5668 0x04 \u4fee\u6539\u3002}] $scan
  set serial [ipgui::add_param $IPINST -name DEFAULT_SERIAL_DIV -parent $page]
  set_property display_name {Power-on 74HC595 Clock Divider (50 MHz / 2N)} $serial
  set_property tooltip [acm_hex8_zh {25 \u5bf9\u5e94 1 MHz \u4e32\u884c\u79fb\u4f4d\u65f6\u949f\uff1b\u4ec5\u4e32\u884c\u6a21\u5f0f\u4f7f\u7528\uff0c\u8f6f\u4ef6\u53ef\u901a\u8fc7\u5bc4\u5b58\u5668 0x08 \u4fee\u6539\u3002}] $serial

  set brightness [ipgui::add_param $IPINST -name DEFAULT_BRIGHTNESS -parent $page]
  set_property display_name {Power-on Global Brightness (0-255)} $brightness
  set_property tooltip [acm_hex8_zh {0 \u8868\u793a\u5168\u706d\uff0c255 \u8868\u793a\u6700\u5927\u4eae\u5ea6\uff1b\u8f6f\u4ef6\u53ef\u901a\u8fc7\u5bc4\u5b58\u5668 0x0C \u4fee\u6539\u3002}] $brightness

}

foreach parameter {
  OUTPUT_MODE DEFAULT_SCAN_DIV
  C_S_AXI_DATA_WIDTH C_S_AXI_ADDR_WIDTH USE_BOARD_FLOW GPIO_BOARD_INTERFACE
} {
  proc update_PARAM_VALUE.$parameter [list PARAM_VALUE.$parameter] {}
  proc validate_PARAM_VALUE.$parameter [list PARAM_VALUE.$parameter] {return true}
  proc update_MODELPARAM_VALUE.$parameter \
    [list MODELPARAM_VALUE.$parameter PARAM_VALUE.$parameter] \
    [format {set_property value [get_property value ${PARAM_VALUE.%s}] ${MODELPARAM_VALUE.%s}} \
      $parameter $parameter]
}

proc update_PARAM_VALUE.DEFAULT_BRIGHTNESS {PARAM_VALUE.DEFAULT_BRIGHTNESS} {}
proc validate_PARAM_VALUE.DEFAULT_BRIGHTNESS {PARAM_VALUE.DEFAULT_BRIGHTNESS} {return true}
proc update_MODELPARAM_VALUE.DEFAULT_BRIGHTNESS {
  MODELPARAM_VALUE.DEFAULT_BRIGHTNESS PARAM_VALUE.DEFAULT_BRIGHTNESS
} {
  set_property value [get_property value ${PARAM_VALUE.DEFAULT_BRIGHTNESS}] \
    ${MODELPARAM_VALUE.DEFAULT_BRIGHTNESS}
}

proc update_PARAM_VALUE.DEFAULT_SERIAL_DIV {
  PARAM_VALUE.DEFAULT_SERIAL_DIV PARAM_VALUE.OUTPUT_MODE
} {
  set mode [get_property value ${PARAM_VALUE.OUTPUT_MODE}]
  set_property enabled [expr {$mode eq "Serial"}] ${PARAM_VALUE.DEFAULT_SERIAL_DIV}
}
proc validate_PARAM_VALUE.DEFAULT_SERIAL_DIV {PARAM_VALUE.DEFAULT_SERIAL_DIV} {return true}
proc update_MODELPARAM_VALUE.DEFAULT_SERIAL_DIV {
  MODELPARAM_VALUE.DEFAULT_SERIAL_DIV PARAM_VALUE.DEFAULT_SERIAL_DIV
} {
  set_property value [get_property value ${PARAM_VALUE.DEFAULT_SERIAL_DIV}] \
    ${MODELPARAM_VALUE.DEFAULT_SERIAL_DIV}
}
