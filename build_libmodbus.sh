#!/bin/bash

if [ $# -ne 1 ]; then
    echo $0: usage: cross_compile_library.sh ARCH 
    echo "example: usage: cross_compile_library.sh [ arm-linux | arm-linux-gnueabihf | arm-linux-gnueabi ]"
    exit 1
fi

export PATH="$PATH:$1/bin"

tool_chain_path=$1
#ARCH=`echo $1 | awk -F"/" '{print (NF>1)? $NF : $1}'`

# linux architecture 
item=`ls $tool_chain_path/bin | grep gcc`
IFS=' ' read -ra ADDR <<< "$item"
item="${ADDR[0]}"
ARCH=`echo $item | sed -e 's/-gcc.*//g'`

echo "Building libmodbus..."

# ======== libmodbus with static build ========
export ARCH=$ARCH
export AR=${ARCH}-ar
export AS=${ARCH}-as
export LD=${ARCH}-ld
export RANLIB=${ARCH}-ranlib
export CC=${ARCH}-gcc
export NM=${ARCH}-nm

./autogen.sh;
if [ $tool_chain_path == '/usr/local'  ]; then
  ./configure --prefix=$tool_chain_path ac_cv_func_malloc_0_nonnull=yes --enable-static --without-documentation
else
  ./configure --prefix=$tool_chain_path ac_cv_func_malloc_0_nonnull=yes --target=${ARCH} --host=${ARCH}  --enable-static --without-documentation
fi
make
sudo "PATH=$PATH" make install
sudo rm $tool_chain_path/lib/libmodbus.so*
