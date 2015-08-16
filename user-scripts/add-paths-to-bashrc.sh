#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $THIS_DIR/set-env-1.sh
####################################################################################################

mv $HOME/.bashrc $HOME/.bashrc_default

cat <<EOF > $HOME/.bashrc
if [ -f \$HOME/.bashrc_default ]; then
  source \$HOME/.bashrc_default
fi

export GHC_HOST=\$HOME/.ghc/arm-host
export PATH=\$HOME/.cabal/bin:/root/x-tools/arm-plum-linux-gnueabi/bin:/root/x-tools/arm-plum-linux-gnueabi/sysroot/usr/bin:\$PATH

EOF
