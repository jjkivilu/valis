FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://50-wired.network"

PACKAGECONFIG = " \
    ${@bb.utils.filter('DISTRO_FEATURES', 'efi ldconfig pam selinux usrmerge', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'rfkill', '', d)} \
    binfmt \
    hostnamed \
    logind \
    machined \
    networkd \
    nss \
    polkit \
    randomseed \
    resolved \
    sysusers \
    timedated \
    timesyncd \
    utmp \
    vconsole \
    xz \
"

do_install_append() {
	install -d ${D}${sysconfdir}/systemd/network
	install -m 644 ${WORKDIR}/*.network ${D}${sysconfdir}/systemd/network
}
