PRODUCT ?= evachargese

all: create-dirs keyring multistrap create-devs

create-dirs:
	mkdir -p rootfs
	mkdir -p debcache

keyring:
	mkdir -p rootfs/etc/apt/trusted.gpg.d
	cp /usr/share/keyrings/debian-archive-stretch-automatic.gpg rootfs/etc/apt/trusted.gpg.d

multistrap:
	sudo multistrap -f multistrap-$(PRODUCT).conf

update-cache:
	sudo cp -a rootfs/var/cache/apt/* debcache/

feed-cache:
	sudo mkdir -p rootfs/var/cache/apt
	-sudo cp -a debcache/* rootfs/var/cache/apt/

create-devs:
	sudo /usr/share/multistrap/device-table.pl --no-fakeroot -d rootfs -f device_table.txt

clean:
	sudo rm -rf rootfs
