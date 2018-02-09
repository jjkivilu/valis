FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

KTYPE = "tiny"
KERNEL_FEATURES = ""

SRC_URI_append += "file://cmdline.cfg"
SRC_URI_append += "file://overlay.cfg"
SRC_URI_append += "file://blkio.cfg"
SRC_URI_append += "file://netfilter.cfg"
SRC_URI_append += "file://ipsec.cfg"

SRC_URI_append_dev += "file://ikconfig.cfg"
