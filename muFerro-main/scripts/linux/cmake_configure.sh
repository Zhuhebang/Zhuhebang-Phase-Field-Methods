#!/bin/sh

# curr=$(pwd)

# while [ "$(basename "$(pwd)")" != "muprosdk" ]; do
#   cd ..
# done

# cd library

source ./scripts/linux/oneapi.sh
cmake --preset="linux-$1" -S "." 

# cd $curr