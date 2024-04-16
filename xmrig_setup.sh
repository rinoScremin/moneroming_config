#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Install required packages
tce-load -wi hwloc
tce-load -wi hwloc-dev

tce-load -wi compiletc
tce-load -wi gcc
tce-load -wi make
tce-load -wi automake
tce-load -wi autoconf
tce-load -wi libtool
tce-load -wi libuv-dev
tce-load -wi openssl-dev
tce-load -wi cmake
tce-load -wi git

# Clone and build xmrig
git clone https://github.com/xmrig/xmrig.git
cd xmrig

mkdir build
cd build

cmake ..
make

echo "Build completed successfully!"
