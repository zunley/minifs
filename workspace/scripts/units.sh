#!/bin/bash

function compile_tool_binutils
{
    prologue binutils-$BINUTILS_VERSION tar.xz
	mkdir -pv build
	cd build
	../configure --prefix=$LFS_TOOLS \
	             --with-sysroot=$LFS \
	             --target=$LFS_TGT   \
	             --disable-nls       \
	             --enable-gprofng=no \
	             --disable-werror
	make
	make install
    epilogue
}

function compile_tool_gmp
{
    prologue gmp-$GMP_VERSION tar.xz
    ./configure --prefix=$LFS_TOOLS \
        --enable-cxx \
        --disable-static
    make
    make install
    epilogue
}

function compile_tool_mpfr
{
    prologue mpfr-$MPFR_VERSION tar.xz
    ./configure --prefix=$LFS_TOOLS \
        --disable-static \
        --with-gmp=$LFS_TOOLS
    make
    make install
    epilogue
}

function compile_tool_mpc
{
    prologue mpc-$MPC_VERSION tar.gz
    ./configure --prefix=$LFS_TOOLS \
        --disable-static \
        --with-gmp=$LFS_TOOLS
    make
    make install
    epilogue
}

function compile_tool_gcc_simple
{
    prologue gcc-$GCC_VERSION tar.xz
    sed -i 's/lib64/lib/g' gcc/config/loongarch/t-linux
    sed -i 's/lib64/lib/g' gcc/config/loongarch/linux.h

	mkdir -pv build
	cd build

	../configure			      \
		--target=$LFS_TGT         \
		--prefix=$LFS_TOOLS       \
		--with-glibc-version=2.37 \
		--with-sysroot=$LFS       \
		--with-newlib             \
        --with-gmp=$LFS_TOOLS \
        --with-mpfr=$LFS_TOOLS \
        --with-mpc=$LFS_TOOLS \
		--without-headers         \
		--enable-default-pie      \
		--enable-default-ssp      \
		--disable-nls             \
		--disable-shared          \
		--disable-multilib        \
		--disable-threads         \
		--disable-libatomic       \
		--disable-libgomp         \
		--disable-libquadmath     \
		--disable-libssp          \
		--disable-libvtv          \
		--enable-languages=c

	make
	make install
    cd ..
    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
        `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include/limits.h
    epilogue
}

function compile_tool_autoconf
{
    prologue autoconf-$AUTOCONF_VERSION tar.xz
    ./configure --prefix=$LFS_TOOLS
    make
    make install
    epilogue
}

function compile_tool_automake
{
    prologue automake-$AUTOMAKE_VERSION tar.xz
    ./configure --prefix=$LFS_TOOLS
    make
    make install
    epilogue
}

function install_linux_header
{
    prologue linux-$LINUX_VERSION tar.xz
    make mrproper
    make ARCH=loongarch headers
    find usr/include -type f ! -name '*.h' -delete
    cp -rv usr/include $LFS/usr
    epilogue
}


function cross_compile_glibc
{
    prologue glibc-$GLIBC_VERSION tar.xz
    patch -Np1 -i $LFS_SOURCES/patches/glibc-2.37-fhs-1.patch
    mkdir -v build
    cd build
    echo "rootsbindir=/usr/sbin" > configparms
    CC=$LFS_TGT-gcc CXX=$LFS_TGT-gcc     \
    ../configure                         \
      --prefix=/usr                      \
      --build=$(../scripts/config.guess) \
      --host=$LFS_TGT                    \
      --enable-kernel=4.15               \
      --with-binutils=$LFS_TOOLS/bin     \
      --with-headers=$LFS/usr/include    \
      --libdir=/usr/lib                  \
      --libexecdir=/usr/lib              \
      libc_cv_slibdir=/usr/lib           \
      libc_cv_rtlddir=/usr/lib
    make
    make DESTDIR=$LFS install
    epilogue

    sed '/RTLDLIST=/s@/usr/lib64@/usr/lib@g' -i $LFS/usr/bin/ldd
}

function compile_tool_gcc_full
{
    prologue gcc-$GCC_VERSION tar.xz
    sed -i 's/lib64/lib/g' gcc/config/loongarch/t-linux
    sed -i 's/lib64/lib/g' gcc/config/loongarch/linux.h

    mkdir build
    cd build
    ../configure --prefix=$LFS_TOOLS \
        --build=$(config.guess) \
        --host=$(config.guess) \
        --target=$LFS_TGT \
        --with-sysroot=$LFS \
        --with-gmp=$LFS_TOOLS \
        --with-mpfr=$LFS_TOOLS \
        --with-mpc=$LFS_TOOLS \
        --enable-default-pie \
        --enable-default-ssp \
        --enable-languages=c,c++
    make
    make install
    epilogue
}

function cross_compile_m4
{
    prologue m4-$M4_VERSION tar.xz
    patch -Np1 -i $LFS_SOURCES/patches/m4-1.4.19-loongarch64.patch
    ./configure --prefix=/usr   \
            --build=$(build-aux/config.guess) \
            --host=$LFS_TGT \
    make
    make DESTDIR=$LFS install
    epilogue
}

function cross_compile_ncurses
{
    prologue ncurses-$NCURSES_VERSION tar.gz
    sed -i s/mawk// configure
    mkdir build
    pushd build
        ../configure
        make -C include
        make -C progs tic
    popd
    CC=$LFS_TGT-gcc CXX=$LFS_TGT-gcc     \
    ./configure --prefix=/usr            \
            --host=$LFS_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-normal             \
            --with-cxx-shared            \
            --without-debug              \
            --without-ada                \
            --disable-stripping          \
            --enable-widec
    make
    make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
    echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
    epilogue
}

function cross_compile_bash
{
    prologue bash-$BASH_VERSION tar.gz
    ./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$LFS_TGT                    \
            --without-bash-malloc
    make
    make DESTDIR=$LFS install
    epilogue

    ln -sv bash $LFS/bin/sh
}

function cross_compile_coreutils
{
    prologue coreutils-$COREUTILS_VERSION tar.xz
    ./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime
    make
    make DESTDIR=$LFS install
    epilogue

    mv -v $LFS/usr/bin/chroot $LFS/usr/sbin
    mkdir -pv $LFS/usr/share/man/man8
    mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
    sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8
}

function cross_compile_diffutils
{
    prologue diffutils-$DIFFUTILS_VERSION tar.xz
    ./configure --prefix=/usr --host=$LFS_TGT
    make
    make DESTDIR=$LFS install
    epilogue
}

function cross_compile_file
{
    prologue file-$FILE_VERSION tar.gz
    update_config
    mkdir build
    pushd build
        ../configure --disable-bzlib      \
               --disable-libseccomp \
               --disable-xzlib      \
               --disable-zlib
        make
    popd
    ./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
    make FILE_COMPILE=$(pwd)/build/src/file
    make DESTDIR=$LFS install
    epilogue

    rm -v $LFS/usr/lib/libmagic.la
}

function cross_compile_findutils
{
    prologue findutils-$FINDUTILS_VERSION tar.xz
    update_config
    ./configure --prefix=/usr                   \
            --localstatedir=/var/lib/locate \
            --host=$LFS_TGT                 \
            --build=$(build-aux/config.guess)
    make
    make DESTDIR=$LFS install
    epilogue
}

function cross_compile_gawk
{
    prologue gawk-$GAWK_VERSION tar.xz
    sed -i 's/extras//' Makefile.in
    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
    make
    make DESTDIR=$LFS install
    epilogue
}

function cross_compile_grep
{
    prologue grep-$GREP_VERSION tar.xz
    ./configure --prefix=/usr \
        --host=$LFS_TGT
    make
    make DESTDIR=$LFS install
    epilogue
}

function cross_compile_gzip
{
    prologue gzip-$GZIP_VERSION tar.xz
    ./configure --prefix=/usr --host=$LFS_TGT
    make
    make DESTDIR=$LFS install
    epilogue
}

function cross_compile_make
{
    prologue make-$MAKE_VERSION tar.gz
    # FIX: upstream issues
    sed -e '/ifdef SIGPIPE/,+2 d' \
        -e '/undef  FATAL_SIG/i FATAL_SIG (SIGPIPE);' \
        -i src/main.c

    ./configure --prefix=/usr   \
            --without-guile \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
    make
    make DESTDIR=$LFS install
    epilogue
}

function cross_compile_patch
{
    prologue patch-$PATCH_VERSION tar.xz
    rm configure
    autoreconf -i
    update_config
    ./configure --prefix=/usr  \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
    make
    make DESTDIR=$LFS install
    epilogue
}

function cross_compile_sed
{
    prologue sed-$SED_VERSION tar.xz

    ./configure --prefix=/usr   \
            --host=$LFS_TGT
    make
    make DESTDIR=$LFS install

    epilogue
}

function cross_compile_tar
{
    prologue tar-$TAR_VERSION tar.xz
    rm configure
    autoreconf
    update_config
    ./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess)
    make
    make DESTDIR=$LFS install
    epilogue
}

function cross_compile_xz
{
    prologue xz-$XZ_VERSION tar.xz
    rm build-aux/config.{guess,sub}
    automake --add-missing
    ./configure --prefix=/usr                   \
            --host=$LFS_TGT                     \
            --build=$(build-aux/config.guess)   \
            --disable-static                    \
            --docdir=/usr/share/doc/xz-5.4.1
    make
    make DESTDIR=$LFS install
    epilogue

    rm -v $LFS/usr/lib/liblzma.la
}

function cross_compile_zlib
{
    prologue zlib-$ZLIB_VERSION tar.xz
    CROSS_PREFIX=$LFS_TGT- ./configure --prefix=/usr --libdir=/usr/lib
    make
    make DESTDIR=$LFS install
    epilogue
}

function cross_compile_gmp
{
    prologue gmp-$GMP_VERSION tar.xz
    update_config
    ./configure --prefix=/usr --libdir=/usr/lib \
        --build=$(./config.guess) \
        --host=$LFS_TGT \
        --enable-cxx \
        --disable-static \
        --docdir=/usr/share/doc/gmp-$GMP_VERSION
    make
    make DESTDIR=$LFS install
    epilogue

    rm -v $LFS/usr/lib/lib{gmp,gmpxx}.la
}

function cross_compile_mpfr
{
    prologue mpfr-$MPFR_VERSION tar.xz
    update_config
    ./configure --prefix=/usr --libdir=/usr/lib \
        --build=$(./config.guess) \
        --host=$LFS_TGT \
        --disable-static \
        --enable-thread-safe \
        --docdir=/usr/share/doc/mpfr-$MPFR_VERSION
    make
    make DESTDIR=$LFS install
    epilogue

    rm -v $LFS/usr/lib/libmpfr.la
}

function cross_compile_mpc
{
    prologue mpc-$MPC_VERSION tar.gz
    update_config
    ./configure --prefix=/usr --libdir=/usr/lib \
        --build=$(build-aux/config.guess) \
        --host=$LFS_TGT \
        --disable-static \
        --docdir=/usr/share/doc/mpc-$MPC_VERSION
    make
    make DESTDIR=$LFS install
    epilogue

    rm -v $LFS/usr/lib/libmpc.la
}

function cross_compile_binutils
{
    prologue binutils-$BINUTILS_VERSION tar.xz
    mkdir build
    cd build
    ../configure --prefix=/usr --libdir=/usr/lib \
        --build=$(../config.guess) \
        --host=$LFS_TGT \
        --host=$LFS_TGT \
        --sysconfdir=/etc \
        --enable-ld=default \
        --enable-plguins \
        --enable-shared \
        --disable-werror \
        --enable-64-bit-bfd \
        --with-system-zlib
    make
    make DESTDIR=$LFS install
    epilogue
}

function cross_compile_gcc
{
    prologue gcc-$GCC_VERSION tar.xz
    sed -i 's/lib64/lib/g' gcc/config/loongarch/t-linux
    sed -i 's/lib64/lib/g' gcc/config/loongarch/linux.h
    mkdir -v build
    cd build
    ../configure --prefix=/usr --libdir=/usr/lib \
        --build=$(../config.guess) \
        --host=$LFS_TGT \
        --target=$LFS_TGT \
        --with-build-sysroot=$LFS \
        --enable-default-pie \
        --enable-default-ssp \
        --disable-multilib \
        --with-system-zlib \
        --enable-languages=c,c++
    make
    make DESTDIR=$LFS install
    epilogue

    ln -sv gcc $LFS/usr/bin/cc
}

function cross_compile_ca_certificates
{
    prologue ca-certificates-$CA_CERTIFICATES_VERSION tar.bz2
    CC=$LFS_TGT-gcc make
    make DESTDIR=$LFS install
    epilogue
}

function cross_compile_openssl
{
    prologue openssl-$OPENSSL_VERSION tar.gz
    CC=$LFS_TGT-gcc \
    ./Configure --prefix=/usr \
        --openssldir=/etc/ssl \
        --libdir=lib \
        shared zlib linux-generic64
    make
    sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
    make DESTDIR=$LFS install
    epilogue
}

function cross_compile_curl
{
    prologue curl-$CURL_VERSION tar.xz
    ./configure --prefix=/usr --libdir=/usr/lib \
        --build=$(config.guess) \
        --host=$LFS_TGT \
        --with-openssl \
        --enable-threaded-resolver \
        --with-ca-path=/etc/ssl/certs
    make
    make DESTDIR=$LFS install
    epilogue
}

function cross_compile_vim
{
    prologue vim-$VIM_VERSION tar.gz
    echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

    cat > src/auto/config.cache << EOF
    vim_cv_getcwd_broken=no
	vim_cv_toupper_broken=no
	vim_cv_terminfo=yes
	vim_cv_tgetent=zero
	vim_cv_stat_ignores_slash=no
	vim_cv_memmove_handles_overlap=yes
	ac_cv_small_wchar_t=n
EOF
    ./configure --prefix=/usr \
        --host=$LFS_TGT \
        --with-tlib=ncurses
    make
    make DESTDIR=$LFS STRIP=$LFS_TGT-strip install
    epilogue

    ln -sv vim $LFS/usr/bin/vi
}
