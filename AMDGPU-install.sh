#!/bin/bash

# This script will install AMDGPU-PRO OpenCL and Vulkan support.
#
# For Ubuntu and it's flavor, just install the package using this command
# in extracted driver directory instread.
#
#     ./amdgpu-pro-install --opencl=legacy,pal --headless --no-dkms
#
# For Arch Linux or Manjaro, use the opencl-amd or rocm-opencl-runtime on AUR instread.
#
# To use amdvlk driver, launch the program/game with this command :
#
#     VK_ICD_FILENAMES="/opt/amdgpu-pro/etc/vulkan/icd.d/amd_icd64.json" game64
#
# If the program/game is 32bit, use this command :
#
#     VK_ICD_FILENAMES="/opt/amdgpu-pro/etc/vulkan/icd.d/amd_icd32.json" game32
#

prefix='amdgpu-pro'

# amdgpu-pro package version
major='21'
minor='30'
build='1290604'
system='ubuntu-20.04'

# libdrm-amdgpu-amdgpu1 version
libdrmver='2.4.106'
libamd_comgrver='2.1.0'
libhsa_ver='1.3.0'
libamdhip_ver='4.2.21303'

shared32="/usr/lib32"
shared64="/usr/lib"
amd_shared32="/opt/amdgpu-pro/lib/i386-linux-gnu"
amd_shared64="/opt/amdgpu-pro/lib/x86_64-linux-gnu"
ids="/opt/amdgpu/share/libdrm"
vk_icd="/opt/amdgpu-pro/etc/vulkan/icd.d"
gcn_bitcode="/opt/amdgpu-pro/amdgcn/bitcode"

# make sure we’re running with root permissions.
if [ `whoami` != root ]; then
    echo Please run this script using sudo
    exit
fi

# check for 64-bit arch
if [ $(uname -m) != 'x86_64' ]; then
    echo This install script support only 64-bit linux. 
    exit
fi

# download and extract drivers
rm -r ${prefix}-${major}.${minor}-${build}-${system} &>/dev/null

if [ ! -f ./${prefix}-${major}.${minor}-${build}-${system}.tar.xz ]; then
    wget --referer https://www.amd.com/en/support/kb/release-notes/rn-amdgpu-unified-linux-21-30 https://drivers.amd.com/drivers/linux/${prefix}-${major}.${minor}-${build}-${system}.tar.xz
fi
tar xJf ${prefix}-${major}.${minor}-${build}-${system}.tar.xz

cd ${prefix}-${major}.${minor}-${build}-${system}

echo Extracting AMDGPU-PRO OpenCL driver files...
#ar x "../${prefix}-${major}.${minor}-${build}-${system}/clinfo-amdgpu-pro_${major}.${minor}-${build}_amd64.deb"
#tar xJf data.tar.xz
#ar x "../${prefix}-${major}.${minor}-${build}-${system}/clinfo-amdgpu-pro_${major}.${minor}-${build}_i386.deb"
#tar xJf data.tar.xz
ar x "../${prefix}-${major}.${minor}-${build}-${system}/comgr-amdgpu-pro_${libamd_comgrver}-${build}_amd64.deb"
tar xJf data.tar.xz
#ar x "../${prefix}-${major}.${minor}-${build}-${system}/comgr-amdgpu-pro-dev_${libamd_comgrver}-${build}_amd64.deb"
#tar xJf data.tar.xz
ar x "../${prefix}-${major}.${minor}-${build}-${system}/hip-rocr-amdgpu-pro_${major}.${minor}-${build}_amd64.deb"
tar xJf data.tar.xz
ar x "../${prefix}-${major}.${minor}-${build}-${system}/hsa-runtime-rocr-amdgpu_${libhsa_ver}-${build}_amd64.deb"
tar xJf data.tar.xz
#ar x "../${prefix}-${major}.${minor}-${build}-${system}/hsa-runtime-rocr-amdgpu-dev_${libhsa_ver}-${build}_amd64.deb"
#tar xJf data.tar.xz
ar x "../${prefix}-${major}.${minor}-${build}-${system}/hsakmt-roct-amdgpu_1.0.9-${build}_amd64.deb"
tar xJf data.tar.xz
#ar x "../${prefix}-${major}.${minor}-${build}-${system}/hsakmt-roct-amdgpu-dev_1.0.9-${build}_amd64.deb"
#tar xJf data.tar.xz
ar x "../${prefix}-${major}.${minor}-${build}-${system}/libdrm-amdgpu-amdgpu1_${libdrmver}-${build}_amd64.deb"
tar xJf data.tar.xz
ar x "../${prefix}-${major}.${minor}-${build}-${system}/libdrm-amdgpu-amdgpu1_${libdrmver}-${build}_i386.deb"
tar xJf data.tar.xz
ar x "../${prefix}-${major}.${minor}-${build}-${system}/libdrm-amdgpu-common_1.0.0-${build}_all.deb"
tar xJf data.tar.xz
ar x "../${prefix}-${major}.${minor}-${build}-${system}/opencl-orca-amdgpu-pro-icd_${major}.${minor}-${build}_amd64.deb"
tar xJf data.tar.xz
ar x "../${prefix}-${major}.${minor}-${build}-${system}/opencl-orca-amdgpu-pro-icd_${major}.${minor}-${build}_i386.deb"
tar xJf data.tar.xz
ar x "../${prefix}-${major}.${minor}-${build}-${system}/opencl-rocr-amdgpu-pro_${major}.${minor}-${build}_amd64.deb"
tar xJf data.tar.xz
#ar x "../${prefix}-${major}.${minor}-${build}-${system}/opencl-rocr-amdgpu-pro-dev_${major}.${minor}-${build}_amd64.deb"
#tar xJf data.tar.xz
ar x "../${prefix}-${major}.${minor}-${build}-${system}/rocm-device-libs-amdgpu-pro_1.0.0-${build}_amd64.deb"
tar xJf data.tar.xz
ar x "../${prefix}-${major}.${minor}-${build}-${system}/vulkan-amdgpu-pro_${major}.${minor}-${build}_amd64.deb"
tar xJf data.tar.xz
ar x "../${prefix}-${major}.${minor}-${build}-${system}/vulkan-amdgpu-pro_${major}.${minor}-${build}_i386.deb"
tar xJf data.tar.xz

