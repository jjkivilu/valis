DESCRIPTION = "Initramfs for minimal functional system"
LICENSE = "MIT"

PACKAGE_INSTALL = "${VIRTUAL-RUNTIME_base-utils}"
PACKAGE_INSTALL += "${ROOTFS_BOOTSTRAP_INSTALL}"

export IMAGE_BASENAME = "${DISTRO}-initramfs"
IMAGE_FEATURES = ""
IMAGE_LINGUAS = ""
IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"

BAD_RECOMMENDATIONS += "busybox-syslog"

inherit core-image

