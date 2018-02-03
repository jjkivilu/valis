DISTRO ?= valis
MACHINE ?= intel-corei7-64
IMAGE ?= $(DISTRO)-image

ROOT_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
BUILD_DIR ?= $(ROOT_DIR)/build
POKY_DIR ?= $(ROOT_DIR)/poky
DL_DIR ?= $(ROOT_DIR)/downloads
DEPLOY_DIR ?= $(BUILD_DIR)/tmp/deploy/images/$(MACHINE)

IMAGE_FILE ?= $(DEPLOY_DIR)/bzImage-initramfs-$(MACHINE).bin

LOCAL_CONF = $(BUILD_DIR)/conf/local.conf
BBLAYERS_CONF = $(BUILD_DIR)/conf/bblayers.conf
ALL_CONF_FILES = $(LOCAL_CONF) $(BBLAYERS_CONF)

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
endef
export HELP
help:
	@echo "$$HELP"

$(LOCAL_CONF):
	mkdir -p $(dir $@) $(DL_DIR)
	echo 'MACHINE = "$(MACHINE)"' > $@
	echo 'DISTRO = "$(DISTRO)"' >> $@
	echo 'DL_DIR = "$(DL_DIR)"' >> $@
	echo 'PARALLEL_MAKE = "-j10"' >> $@
	echo 'BB_NUMBER_THREADS = "4"' >> $@


$(BBLAYERS_CONF):
	mkdir -p $(dir $@)
	echo 'POKY_BBLAYERS_CONF_VERSION = "2"' > $@
	echo 'BBPATH = "$${TOPDIR}"' >> $@
	echo 'BBFILES ?= ""' >> $@
	for L in $(BBLAYERS); do if [ -d "$$L" ]; then echo "BBLAYERS += \"$$L\"" >> $@; fi; done

config: $(ALL_CONF_FILES)

define oe-init-build-env
OEROOT=$(POKY_DIR) . $(POKY_DIR)/oe-init-build-env $(BUILD_DIR)
endef

build-env: SHELL = /bin/bash
build-env: config
	($(call oe-init-build-env); \
	 export PROMPT_COMMAND='printf "\033[1;33m[BB]\033[0m "'; \
	 exec $(SHELL) -i) || true

bitbake: config
	$(call oe-init-build-env); bitbake $(TASK)

image: $(IMAGE_FILE)
$(IMAGE_FILE): TASK = $(IMAGE)
$(IMAGE_FILE): $(ALL_CONF_FILES) bitbake

runqemu: MACHINE = qemux86-64
runqemu: $(IMAGE_FILE)
	$(call oe-init-build-env); \
	runqemu kvm nographic \
		$(DEPLOY_DIR)/bzImage-initramfs-$(MACHINE).bin

clean:
	rm -rf $(BUILD_DIR)

.PHONY: build-env bitbake image clean
