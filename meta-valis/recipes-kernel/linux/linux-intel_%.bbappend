require common.inc

SRC_URI_append += "file://intel.cfg"

KERNEL_FEATURES_INTEL_COMMON_remove = "cfg/virtio.scc"
