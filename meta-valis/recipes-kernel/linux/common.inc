FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

DEPENDS_append += "lz4-native"

LINUX_KERNEL_TYPE = "tiny"
LINUX_VERSION_EXTENSION = "-${DISTRO}"

KERNEL_FEATURES = ""
KERNEL_EXTRA_FEATURES = ""

SRC_URI_append += "file://defconfig"
SRC_URI_append += "file://cmdline.cfg"
SRC_URI_append += "file://net.cfg"
SRC_URI_append += "file://netfilter.cfg"
SRC_URI_append += "file://wlan.cfg"
SRC_URI_append += "file://hid.cfg"
SRC_URI_append += "file://usb.cfg"
SRC_URI_append += "file://storage.cfg"

SRC_URI_append_dev += "file://dev.cfg"
