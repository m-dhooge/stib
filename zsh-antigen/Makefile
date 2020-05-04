CROSS_COMPILE ?= arm-linux-gnueabi-
ROOTFS ?= ../rootfs

TARGET_USER ?= root

BUILD_DIR ?= tmp

ifeq ($(TARGET_USER),root)
USER_DIR ?= $(BUILD_DIR)/root
else
USER_DIR ?= $(BUILD_DIR)/home/$(TARGET_USER)
endif


###
### Default rule
###

.PHONY: all
all: antigen fzy termsize


###
### Antigen
###

.PHONY: antigen antigen-cfg antigen-run

antigen: home-dir antigen-cfg antigen-run

antigen-cfg:
ifeq ($(realpath $(USER_DIR)/antigen.zsh),)
	curl -L git.io/antigen > $(USER_DIR)/antigen.zsh
# Appeler antigen cache-gen
endif
	cp zshrc     $(USER_DIR)/.zshrc
	cp antigenrc $(USER_DIR)/.antigenrc

antigen-run:
ifeq ($(realpath $(USER_DIR)/.antigen),)
	cd $(USER_DIR) && HOME=. zsh .zshrc
endif
	rm -f $(USER_DIR)/.zshrc.grc


###
### Fuzzy
###

.PHONY: fzy fzy-bin fzy-git

fzy: fzy-bin
	DESTDIR=$(abspath $(BUILD_DIR)) \
	$(MAKE) -C fzy install

fzy-bin: fzy-git
	CFLAGS="--sysroot $(abspath $(ROOTFS))" \
	CC=$(CROSS_COMPILE)gcc \
	$(MAKE) -C fzy

fzy-git:
ifeq ($(realpath fzy),)
	git clone https://github.com/jhawthorn/fzy.git
endif


###
### Terminal Size
###

.PHONY: termsize

termsize:
ifeq ($(realpath $(USER_DIR)/termsize),)
	curl -L https://raw.githubusercontent.com/akkana/scripts/master/termsize > $(USER_DIR)/termsize
	chmod +x $(USER_DIR)/termsize
endif


###
### Miscellaneous
###

.PHONY: clean home-dir install

home-dir:
	mkdir -p $(USER_DIR)

clean:
	rm -rf $(BUILD_DIR) fzy

install:
	cp --verbose --recursive $(BUILD_DIR)/* $(ROOTFS) > install.log
	perl -pi.orig -e 's/^($(TARGET_USER).*)bash/\1zsh/' $(ROOTFS)/etc/passwd
	perl -pi.orig -e 's/^.* ->/rm/' install.log
	mv install.log uninstall.sh

