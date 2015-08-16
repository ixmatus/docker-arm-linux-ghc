#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $THIS_DIR/set-env-1.sh
####################################################################################################

cd $CROSS_ADDON_SRC
apt-get source gnutls26
pushd gnutls26*
patch -p1 <$BASEDIR/patches/gnutls-no-atfork.patch
./configure --without-p11-kit --prefix="$CROSS_ADDON_PREFIX" --host=$CROSS_TARGET --build=$BUILD_ARCH CC="arm-plum-linux-gnueabi-gcc -fgnu89-inline" --enable-static --disable-shared
pushd lib
make $MAKEFLAGS
make install
popd
