#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $THIS_DIR/set-env-1.sh
####################################################################################################

(cd $CROSS_ADDON_SRC; tar xf "$TARDIR/$GMP_TAR_FILE")
pushd $GMP_SRC > /dev/null
./configure --prefix="$CROSS_ADDON_PREFIX" --host=$CROSS_TARGET --build=$BUILD_ARCH --with-build-cc=$BUILD_GCC --enable-static --disable-shared
make $MAKEFLAGS
make install
popd > /dev/null
