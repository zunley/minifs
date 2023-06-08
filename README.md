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
如果你是第一次运行这个项目，请先执行
```
make init
```
该命令将创建项目所需的基本文件结构并下载相应的软件包

然后进行编译
```
make
```

## CHANGELOG
- 2023.06.05 通过 strip 二进制文件，rootfs 压缩包由 800 M 缩减 150 M
