# Minifs

minifs(mini root file system) 是一个极简的 loongarch64 根文件系统。


## 预装
- [x] bash
- [x] binutils
- [x] gcc g++
- [x] coreutils
- [x] make
- [ ] vim
- [ ] curl

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

## 编译 rootfs
```
make roorfs 
```
### 打包 rootfs
```
make tarball
```
### 制作 minifs 镜像
```
make image
```

## 注意
- 整套流程在 x86 docker 上编译，不需要宿主机配置开发环境
- 编译 rootfs 需要一个基础镜像 minifs-build，可以通过 `make image-build` 生成

## TODO
- [ ] 自动删除无用的 la 文件
- [ ] 预装 wget，curl 测试网络功能
- [ ] 预装 vim 测试编译功能
- [ ] 文件系统精简，缩减体积
