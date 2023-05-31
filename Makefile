PROJECT:=/mnt/lfs
WORKSPACE:=${PROJECT}/workspace
LFS:=${PROJECT}/rootfs

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

clean: clean-rootfs clean-workspace
clean-rootfs:
	rm -rf rootfs/*
clean-workspace:
	rm -rf workspace/tools/* workspace/build/* workspace/stages/*
image-build:
	docker build \
		--build-arg https_proxy=${https_proxy} \
		--build-arg http_proxy=${http_proxy} \
		-f images/Dockerfile.build \
		-t minifs-build \
		images

