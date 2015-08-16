#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $THIS_DIR/set-env.sh
####################################################################################################

echo "Fetching iconv"
curl -o "$ICONV_TAR_PATH" http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz  2>&1
