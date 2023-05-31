#!/bin/bash
set +h
umask 022

BINUTILS_VERSION=2.40
GCC_VERSION=13.1.0
LINUX_VERSION=6.3.3
GLIBC_VERSION=2.37
MPFR_VERSION=4.2.0
GMP_VERSION=6.2.1
MPC_VERSION=1.3.1
AUTOCONF_VERSION=2.71
AUTOMAKE_VERSION=1.16.5
M4_VERSION=1.4.19      
NCURSES_VERSION=6.4
BASH_VERSION=5.2.15
COREUTILS_VERSION=9.1
DIFFUTILS_VERSION=3.9
FILE_VERSION=5.44
FINDUTILS_VERSION=4.9.0
GAWK_VERSION=5.2.1
GREP_VERSION=3.8
GZIP_VERSION=1.12
MAKE_VERSION=4.4
PATCH_VERSION=2.7.6
SED_VERSION=4.9
TAR_VERSION=1.34
XZ_VERSION=5.4.1
ZLIB_VERSION=1.2.13

: ${LFS?} ${WORKSPACE}

export LFS_SOURCES=$WORKSPACE/sources
export LFS_BUILD=$WORKSPACE/build
export LFS_TOOLS=$WORKSPACE/tools
export LC_ALL=POSIX
export LFS_TGT=loongarch64-lfs-linux-gnu
export PATH=/usr/bin:/bin
export PATH=$WORKSPACE/tools/bin:$PATH
export CONFIG_SITE=$LFS/usr/share/config.site
export MAKEFLAGS="-j`nproc`"

function print
{
    echo $1
}

function prologue
{
    project=$1
    suffix=$2                                         
    rm -rf $LFS_BUILD/$project
    tar -xf $LFS_SOURCES/$project.$suffix -C $LFS_BUILD
    pushd $LFS_BUILD/$project
}

function epilogue
{
    popd
}

function update_config
{
    find \( -name config.sub -or -name config.guess \) -delete
    automake --add-missing || true
}
