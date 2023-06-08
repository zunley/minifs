# Minifs

minifs(mini root file system) is a rootfs for loongarch64.

## packages
- [x] bash
- [x] binutils
- [x] gcc g++
- [x] coreutils
- [x] make
- [x] vim
- [x] curl

## Project Layout
```
├── rootfs
│   ├── bin -> usr/bin
│   ├── dev
│   ├── etc
│   ├── lib -> usr/lib
│   ├── lib64 -> usr/lib
│   ├── proc
│   ├── run
│   ├── sbin -> usr/sbin
│   ├── sys
│   ├── usr
│   └── var
└── workspace
    ├── build
    ├── scripts
    ├── sources
    ├── stages
    └── tools
```

## build
If you are building from sources for the first time, run
```
make init
```
to create project layout and download the required packages. Then
```
make
```

## run
```
curl -L https://raw.githubusercontent.com/qemu/qemu/master/scripts/qemu-binfmt-conf.sh | bash -
docker run -it --rm merore/minifs
```
