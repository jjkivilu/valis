DESCRIPTION = "Initramfs for minimal functional system"
LICENSE = "MIT"

INITRAMFS_MAXSIZE = "300000"

PACKAGE_INSTALL = "${VIRTUAL-RUNTIME_base-utils}"
PACKAGE_INSTALL += "${ROOTFS_BOOTSTRAP_INSTALL}"
PACKAGE_INSTALL += "systemd"
PACKAGE_INSTALL += "docker"

PACKAGE_INSTALL_dev += "less"

export IMAGE_BASENAME = "${DISTRO}-initramfs"
IMAGE_FEATURES = ""
IMAGE_LINGUAS = ""
IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"

BAD_RECOMMENDATIONS += "busybox-syslog"

inherit core-image

fix_dev_console() {
	if [ ! -c ${IMAGE_ROOTFS}/dev/console ]; then
		install -d ${IMAGE_ROOTFS}/dev
		mknod -m 622 ${IMAGE_ROOTFS}/dev/console c 5 1
	fi
}

IMAGE_PREPROCESS_COMMAND += "fix_dev_console;"

inherit extrausers
EXTRA_USERS_PARAMS_dev = " \
	usermod -P '' root; \
"

