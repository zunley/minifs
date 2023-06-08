SHELL=/usr/bin/bash

PROJECT:=/mnt/lfs
WORKSPACE:=${PROJECT}/workspace
LFS:=${PROJECT}/rootfs
STRIP:=workspace/tools/bin/loongarch64-lfs-linux-gnu-strip

default: check-user tools rootfs strip update-ca tarball image

tools:
	docker run --rm \
		-v $(shell pwd):${PROJECT} \
		-e LFS=${LFS} \
		-e PROJECT=${PROJECT} \
		-e WORKSPACE=${WORKSPACE} \
		minifs-builder /bin/bash -c "${WORKSPACE}/scripts/compile-tools.sh"

.PHONY: rootfs
rootfs:
	docker run --rm \
		-v $(shell pwd):${PROJECT} \
		-e LFS=${LFS} \
		-e PROJECT=${PROJECT} \
		-e WORKSPACE=${WORKSPACE} \
		minifs-builder /bin/bash -c "${WORKSPACE}/scripts/compile-rootfs.sh"

.PHONY: tarball
tarball:
	tar -zcvf archives/rootfs.tar.gz -C rootfs .

.PHONY: image
image:
	cp -f workspace/tools/bin/qemu-loongarch64 archives/
	docker build --no-cache -f images/Dockerfile -t minifs .

.PHONY: init
init: check-user clean-all sources

.PHONY: check-user
check-user:
	@if [ $$UID -ne 0 ]; then \
		echo "Please run with root."; \
		exit 1; \
	fi

.PHONY: strip
strip:
	find rootfs/usr/{bin,lib,libexec} -type f -exec file {} \; | grep "\<ELF\>" | awk -F ':' '{print $$1}' | \
		xargs ${STRIP} --strip-unneeded

.PHONY: sources
sources: 
	wget -c -nc -P workspace/sources/archives -i workspace/sources/wget-list

.PHONY: update-ca
update-ca:
	mkdir -pv rootfs/usr/local/bin
	cp $$(which qemu-loongarch64) rootfs/usr/local/bin/
	cp workspace/scripts/update-ca.sh rootfs/usr/bin/
	chroot rootfs /usr/bin/env -i \
		PATH=/usr/bin:/usr/sbin \
		/usr/bin/update-ca.sh
	rm rootfs/usr/local/bin/qemu-loongarch64
	rm rootfs/usr/bin/update-ca.sh

clean: check-user clean-rootfs layout
clean-all: check-user clean-rootfs clean-tools layout
clean-rootfs:
	rm -rf rootfs/*
	rm -rf workspace/stages/rootfs/*
clean-tools:
	rm -rf workspace/{tools,build,stage,sources/archives}/* 
	rm -rf workspace/stages/tools/*
layout:
	mkdir -pv rootfs/{etc,var,run} rootfs/usr/{bin,lib,sbin} rootfs/{dev,proc,sys}
	for i in bin lib sbin; do \
		ln -sv usr/$$i rootfs/$$i; \
	done;
	ln -sv usr/lib rootfs/lib64
	mkdir -pv workspace/{sources/archives,build,tools,stages/{rootfs,tools}}
	mkdir -pv archives

builder:
	docker build \
		--build-arg https_proxy=${https_proxy} \
		--build-arg http_proxy=${http_proxy} \
		-f images/Dockerfile.builder \
		-t minifs-builder \
		images
