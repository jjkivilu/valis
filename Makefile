-include site.conf
$(foreach v,$(.VARIABLES),$(eval $(v) := $$(patsubst "%",%,$$($(v)))))

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
	   $(ROOT_DIR)/meta-openembedded/meta-oe \
	   $(ROOT_DIR)/meta-openembedded/meta-python \
	   $(ROOT_DIR)/meta-openembedded/meta-networking \
	   $(ROOT_DIR)/meta-openembedded/meta-filesystems \
	   $(ROOT_DIR)/meta-virtualization \
	   $(ROOT_DIR)/meta-measured \
	   $(ROOT_DIR)/meta-valis \
	   $(EXTRA_BBLAYERS)

define HELP
Usage: $(MAKE) [target] [variables ...]
Targets:
	build-env		Start shell in OE build environment
	bitbake [TASK=...]	Run bitbake with optional arguments specified by TASK
	config			Create project configuration. Force reconfig with "make -B config"
	runqemu			Run image under QEMU. Hit Ctrl-A X to exit
	deploy DIR=...		Deploy image to correct directory under specified DIR
	pxeboot IF=...		Run DHCP and TFTP servers on interface IF for PXE network boot
	browse			Browse initramfs contents with Midnight Commander
	deps			Generate task and recipe dependency graphics under BUILD_DIR
	clean			Remove BUILD_DIR

Variables:
	DISTRO			Distro to build ($(DISTRO))
	MACHINE			Target machine ($(MACHINE))
	IMAGE			Default image to be built by "make image" ($(IMAGE))
	EXTRA_BBLAYERS		List of additional layer directories to be included in build
	DL_DIR			Alternative location for upstream downloads ($(DL_DIR))

	You can provide these as arguments to "make" or in a file "site.conf", for example:
	  DL_DIR = "/mnt/data/downloads"
	  DISTROOVERRIDES_append = ":dev"	# to enable development image
endef
export HELP
help:
	@echo "$$HELP"

$(LOCAL_CONF):
	mkdir -p $(dir $@) $(DL_DIR)
	echo 'MACHINE ?= "$(MACHINE)"' > $@
	echo 'DISTRO ?= "$(DISTRO)"' >> $@
	echo 'DL_DIR ?= "$(DL_DIR)"' >> $@
	echo 'RM_OLD_IMAGE = "1"' >> $@
	echo 'VALIS_LICENSE = "${ROOT_DIR}/LICENSE"' >> $@

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
	-$(call oe-init-build-env); exec $(SHELL) -i

bitbake: $(CONF_FILES)
	$(call oe-init-build-env); bitbake $(TASK)

image: $(IMAGE_FILE)
$(IMAGE_FILE): $(CONF_FILES)
$(IMAGE_FILE): TASK = $(IMAGE)
$(IMAGE_FILE): bitbake
	@du -shD $(wildcard \
		$(DEPLOY_DIR)/bzImage-$(MACHINE).bin \
		$(DEPLOY_DIR)/$(DISTRO)-initramfs-$(MACHINE).cpio* \
		$(IMAGE_FILE) \
	) | sed -e 's,$(DEPLOY_DIR)/,,'

runqemu: MACHINE = qemux86-64
runqemu: $(IMAGE_FILE)
	$(call oe-init-build-env); runqemu kvm nographic qemuparams="-m 1024" $<

deploy: $(IMAGE_FILE)
	@if [ ! -d '$(DIR)' ]; then echo "ERROR: Please specify DIR=..."; exit 1; fi
	mkdir -p $(DIR)/EFI/boot
	cp $(IMAGE_FILE) $(DIR)/EFI/boot/bootx64.efi

pxeboot: WAN = $(shell route | awk '/^default/ { print $$8 }')
pxeboot: $(IMAGE_FILE)
	@if [ -z '$(IF)' ]; then echo "ERROR: Please specify network interface IF=..."; exit 1; fi
	sudo ifconfig $(IF) 192.168.2.1 netmask 255.255.255.0
	sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
	sudo iptables -t nat -A POSTROUTING -o $(WAN) -j MASQUERADE
	sudo iptables -A FORWARD -i $(WAN) -o $(IF) -m state --state RELATED,ESTABLISHED -j ACCEPT
	sudo iptables -A FORWARD -i $(IF) -o $(WAN) -j ACCEPT
	sudo dnsmasq -d -i $(IF) -p 0 \
		--dhcp-range=192.168.2.2,192.168.2.200,72h \
		--dhcp-boot=$(notdir $(IMAGE_FILE)) \
		--enable-tftp --tftp-root=$(dir $(IMAGE_FILE))

browse: $(IMAGE_FILE)
	mc $(BUILD_DIR)/tmp/work/$(subst -,_,$(MACHINE))-poky-linux/$(DISTRO)-initramfs/*/rootfs

deps: TASK = -g $(IMAGE)
deps: bitbake

clean:
	-rm -rf $(BUILD_DIR)

.PHONY: config build-env bitbake image runqemu clean $(CONF_FILES)
