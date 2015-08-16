#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $THIS_DIR/set-env-1.sh
####################################################################################################

cd $CROSS_ADDON_SRC
tar xf ${GHC_TAR_PATH}
mv ghc-${GHC_RELEASE} "$GHC_SRC"
apply_patches 'ghc-*' "$GHC_SRC"
pushd "$GHC_SRC" > /dev/null

# Setup build.mk
cat > mk/build.mk <<EOF
Stage1Only = YES
DYNAMIC_GHC_PROGRAMS = NO
SRC_HC_OPTS     = -O -H64m
GhcStage1HcOpts = -O2 -fasm
GhcStage2HcOpts = -O2 -fasm $ARCH_OPTS
GhcHcOpts       = -Rghc-timing
GhcLibHcOpts    = -O2
GhcLibWays      = v
HADDOCK_DOCS       = NO
BUILD_DOCBOOK_HTML = NO
BUILD_DOCBOOK_PS   = NO
BUILD_DOCBOOK_PDF  = NO
EOF

# Update config.sub and config.guess
for x in $(find . -name "config.sub") ; do
    dir=$(dirname $x)
    cp -v "$CONFIG_SUB_SRC/config.sub" "$dir"
    cp -v "$CONFIG_SUB_SRC/config.guess" "$dir"
done

# Apply library patches
apply_patches "hsc2hs-*" "$GHC_SRC/utils/hsc2hs"
apply_patches "haskeline-*" "$GHC_SRC/libraries/haskeline"
apply_patches "unix-*" "$GHC_SRC/libraries/unix"
apply_patches "base-*" "$GHC_SRC/libraries/base"

# Fix the vendor triplet detection so Plum's vendor-specific cross
# compiler toolchain will be recognized...
echo "Adding the plum vendor (don't need this if you have an unknown or custom vendor)"
sed -i 's/dec|unknown|hp|apple|next|sun|sgi|ibm|montavista|portbld)/plum|dec|unknown|hp|apple|next|sun|sgi|ibm|montavista|portbld)/' ./aclocal.m4

echo "Commenting out ncurses and haskline, they're giving me problems"
sed -i 's/PACKAGES_STAGE1 += terminfo/#PACKAGES_STAGE1 += terminfo/' ghc.mk
sed -i 's/PACKAGES_STAGE1 += haskeline/#PACKAGES_STAGE1 += haskeline/' ghc.mk

# Configure
perl boot

./configure --enable-bootstrap-with-devel-snapshot --prefix="$GHC_PREFIX" --target=$CROSS_TARGET \
            --with-ghc=$GHC_STAGE0 --with-gcc=$CROSS/bin/$CROSS_TARGET-gcc \
            --with-gmp-includes="${CROSS_ADDON_PREFIX}/include" \
            --with-gmp-libraries="${CROSS_ADDON_PREFIX}/lib"

function check_install_gmp_constants() {
    echo "This really should be generalized a bit better..."
    GMPDCHDR="libraries/integer-gmp/mkGmpDerivedConstants/dist"
    if ! [ -e  "${GMPDCHDR}/GmpDerivedConstants.h" ] ; then
        if [ -e "$BASEDIR/patches/gmp-arm-linux-gnueabi-GmpDerivedConstants.h" ] ; then
            mkdir -p "${GMPDCHDR}"
            cp -v "$BASEDIR/patches/gmp-arm-linux-gnueabi-GmpDerivedConstants.h" "$GMPDCHDR/GmpDerivedConstants.h"
        else
            echo \#\#\# Put the cross-compiled mkGmpDerivedConstants program on your target and execute it to get the constants you need for GMP.
            exit 1
        fi
    fi
}

#
# The nature of parallel builds that once in a blue moon this directory does not get created
# before we try to "/usr/bin/install -c -m 644  utils/hsc2hs/template-hsc.h "/home/androidbuilder/.ghc/android-host/lib/ghc-7.8.4"
# This causes a conflict.
#
/usr/bin/install -c -m 755 -d "$GHC_PREFIX/lib/arm-plum-linux-gnueabi-ghc-${GHC_RELEASE}/include/"
make $MAKEFLAGS || true # TMP hack, see http://hackage.haskell.org/trac/ghc/ticket/7490
make $MAKEFLAGS || true # TMP hack, target mkGmpDerivedConstants fails on build host
# There's a long pause at this point. Just be patient!
check_install_gmp_constants
make $MAKEFLAGS || true # TMP hack, tries to execut inplace stage2
make $MAKEFLAGS || true # TMP hack, one more for luck
make install
