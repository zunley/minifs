# Minifs

minifs(mini root file system) 是一个极简的 loongarch64 根文件系统。


## 预装
- [x] bash
- [x] binutils
- [x] gcc g++
- [x] coreutils
- [x] make
- [x] vim
- [x] curl

## 项目结构
```
Project Layout
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
- `rootfs` 最终生成的根文件系统
- `workspace` 总工作区
    - `sources` 软件源码
    - `build` 编译
    - `tools` 零时编译的工具
    - `scripts` 构建脚本
    - `stages` 步骤记录

## 编译
```
make
```

## 一般编译步骤
1. `make rootfs` 编译 rootfs 系统
2. `make strip` 精简系统
3. `make update-ca` 更新系统中的 ca 证书文件
4. `make raball` 将 rootfs 打包成 tar 文件
5. `make image` 将 tar 包制作成镜像

## 注意
- 整套流程在 x86 docker 上编译，不需要宿主机配置开发环境
- 编译 rootfs 需要一个基础镜像 minifs-build，可以通过 `make image-build` 生成

## CHANGELOG
- 2023.06.05 通过 strip 二进制文件，ROOTFS 压缩包由 800 M 缩减 150 M
