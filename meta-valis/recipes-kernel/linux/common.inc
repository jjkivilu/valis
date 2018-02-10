FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

DEPENDS_append += "lz4-native"

LINUX_VERSION_EXTENSION = "-${DISTRO}"

KERNEL_FEATURES = ""

SRC_URI_append += "file://defconfig"
SRC_URI_append += "file://cmdline.cfg"

SRC_URI_append_dev += "file://ikconfig.cfg"
