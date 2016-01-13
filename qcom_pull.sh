#!/bin/bash
adb root
cd $(pwd)
mkdir ./lib
rm -r ./lib/*
adb remount

adb pull system/vendor/lib/libchromatix_ov5670_asus_common.so ./lib/
adb pull system/vendor/lib/libchromatix_ov5670_asus_preview_full.so ./lib/
adb pull system/vendor/lib/libchromatix_t4k35_asus_common.so ./lib/
adb pull system/vendor/lib/libchromatix_t4k35_asus_preview_full.so ./lib/
adb pull system/vendor/lib/libchromatix_t4k37_asus_common.so ./lib/
adb pull system/vendor/lib/libchromatix_t4k37_asus_preview_full.so ./lib/
adb pull system/vendor/lib/libmmcamera_t4k35.so ./lib/
adb pull system/vendor/lib/libmmcamera_t4k37.so ./lib/
adb pull system/vendor/lib/libmmcamera_ov5670_q5v41b.so ./lib/

