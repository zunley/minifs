SHELL=/usr/bin/bash

PROJECT:=/mnt/lfs
WORKSPACE:=${PROJECT}/workspace
LFS:=${PROJECT}/rootfs
STRIP:=workspace/tools/bin/loongarch64-lfs-linux-gnu-strip

default: rootfs

.PHONY: rootfs
rootfs:
	docker run --rm \
		-v $(shell pwd):${PROJECT} \
		-e LFS=${LFS} \
		-e PROJECT=${PROJECT} \
		-e WORKSPACE=${WORKSPACE} \
		minifs-build /bin/bash -c "${WORKSPACE}/scripts/compile.sh"

.PHONY: tarball
tarball:
	tar -zcvf images/rootfs.tar.gz -C rootfs .

.PHONY: image
image:
	docker build -f images/Dockerfile -t minifs images

.PHONY: strip
strip:
	find rootfs/usr/{bin,lib,libexec} -type f -exec file {} \; | grep "\<ELF\>" | awk -F ':' '{print $$1}' | \
		xargs ${STRIP} --strip-unneeded

.PHONY: update-ca
update-ca:
	cp $$(which qemu-loongarch64) rootfs/usr/local/bin/
	cp workspace/scripts/update-ca.sh rootfs/usr/bin/
	chroot rootfs /usr/bin/env -i \
		PATH=/usr/bin:/usr/sbin \
		/usr/bin/update-ca.sh
	rm rootfs/usr/local/bin/qemu-loongarch64
	rm rootfs/usr/bin/update-ca.sh

clean: clean-rootfs 
clean-rootfs:
	# delete rootfs and stage file for rebuild
	rm -rf rootfs/*
	find workspace/stages -name cross_compile\* -delete
	rm -f workspace/stages/compile_linux_header
clean-workspace:
	rm -rf workspace/{tools,build,stage}/* 
	find workspace/stages -name compile_tools\* -delete
image-build:
	docker build \
		--build-arg https_proxy=${https_proxy} \
		--build-arg http_proxy=${http_proxy} \
		-f images/Dockerfile.build \
		-t minifs-build \
		images
