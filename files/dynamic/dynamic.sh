#!/sbin/sh

# This file contains parts from the scripts taken from the Open GApps Project by mfonville.
#
# The Open GApps scripts are free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# These scripts are distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# Functions & variables
tmp_path=/tmp/dynamic

file_getprop() { grep "^$2" "$1" | cut -d= -f2; }

rom_build_prop=/system/build.prop

device_architecture="$(file_getprop $rom_build_prop "ro.product.cpu.abilist=")"
# If the recommended field is empty, fall back to the deprecated one
if [ -z "$device_architecture" ]; then
  device_architecture="$(file_getprop $rom_build_prop "ro.product.cpu.abi=")"
fi

is_tablet="$(file_getprop $rom_build_prop "ro.build.characteristics" | grep "tablet")"

# FaceLock
if (echo "$device_architecture" | grep -i "armeabi" | grep -qiv "arm64"); then
  cp -rf $tmp_path/FaceLock/arm/* /system
  cp -rf $tmp_path/FaceLock/vendor/* /system/vendor
elif (echo "$device_architecture" | grep -qi "arm64"); then
  cp -rf $tmp_path/FaceLock/arm64/* /system
  cp -rf $tmp_path/FaceLock/vendor/* /system/vendor
fi

# Libs
if (echo "$device_architecture" | grep -i "armeabi" | grep -qiv "arm64"); then
  cp -rf $tmp_path/Libs/system/lib/* /system/lib
  mkdir -p /system/vendor/lib
  cp -rf $tmp_path/Libs/system/vendor/lib/* /system/vendor/lib
elif (echo "$device_architecture" | grep -qi "arm64"); then
  cp -rf $tmp_path/Libs/system/lib64/* /system/lib64
  mkdir -p /system/vendor/lib
  mkdir -p /system/vendor/lib64
  cp -rf $tmp_path/Libs/system/vendor/lib/* /system/vendor/lib
  cp -rf $tmp_path/Libs/system/vendor/lib64/* /system/vendor/lib64
elif (echo "$device_architecture" | grep -qi "x86"); then
  cp -f $tmp_path/Libs/system/lib/libjni_latinime.so /system/lib
  cp -f $tmp_path/Libs/system/lib/libjni_latinimegoogle.so /system/lib
fi

# PrebuiltGmsCore
if (echo "$device_architecture" | grep -i "armeabi" | grep -qiv "arm64"); then
  cp -rf $tmp_path/PrebuiltGmsCore/arm/* /system
elif (echo "$device_architecture" | grep -qi "arm64"); then
  cp -rf $tmp_path/PrebuiltGmsCore/arm64/* /system
elif (echo "$device_architecture" | grep -qi "x86"); then
  cp -rf $tmp_path/PrebuiltGmsCore/x86/* /system
fi

# SetupWizard
if [ -n "$is_tablet" ]; then
  cp -rf $tmp_path/SetupWizard/tablet/* /system
else
  cp -rf $tmp_path/SetupWizard/phone/* /system
fi

# Velvet
if (echo "$device_architecture" | grep -i "armeabi" | grep -qiv "arm64"); then
  cp -rf $tmp_path/Velvet/arm/* /system
elif (echo "$device_architecture" | grep -qi "arm64"); then
  cp -rf $tmp_path/Velvet/arm64/* /system
elif (echo "$device_architecture" | grep -qi "x86"); then
  cp -rf $tmp_path/Velvet/x86/* /system
fi

# Make required symbolic links
if (echo "$device_architecture" | grep -i "armeabi" | grep -qiv "arm64"); then
  mkdir -p /system/app/FaceLock/lib/arm
  mkdir -p /system/app/LatinIME/lib/arm
  ln -sfn /system/lib/libfacelock_jni.so /system/app/FaceLock/lib/arm/libfacelock_jni.so
  ln -sfn /system/lib/libjni_latinime.so /system/app/LatinIME/lib/arm/libjni_latinime.so
  ln -sfn /system/lib/libjni_latinimegoogle.so /system/app/LatinIME/lib/arm/libjni_latinimegoogle.so
elif (echo "$device_architecture" | grep -qi "arm64"); then
  mkdir -p /system/app/FaceLock/lib/arm64
  mkdir -p /system/app/LatinIME/lib/arm64
  ln -sfn /system/lib64/libfacelock_jni.so /system/app/FaceLock/lib/arm64/libfacelock_jni.so
  ln -sfn /system/lib64/libjni_latinime.so /system/app/LatinIME/lib/arm64/libjni_latinime.so
  ln -sfn /system/lib64/libjni_latinimegoogle.so /system/app/LatinIME/lib/arm64/libjni_latinimegoogle.so
elif (echo "$device_architecture" | grep -qi "x86"); then
  mkdir -p /system/app/LatinIME/lib/x86
  ln -sfn /system/lib/libjni_latinime.so /system/app/LatinIME/lib/x86/libjni_latinime.so
  ln -sfn /system/lib/libjni_latinimegoogle.so /system/app/LatinIME/lib/x86/libjni_latinimegoogle.so
fi