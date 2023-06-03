#!/bin/bash

set -o errexit
set -o nounset

source $WORKSPACE/scripts/header.sh
source $WORKSPACE/scripts/units.sh

#
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


log_file="$WORKSPACE/compile.log"
cat /dev/null > $log_file

function log
{
    echo $1 >> $log_file
}

function run
{
    cmd=$1                               
    name=$(echo $1 | sed -e 's/_/ /g')

    if [ -f $WORKSPACE/stages/$cmd ]; then
        log "skip: $cmd"
        return 0
    fi

    start=$(date +%s.%N)
    eval $cmd
    end=$(date +%s.%N)
    runtime=$(echo "$end - $start" | bc)
    log "$name: $runtime"

    touch $WORKSPACE/stages/$cmd
}

function handle_exit
{
    cat $log_file
}

trap handle_exit EXIT

# prepare
run file_system_layout

# compile tools
run compile_tool_binutils
run compile_tool_gcc_simple
run compile_linux_headers
run cross_compile_glibc
run compile_tool_gcc_full
run compile_tool_autoconf
run compile_tool_automake

# cross compile minifs
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