# Remove target directory
echo Remove target directory.
rm -r /opt/amdgpu &>/dev/null
rm -r /opt/amdgpu-pro &>/dev/null

# Remove old version
rm ${shared32}/libdrm_amdpro.so.1
rm ${shared32}/libdrm_amdpro.so.1.0.0
rm ${shared32}/libamdocl-orca32.so

rm ${shared64}/libdrm_amdpro.so.1
rm ${shared64}/libdrm_amdpro.so.1.0.0
rm ${shared64}/libhsakmt.so.1
rm ${shared64}/libhsakmt.so.1.0.6
rm ${shared64}/libamdocl-orca64.so
rm ${shared64}/libamdocl64.so
rm ${shared64}/libamd_comgr.so
rm ${shared64}/libamd_comgr.so.2
rm ${shared64}/libamd_comgr.so.${libamd_comgrver}
rm ${shared64}/libamdhip64.so
rm ${shared64}/libamdhip64.so.4
rm ${shared64}/libamdhip64.so.${libamdhip_ver}-
rm ${shared64}/libhsa-runtime64.so.1
rm ${shared64}/libhsa-runtime64.so.${libhsa_ver}

# Create target directory
echo Create target directory.
mkdir -p ${ids}
mkdir -p ${amd_shared32}
mkdir -p ${amd_shared64}
mkdir -p ${vk_icd}
mkdir -p ${gcn_bitcode}

echo Patch and installing AMDGPU-PRO OpenCL driver...

rm /etc/OpenCL/vendors/amdocl-orca64.icd
rm /etc/OpenCL/vendors/amdocl-orca32.icd
rm /etc/OpenCL/vendors/amdocl64.icd

# For some reasons this directory is not exist on some system
if [ ! -f /etc/OpenCL/vendors ]; then
    echo Directory /etc/OpenCL/vendors is not exist
    echo Creating it...
    mkdir -p /etc/OpenCL/vendors
fi
cp ./etc/OpenCL/vendors/*.icd /etc/OpenCL/vendors

cp ./opt/amdgpu-pro/etc/vulkan/icd.d/*.json ${vk_icd}
cp ./opt/amdgpu/share/libdrm/amdgpu.ids /opt/amdgpu/share/libdrm

cp  ./opt/amdgpu-pro/amdgcn/bitcode/*.bc /opt/amdgpu-pro/amdgcn/bitcode

pushd ./opt/amdgpu/lib/i386-linux-gnu &>/dev/null
rm "libdrm_amdgpu.so.1"
mv "libdrm_amdgpu.so.1.0.0" "libdrm_amdpro.so.1.0.0"
ln -s "libdrm_amdpro.so.1.0.0" "libdrm_amdpro.so.1"
mv "libdrm_amdpro.so.1.0.0" "${shared32}"
mv "libdrm_amdpro.so.1" "${shared32}"
popd &>/dev/null

pushd ./opt/amdgpu/lib/x86_64-linux-gnu &>/dev/null
rm "libdrm_amdgpu.so.1"
mv "libdrm_amdgpu.so.1.0.0" "libdrm_amdpro.so.1.0.0"
ln -s "libdrm_amdpro.so.1.0.0" "libdrm_amdpro.so.1"
mv "libdrm_amdpro.so.1.0.0" "${shared64}"
mv "libdrm_amdpro.so.1" "${shared64}"
mv "libhsakmt.so.1.0.6" "${shared64}"
mv "libhsakmt.so.1" "${shared64}"
popd &>/dev/null

pushd ./opt/amdgpu-pro/lib/i386-linux-gnu &>/dev/null
sed -i "s|libdrm_amdgpu|libdrm_amdpro|g" libamdocl-orca32.so
mv "libamdocl-orca32.so" "${shared32}"
mv "amdvlk32.so.1.0" "${amd_shared32}"
mv "amdvlk32.so" "${amd_shared32}"
popd &>/dev/null

pushd ./opt/amdgpu-pro/lib/x86_64-linux-gnu &>/dev/null
sed -i "s|libdrm_amdgpu|libdrm_amdpro|g" libamdocl-orca64.so
mv "libamdocl-orca64.so" "${shared64}"
mv "libamdocl64.so" "${shared64}"
mv "libamd_comgr.so.${libamd_comgrver}" "${shared64}"
ln -s "libamd_comgr.so.2" "libamd_comgr.so"
mv "libamd_comgr.so.2" "${shared64}"
mv "libamd_comgr.so" "${shared64}"
mv "libcltrace.so" "${amd_shared64}"
mv "amdvlk64.so.1.0" "${amd_shared64}"
mv "amdvlk64.so" "${amd_shared64}"
mv "libamdhip64.so.${libamdhip_ver}-" "${shared64}"
mv "libamdhip64.so.4" "${shared64}"
mv "libamdhip64.so" "${shared64}"
mv "libhsa-runtime64.so.1" "${shared64}"
mv "libhsa-runtime64.so.${libhsa_ver}" "${shared64}"
mv "libhiprtc-builtins.so.4.2" "${amd_shared64}"
popd &>/dev/null

echo "Finished!"

cd ..
echo "Cleaning up"
rm -r ${prefix}-${major}.${minor}-${build}-${system}

echo Done.
