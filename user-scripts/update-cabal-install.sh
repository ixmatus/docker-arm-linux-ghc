#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $THIS_DIR/set-env-1.sh
####################################################################################################

arm-plum-linux-gnueabi-cabal update
CFG=$CROSS/.cabal/config

cat $CFG | sed 's/^\(jobs.*\)$/-- \1/' > $CFG.new
rm -f $CFG
mv $CFG.new $CFG

