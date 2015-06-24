#!/bin/sh

NDK=`which ndk-build`
NDK=`dirname $NDK`
NDK=`readlink -f $NDK`

export CFLAGS="-Os"
./build.sh $NDK x86-4.8 x86 4.8 android-14 `pwd`/build/x86 || exit 1
./build.sh $NDK arm-linux-androideabi-4.8 armeabi 4.8 android-14 `pwd`/build/arm || exit 1
./build.sh $NDK mipsel-linux-android-4.8 mips 4.8 android-14 `pwd`/build/mips || exit 1

#export CFLAGS="-Os -flto"
#export LDFLAGS="-flto"
#./build.sh $NDK x86-4.8 x86 4.8 android-14 `pwd`/build-gcc4.8/x86 || exit 1
#./build.sh $NDK arm-linux-androideabi-4.8 armeabi 4.8 android-14 `pwd`/build-gcc4.8/arm || exit 1
#./build.sh $NDK mipsel-linux-android-4.8 mips 4.8 android-14 `pwd`/build-gcc4.8/mips || exit 1
