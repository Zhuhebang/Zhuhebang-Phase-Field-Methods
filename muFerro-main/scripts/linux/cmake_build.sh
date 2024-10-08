#!/bin/sh

# curr=$(pwd)

# while [ "$(basename "$(pwd)")" != "muprosdk" ]; do
#   cd ..
# done

# cd library

pwd
source ./scripts/linux/oneapi.sh
if [ -z "$2" ]; then
    cmake --build --preset="linux-$1"
else
    cmake --build --preset="linux-$1" --target "$2"
fi
# cd $curr