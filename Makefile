DISTRO ?= valis
MACHINE ?= intel-corei7-64
IMAGE ?= core-image-minimal
EXTRA_BBLAYERS ?= ""

ROOT_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
BUILD_DIR ?= $(ROOT_DIR)/build
POKY_DIR ?= $(ROOT_DIR)/poky
DL_DIR ?= $(ROOT_DIR)/downloads

LOCAL_CONF = $(BUILD_DIR)/conf/local.conf
BBLAYERS_CONF = $(BUILD_DIR)/conf/bblayers.conf

define HELP
Usage: $(MAKE) [target] [variables ...]
Targets:
	build-env		Start shell in OE build environment
	bitbake [TASK=...]	Run bitbake with optional arguments specified by TASK
	config			Create project configuration. Force reconfig with "make -B config"
	clean			Remove BUILD_DIR

Variables:
	DISTRO			Distro to build ($(DISTRO))
	MACHINE			Target machine ($(MACHINE))
	IMAGE			Default image to be built by "make image" ($(IMAGE))
endef
export HELP
help:
	@echo "$$HELP"

$(LOCAL_CONF):
	mkdir -p $(dir $@) $(DL_DIR)
	echo 'MACHINE = "$(MACHINE)"' > $@
	echo 'DISTRO = "$(DISTRO)"' >> $@
	echo 'DL_DIR = "$(DL_DIR)"' >> $@

$(BBLAYERS_CONF):
	mkdir -p $(dir $@)
	echo 'POKY_BBLAYERS_CONF_VERSION = "2"' > $@
	echo 'BBPATH = "$${TOPDIR}"' >> $@
	echo 'BBFILES ?= ""' >> $@
	echo 'BBLAYERS += "$(POKY_DIR)/meta"' >> $@
	echo 'BBLAYERS += "$(POKY_DIR)/meta-poky"' >> $@
	echo 'BBLAYERS += "$(POKY_DIR)/meta-yocto-bsp"' >> $@
	echo 'BBLAYERS += "$(ROOT_DIR)/meta-intel"' >> $@
	echo 'BBLAYERS += "$(ROOT_DIR)/meta-valis"' >> $@
	for L in $(EXTRA_BBLAYERS); do test -d "$$L" && echo "BBLAYERS += \"$$L\"" >> $@ || true; done

config: $(LOCAL_CONF) $(BBLAYERS_CONF)

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

image: TASK=$(IMAGE)
image: bitbake

clean:
	rm -rf $(BUILD_DIR)

.PHONY: build-env bitbake image clean
