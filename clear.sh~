#!/bin/bash
adb root
adb remount
adb shell rm -rf /sdcard/DCIM/
adb shell rm /data/*.nv12
adb shell rm /data/nv12/*.nv12
adb shell rm /data/*.yuv
adb shell rm /data/yuv/*.yuv
adb shell setprop camera.hal.debug 131
