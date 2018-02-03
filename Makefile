DISTRO ?= valis
MACHINE ?= intel-corei7-64

ROOT_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
BUILD_DIR ?= $(ROOT_DIR)/build
POKY_DIR ?= $(ROOT_DIR)/poky
DL_DIR ?= $(ROOT_DIR)/downloads
DEPLOY_DIR ?= $(BUILD_DIR)/tmp/deploy/images/$(MACHINE)

IMAGE ?= $(DISTRO)-image
IMAGE_FILE ?= $(DEPLOY_DIR)/bzImage-initramfs-$(MACHINE).bin

LOCAL_CONF = $(BUILD_DIR)/conf/local.conf
SITE_CONF = $(BUILD_DIR)/conf/site.conf
BBLAYERS_CONF = $(BUILD_DIR)/conf/bblayers.conf
CONF_FILES = $(LOCAL_CONF) $(SITE_CONF) $(BBLAYERS_CONF)

BBLAYERS = $(POKY_DIR)/meta \
	   $(POKY_DIR)/meta-poky \
	   $(POKY_DIR)/meta-yocto-bsp \
	   $(ROOT_DIR)/meta-intel \
	   $(ROOT_DIR)/meta-valis \
	   $(EXTRA_BBLAYERS)

define HELP
Usage: $(MAKE) [target] [variables ...]
Targets:
	build-env		Start shell in OE build environment
	bitbake [TASK=...]	Run bitbake with optional arguments specified by TASK
	config			Create project configuration. Force reconfig with "make -B config"
	runqemu			Run image under QEMU. Hit Ctrl-A X to exit
	clean			Remove BUILD_DIR

Variables:
	DISTRO			Distro to build ($(DISTRO))
	MACHINE			Target machine ($(MACHINE))
	IMAGE			Default image to be built by "make image" ($(IMAGE))
	EXTRA_BBLAYERS		List of additional layer directories to be included in build
	DL_DIR			Alternative location for upstream downloads ($(DL_DIR))

	You can provide these in a file "site.conf" or as arguments to "make"
endef
export HELP
help:
	@echo "$$HELP"

$(LOCAL_CONF):
	mkdir -p $(dir $@) $(DL_DIR)
	echo 'MACHINE ?= "$(MACHINE)"' > $@
	echo 'DISTRO ?= "$(DISTRO)"' >> $@
	echo 'DL_DIR ?= "$(DL_DIR)"' >> $@

$(SITE_CONF): $(wildcard $(ROOT_DIR)/site.conf)
	for f in $^; do cp $$f $@; done

$(BBLAYERS_CONF):
	mkdir -p $(dir $@)
	echo 'POKY_BBLAYERS_CONF_VERSION = "2"' > $@
	echo 'BBPATH = "$${TOPDIR}"' >> $@
	echo 'BBFILES ?= ""' >> $@
	for L in $(BBLAYERS); do if [ -d "$$L" ]; then echo "BBLAYERS += \"$$L\"" >> $@; fi; done

config: $(CONF_FILES)

define oe-init-build-env
OEROOT=$(POKY_DIR) . $(POKY_DIR)/oe-init-build-env $(BUILD_DIR)
endef

build-env: SHELL = /bin/bash
build-env: $(CONF_FILES)
	($(call oe-init-build-env); \
	 export PROMPT_COMMAND='printf "\033[1;33m[BB]\033[0m "'; \
	 exec $(SHELL) -i) || true

bitbake: $(CONF_FILES)
	$(call oe-init-build-env); bitbake $(TASK)

$(IMAGE_FILE): TASK = $(IMAGE)
$(IMAGE_FILE): bitbake
image: $(IMAGE_FILE)
	@du -shD \
		$(DEPLOY_DIR)/bzImage-$(MACHINE).bin \
		$(DEPLOY_DIR)/$(DISTRO)-initramfs-$(MACHINE).cpio* \
		$(IMAGE_FILE) \
	| sed -e 's,$(DEPLOY_DIR)/,,'

runqemu: MACHINE = qemux86-64
runqemu: $(IMAGE_FILE)
	$(call oe-init-build-env); \
	runqemu kvm nographic \
		$(DEPLOY_DIR)/bzImage-$(MACHINE).initramfs-$(MACHINE).bin

clean:
	rm -rf $(BUILD_DIR)

.PHONY: build-env bitbake image clean
