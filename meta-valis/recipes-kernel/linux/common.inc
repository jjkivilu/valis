FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

KERNEL_FEATURES_append = " features/net/net.scc" \
                         " features/netfilter/netfilter.scc"

SRC_URI_append += "file://defconfig"

SRC_URI_append += "file://cmdline.cfg"

SRC_URI_append_dev += "file://ikconfig.cfg"
