# 3.8/Makefile

# Inherit variables from parent Makefile
include ../Makefile

# ----------------------------
# Targets
# ----------------------------
prepare-targets: amd64 arm64v8 arm32v7

# ----------------------------
# Rootfs downloads
# ----------------------------
amd64: amd64.rootfs.tar
amd64.rootfs.tar:
	@echo ">> Preparing amd64 rootfs"
	curl -C - -LO http://ftp.spline.inf.fu-berlin.de/pub/crux/crux-3.8/iso/crux-3.8.iso
	$(call iso2tar,crux-3.8.iso)
	mkdir -p .amd64.tmp/iso .amd64.tmp/rootfs
	tar -C .amd64.tmp/iso -xf crux-3.8.tar ./crux ./rootfs.tar.xz
	unxz .amd64.tmp/iso/rootfs.tar.xz
	tar --delete -f .amd64.tmp/iso/rootfs.tar ./lib/firmware ./lib/modules ./dev/console ./usr/lib/dbus/dbus-daemon-launch-helper
	tar -C .amd64.tmp/rootfs -xf .amd64.tmp/iso/rootfs.tar
	mkdir -p .amd64.tmp/rootfs/media
	mv .amd64.tmp/iso/crux .amd64.tmp/rootfs/media/crux
	tar -cf amd64.rootfs.tar -C .amd64.tmp/rootfs .
	rm -rf .amd64.tmp

arm64v8: arm64v8.rootfs.tar
arm64v8.rootfs.tar:
	@echo ">> Preparing arm64v8 rootfs"
	curl -C - -LO https://git.crux.nu/system/crux-rootfs/releases/download/3.8/crux-3.8-arm64.rootfs.tar.xz
	mkdir -p .arm64v8.tmp/rootfs
	unxz -k -c crux-3.8-arm64.rootfs.tar.xz > .arm64v8.tmp/rootfs/crux-3.8-arm64.rootfs.tar
	tar --delete -f .arm64v8.tmp/rootfs/crux-3.8-arm64.rootfs.tar dev/console boot/ lib/firmware/ lib/modules/
	mv .arm64v8.tmp/rootfs/crux-3.8-arm64.rootfs.tar arm64v8.rootfs.tar
	rm -rf .arm64v8.tmp

arm32v7: arm32v7.rootfs.tar
arm32v7.rootfs.tar:
	@echo ">> Preparing arm32v7 rootfs"
	curl -C - -LO https://git.crux.nu/system/crux-rootfs/releases/download/3.8/crux-3.8-armhf.rootfs.tar.xz
	mkdir -p .arm32v7.tmp/rootfs
	unxz -k -c crux-3.8-armhf.rootfs.tar.xz > .arm32v7.tmp/rootfs/crux-3.8-armhf.rootfs.tar
	tar --delete -f .arm32v7.tmp/rootfs/crux-3.8-armhf.rootfs.tar dev/console boot/ lib/firmware/ lib/modules/
	mv .arm32v7.tmp/rootfs/crux-3.8-armhf.rootfs.tar arm32v7.rootfs.tar
	rm -rf .arm32v7.tmp