#!/bin/bash

set -o errexit
set -o nounset

source $WORKSPACE/scripts/header.sh
source $WORKSPACE/scripts/units.sh

# Project Layout
# ├── rootfs
# │   ├── bin -> usr/bin
# │   ├── dev
# │   ├── etc
# │   ├── lib -> usr/lib
# │   ├── lib64 -> usr/lib
# │   ├── proc
# │   ├── run
# │   ├── sbin -> usr/sbin
# │   ├── sys
# │   ├── usr
# │   └── var
# └── workspace
#     ├── build
#     ├── scripts
#     ├── sources
#     ├── stages
#     └── tools

init rootfs
trap show_log EXIT

run install_linux_header
run cross_compile_glibc
run cross_compile_m4
run cross_compile_ncurses
run cross_compile_bash
run cross_compile_coreutils
run cross_compile_diffutils
run cross_compile_file
run cross_compile_findutils
run cross_compile_gawk
run cross_compile_grep
run cross_compile_gzip
run cross_compile_make
run cross_compile_patch
run cross_compile_sed
run cross_compile_tar
run cross_compile_xz
run cross_compile_zlib
run cross_compile_gmp
run cross_compile_mpfr
run cross_compile_mpc
run cross_compile_binutils
run cross_compile_gcc
run cross_compile_openssl
run cross_compile_ca_certificates
run cross_compile_curl
run cross_compile_vim
