#!/bin/bash

#
# This script is responsible for setting up all the environment variables exactly the way
# they should be for building GHC. It will be sourced from other build scripts, but not
# run directly by Docker.
#

[ -e /etc/makepkg.conf ] && source /etc/makepkg.conf
MAKEFLAGS=${MAKEFLAGS:--j9}

# Basic configuration
GHCHOME=$HOME/.ghc
BASEDIR="/opt/arm"
mkdir -p "${BASEDIR}"
cd "${BASEDIR}"

CROSS_PLATFORM="arm"

CROSS_TARGET="arm-plum-linux-gnueabi"
CROSS_DESC="${CROSS_TARGET}"
ARCH_OPTS="-fllvm"

CROSS="/root/x-tools/${CROSS_TARGET}"
CROSS_ADDON_SRC="$BASEDIR/build"
CROSS_ADDON_PREFIX="$CROSS/sysroot/usr"

GHC_STAGE0_SRC="$BASEDIR/stage0"
GHC_STAGE0_PREFIX="$GHCHOME/arm-host"
GHC_STAGE0="$GHC_STAGE0_PREFIX/bin/ghc"

GHC_PREFIX="$CROSS"
GHC_SRC="$CROSS_ADDON_SRC/ghc"

# GHC tarball
GHC_RELEASE=7.8.4
GHC_MD5=91f74cf9d813603cc3145528db4bbead

NCURSES_RELEASE=5.9
NCURSES_MD5=8cb9c412e5f2d96bc6f459aa8c6282a1

GMP_RELEASE=5.1.3
GMP_MD5=e5fe367801ff067b923d1e6a126448aa

CONFIG_SUB_SRC=${CONFIG_SUB_SRC:-/usr/share/automake-1.14}

BUILD_GCC=gcc
BUILD_ARCH=$($BUILD_GCC -v 2>&1 | grep ^Target: | cut -f 2 -d ' ')

mkdir -p "$GHCHOME"
mkdir -p "$CROSS_ADDON_SRC"
mkdir -p "${BASEDIR}/tarfiles"
TARDIR="${BASEDIR}/tarfiles"

function check_md5() {
    FILENAME="$1"
    MD5="$2"
    [ -e "${FILENAME}" ] || return 1;
    ACTUAL_MD5=$(md5sum "$FILENAME" | cut -f1 -d ' ')
    if [ ! "$ACTUAL_MD5" == "$MD5" ]; then
      >&2 echo "MD5 hash of $FILENAME did not match."
      >&2 echo "$MD5 =/= $ACTUAL_MD5"
      exit 1
    fi
}

function apply_patches() {
    pushd $2 > /dev/null
    for p in $(find "$BASEDIR/patches" -name "$1") ; do
        echo Applying patch $p in $(pwd)
        patch -p1 < "$p"
    done
    popd > /dev/null
}

# Add cross-compiler toolchain to path
export PATH="$CROSS/bin":$PATH

# Unpack ncurses
NCURSES_TAR_FILE="ncurses-${NCURSES_RELEASE}.tar.gz"
NCURSES_TAR_PATH="${TARDIR}/${NCURSES_TAR_FILE}"
NCURSES_SRC="$CROSS_ADDON_SRC/ncurses-${NCURSES_RELEASE}"

ICONV_TAR_FILE="libiconv-1.14.tar.gz"
ICONV_TAR_PATH="${TARDIR}/${ICONV_TAR_FILE}"
ICONV_SRC="$CROSS_ADDON_SRC/libiconv-1.14"

GMP_TAR_FILE="gmp-${GMP_RELEASE}.tar.xz"
GMP_TAR_PATH="${TARDIR}/${GMP_TAR_FILE}"
GMP_SRC="$CROSS_ADDON_SRC/gmp-${GMP_RELEASE}"

GHC_TAR_FILE="ghc-${GHC_RELEASE}-src.tar.xz"
GHC_TAR_PATH="${TARDIR}/${GHC_TAR_FILE}"
