#!/bin/bash

# in case build is executed from outside current dir be a gem and change the dir
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P)"
cd $CURRENT_DIR

if [ ! -f /.dockerenv ]; then
  echo "ERROR: This script is only supported running in docker"
  exit 1
fi

export BVER=5.2.37
export PREFIX=/usr/data/bash
export TOOL=/opt/toolchains/mips-gcc720-glibc229
export SYSROOT=/opt/k1-sysroot

if [ -d build ]; then
    rm -rf build/
fi
mkdir -p build

if [ ! -f bash-${BVER}.tar.gz ]; then
    wget https://ftp.gnu.org/gnu/bash/bash-${BVER}.tar.gz -O bash-${BVER}.tar.gz
fi

tar xzf bash-${BVER}.tar.gz -C build/
cd build/bash-${BVER}

CC=gcc CFLAGS="-O2" CPPFLAGS="-DPROTOTYPES=1" ./configure --build=$(gcc -dumpmachine)
make -C builtins mkbuiltins V=1 CC=gcc CFLAGS="-O2" CPPFLAGS="-DPROTOTYPES=1"
test -x builtins/mkbuiltins

# clean configure cache then cross-configure
make distclean
rm -f config.cache
cat > config.site <<EOF
ac_cv_func_setvbuf_reversed=no
ac_cv_func_strcoll_works=yes
ac_cv_type_rlim_t=yes
gt_cv_int_divbyzero_sigfpe=no
bash_cv_job_control_missing=present
bash_cv_sys_siglist=yes
bash_cv_must_reinstall_sighandlers=no
bash_cv_getcwd_malloc=yes
bash_cv_func_sigsetjmp=present
bash_cv_stat_time_t_signed=yes
ac_cv_c_prototypes=yes
EOF
export CONFIG_SITE=config.site

export CC="$TOOL/bin/mips-linux-gnu-gcc --sysroot=$SYSROOT"
export CXX="$TOOL/bin/mips-linux-gnu-g++ --sysroot=$SYSROOT"
export AR=$TOOL/bin/mips-linux-gnu-ar
export RANLIB=$TOOL/bin/mips-linux-gnu-ranlib
export STRIP=$TOOL/bin/mips-linux-gnu-strip

export CFLAGS="-Os -pipe -EL -march=mips32r2 -mhard-float -mfp64 -mnan=2008 -mno-mips16 -mno-micromips -fno-strict-aliasing -ffunction-sections -fdata-sections"
export LDFLAGS="-Wl,-EL -Wl,-m,elf32ltsmip -Wl,--gc-sections -Wl,-rpath-link,$SYSROOT/lib -Wl,-rpath-link,$SYSROOT/usr/lib -Wl,--dynamic-linker=/lib/ld-linux-mipsn8.so.1"

./configure --host=mips-linux-gnu --build=$(gcc -dumpmachine) --prefix="$PREFIX" \
  --without-bash-malloc --disable-nls --with-installed-readline=no

make -j"$(nproc)"
make DESTDIR="$PWD/_staging" install
$TOOL/bin/mips-linux-gnu-strip "$PWD/_staging/$PREFIX/bin/bash"
rm -rf $PWD/_staging/$PREFIX/include
rm -rf $PWD/_staging/$PREFIX/share

echo "Creating tarball..."
tar -C _staging -czf $CURRENT_DIR/build/bash.tar.gz .
