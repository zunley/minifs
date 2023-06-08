#!/bin/bash
set -o errexit
set -o nounset

source $WORKSPACE/scripts/header.sh
source $WORKSPACE/scripts/units.sh

init tools
trap show_log EXIT

run compile_tool_binutils
run compile_tool_gmp
run compile_tool_mpfr
run compile_tool_mpc
run compile_tool_gcc_simple
run install_linux_header
run cross_compile_glibc
run compile_tool_gcc_full
run compile_tool_autoconf
run compile_tool_automake

