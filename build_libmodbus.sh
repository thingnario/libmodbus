#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: ./build_libmodbus.sh tool_chain_path install_path!"
    echo "Example: ./build_libmodbus.sh /usr/local/arm-linux /Desktop/eric/logger/build/moxa-ia240/libmodbus"
    exit
fi

export PATH="$PATH:$1/bin"
export CPATH="$1/include"

tool_chain_path=$1
#ARCH=`echo $1 | awk -F"/" '{print (NF>1)? $NF : $1}'`

# linux architecture 
item=`ls $tool_chain_path/bin | grep gcc`
IFS=' ' read -ra ADDR <<< "$item"
item="${ADDR[0]}"
ARCH=`echo $item | sed -e 's/-gcc.*//g'`

echo "Building libmodbus..."

# ======== libmodbus with static build ========
./autogen.sh;
if [ "$ARCH" == "" ]; then
  export AR=ar
  export LD=ld
  export AS=as
  export CC=gcc
  ./configure --prefix=$2 ac_cv_func_malloc_0_nonnull=yes --enable-static --without-documentation
else
  export AR=${ARCH}-ar
  export AS=${ARCH}-as
  export LD=${ARCH}-ld
  export RANLIB=${ARCH}-ranlib
  export CC=${ARCH}-gcc
  export NM=${ARCH}-nm
  ./configure --prefix=$2 ac_cv_func_malloc_0_nonnull=yes --target=${ARCH} --host=${ARCH}  --enable-static --without-documentation
fi
make
make install
rm $2/lib/libmodbus.so*
