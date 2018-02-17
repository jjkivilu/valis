DESCRIPTION = "Initramfs for minimal functional system"
LICENSE = "MIT"

INITRAMFS_MAXSIZE = "300000"

IMAGE_INSTALL = "${VIRTUAL-RUNTIME_base-utils}"
IMAGE_INSTALL += "${ROOTFS_BOOTSTRAP_INSTALL}"
IMAGE_INSTALL += "systemd"
IMAGE_INSTALL += "dropbear"
IMAGE_INSTALL += "docker"

IMAGE_INSTALL_append_dev += "less"

export IMAGE_BASENAME = "${DISTRO}-initramfs"
IMAGE_FEATURES = ""
IMAGE_LINGUAS = ""
IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"
IMAGE_FEATURES_append_dev += "debug-tweaks package-management"

BAD_RECOMMENDATIONS += "busybox-syslog"

inherit core-image

fix_dev_console() {
	if [ ! -c ${IMAGE_ROOTFS}/dev/console ]; then
		install -d ${IMAGE_ROOTFS}/dev
		mknod -m 622 ${IMAGE_ROOTFS}/dev/console c 5 1
	fi
}

IMAGE_PREPROCESS_COMMAND += "fix_dev_console;"
