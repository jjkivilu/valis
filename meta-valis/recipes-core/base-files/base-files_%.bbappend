FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append += "file://aliases.sh"

do_install_append() {
	install -d ${D}${sysconfdir}/profile.d
	install -m 644 ${WORKDIR}/aliases.sh ${D}${sysconfdir}/profile.d/
}
