do_compile_append() {
	# Enable running from ramdisk, disables pivot_root usage
	sed -i '/\[Service\]/a Environment=DOCKER_RAMDISK=1' \
		${S}/src/import/contrib/init/systemd/docker.service
}
