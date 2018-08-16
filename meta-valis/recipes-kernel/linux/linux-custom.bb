# You can enable building this example of custom kernel by adding to site.conf:
# PREFERRED_PROVIDER_virtual/kernel = "linux-custom"

# Then fill in the below variables:
LINUX_SRC_URI = "git://git.infradead.org/users/jjs/linux-tpmdd.git"
LINUX_VERSION = "4.18"
PV = "${LINUX_VERSION}-rc2"

# You may also need to change these:
SRCREV_linux = "ec403d8ed08c8272cfeeeea154fdebcd289988c8"
SRCREV_meta = "79c6259d1eadbb81b3db57104dcb5a9d6dee166f"
LIC_FILES_CHKSUM_linux = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

inherit kernel
require recipes-kernel/linux/linux-yocto.inc
require common.inc

SRC_URI = "${LINUX_SRC_URI};name=linux \
	   git://git.yoctoproject.org/yocto-kernel-cache;type=kmeta;name=meta;branch=${KMETA_BRANCH};destsuffix=${KMETA}"

KMETA = "kernel-meta"
KMETA_BRANCH = "yocto-${LINUX_VERSION}"
COMPATIBLE_MACHINE = "qemux86.*|genericx86.*|intel-corei7.*"
