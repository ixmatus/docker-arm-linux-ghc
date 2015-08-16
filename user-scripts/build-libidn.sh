#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $THIS_DIR/set-env-1.sh
####################################################################################################

cd $CROSS_ADDON_SRC
apt-get source libidn
pushd libidn*
./configure --prefix="$CROSS_ADDON_PREFIX" --host=$CROSS_TARGET --build=$BUILD_ARCH \
  --with-build-cc=$BUILD_GCC --enable-static --disable-shared
make $MAKEFLAGS || true
make install
popd


