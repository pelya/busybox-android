#!/bin/bash

set -x
ANDROID_NDK="$1"
NDK_TOOLCHAIN="$2"
ANDROID_ABI="$3"
ANDROID_TOOLCHAIN_COMPILER_VERSION="$4"
ANDROID_NATIVE_API_LEVEL="$5"
PREFIX="$6"

[ -n "$PREFIX" ] || { echo "Please run build-all.sh" ; exit 1 ; } || exit 1

pkg=busybox-1.21.0

[ -e $pkg.tar.bz2 ] || wget http://busybox.net/downloads/$pkg.tar.bz2 || exit 1

MYARCH=linux-x86
NCPU=4
if uname -s | grep -i "linux" > /dev/null ; then
	MYARCH=linux-x86
	NCPU=`cat /proc/cpuinfo | grep -c -i processor`
fi
if uname -s | grep -i "darwin" > /dev/null ; then
	MYARCH=darwin-x86
fi
if uname -s | grep -i "windows" > /dev/null ; then
	MYARCH=windows-x86
fi

grep "64.bit" "$ANDROID_NDK/RELEASE.TXT" >/dev/null 2>&1 && MYARCH="${MYARCH}_64"

rm -rf $pkg
echo "untar ..." >&2
tar jvxf $pkg.tar.bz2
cd $pkg
echo "patch ..." >&2
patch -b -p0 < ../busybox-android.patch
export ANDROID_NDK
export ANDROID_NDK_ROOT=$ANDROID_NDK
export CONFIG_CROSS_COMPILER_PREFIX CONFIG_SYSROOT CONFIG_EXTRA_CFLAGS CONFIG_EXTRA_LDFLAGS CONFIG_EXTRA_LDLIBS
case  "$ANDROID_ABI" in
    armeabi | armeabi-v7a)
        CONFIG_CROSS_COMPILER_PREFIX="arm-linux-androideabi-"
        CONFIG_SYSROOT="$ANDROID_NDK/platforms/$ANDROID_NATIVE_API_LEVEL/arch-arm"
        CONFIG_EXTRA_CFLAGS="-fsigned-char -march=armv5te -mtune=xscale -msoft-float -fdata-sections -ffunction-sections -fexceptions -mthumb -fPIC -Wno-psabi -DANDROID -D__ARM_ARCH_5__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__ -fomit-frame-pointer --sysroot $ANDROID_NDK/platforms/$ANDROID_NATIVE_API_LEVEL/arch-arm -isystem $ANDROID_NDK/platforms/$ANDROID_NATIVE_API_LEVEL/arch-arm/usr/include -isystem $ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/include -isystem $ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/$ANDROID_TOOLCHAIN_COMPILER_VERSION/include -isystem $ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/$ANDROID_TOOLCHAIN_COMPILER_VERSION/include/backward -isystem $ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/$ANDROID_TOOLCHAIN_COMPILER_VERSION/libs/armeabi/include $CFLAGS"
        CONFIG_EXTRA_LDFLAGS="-rdynamic --sysroot $ANDROID_NDK/platforms/$ANDROID_NATIVE_API_LEVEL/arch-arm -Wl,--gc-sections -L$ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/$ANDROID_TOOLCHAIN_COMPILER_VERSION/libs/armeabi -lgnustl_static -lsupc++ $LDFLAGS"
        CONFIG_EXTRA_LDLIBS=""
        ;;
    "mips") CONFIG_CROSS_COMPILER_PREFIX="mipsel-linux-android-"
        CONFIG_SYSROOT="$ANDROID_NDK/platforms/$ANDROID_NATIVE_API_LEVEL/arch-mips"
        CONFIG_EXTRA_CFLAGS="-fPIC -Wno-psabi -DANDROID -fomit-frame-pointer -fno-strict-aliasing -finline-functions -ffunction-sections -funwind-tables -fmessage-length=0 -fno-inline-functions-called-once -fgcse-after-reload -frerun-cse-after-loop -frename-registers --sysroot $ANDROID_NDK/platforms/$ANDROID_NATIVE_API_LEVEL/arch-mips -isystem $ANDROID_NDK/platforms/$ANDROID_NATIVE_API_LEVEL/arch-mips/usr/include -isystem $ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/$ANDROID_TOOLCHAIN_COMPILER_VERSION/include -isystem $ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/$ANDROID_TOOLCHAIN_COMPILER_VERSION/include/backward -isystem $ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/$ANDROID_TOOLCHAIN_COMPILER_VERSION/libs/mips/include $CFLAGS"
        CONFIG_EXTRA_LDFLAGS="-rdynamic --sysroot $ANDROID_NDK/platforms/$ANDROID_NATIVE_API_LEVEL/arch-mips -Wl,--gc-sections -L$ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/$ANDROID_TOOLCHAIN_COMPILER_VERSION/libs/mips -lgnustl_static -lsupc++ $LDFLAGS"
        CONFIG_EXTRA_LDLIBS=""
        ;;
    "x86") CONFIG_CROSS_COMPILER_PREFIX="i686-linux-android-"
        CONFIG_SYSROOT="$ANDROID_NDK/platforms/$ANDROID_NATIVE_API_LEVEL/arch-x86"
        CONFIG_EXTRA_CFLAGS="-march=i686 -mtune=atom -DANDROID -fPIC -mandroid -mstackrealign -msse3 -mfpmath=sse -m32 -fno-short-enums -ffunction-sections -funwind-tables -fomit-frame-pointer -fstrict-aliasing -funswitch-loops  -Wa,--noexecstack --sysroot $ANDROID_NDK/platforms/$ANDROID_NATIVE_API_LEVEL/arch-x86 -isystem $ANDROID_NDK/platforms/$ANDROID_NATIVE_API_LEVEL/arch-x86/usr/include -isystem $ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/$ANDROID_TOOLCHAIN_COMPILER_VERSION/include -isystem $ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/$ANDROID_TOOLCHAIN_COMPILER_VERSION/include/backward -isystem $ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/$ANDROID_TOOLCHAIN_COMPILER_VERSION/libs/x86/include $CFLAGS"
        CONFIG_EXTRA_LDFLAGS="-rdynamic --sysroot $ANDROID_NDK/platforms/$ANDROID_NATIVE_API_LEVEL/arch-x86 -Wl,--gc-sections -L$ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/$ANDROID_TOOLCHAIN_COMPILER_VERSION/libs/x86 -lgnustl_static -lsupc++ $LDFLAGS"
        CONFIG_EXTRA_LDLIBS=""
        ;;
esac

unset CFLAGS
unset LDFLAGS

echo "config ..." >&2
cat ../busybox-android.config | sed "s|CONFIG_CROSS_COMPILER_PREFIX_TEMPLATE|$CONFIG_CROSS_COMPILER_PREFIX|" | sed "s|CONFIG_SYSROOT_TEMPLATE|$CONFIG_SYSROOT|" | sed "s|CONFIG_EXTRA_CFLAGS_TEMPLATE|$CONFIG_EXTRA_CFLAGS|" | sed "s|CONFIG_EXTRA_LDFLAGS_TEMPLATE|$CONFIG_EXTRA_LDFLAGS|" | sed "s|CONFIG_EXTRA_LDLIBS_TEMPLATE|$CONFIG_EXTRA_LDLIBS|" > .config
PATH=$ANDROID_NDK_ROOT:$PATH
PATH=$ANDROID_NDK_ROOT/toolchains/$NDK_TOOLCHAIN/prebuilt/$MYARCH/bin:$PATH
export PATH

echo "make ..." >&2
make -j$NCPU || exit 1
make CONFIG_PREFIX=$PREFIX install || exit 1

upx $PREFIX/bin/busybox || echo "Please install UPX: sudo apt-get install upx"
