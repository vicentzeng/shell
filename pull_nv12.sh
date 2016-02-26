#!/bin/bash
adb root
cd $(pwd)
mkdir ./nv12
rm -r ./nv12/*.nv12
rm -r ./nv12/*.pnm

adb remount
adb shell ls /data/misc/camera/|grep .nv12
adb pull /data/misc/camera/ ./nv12/pic/
adb shell rm /data/misc/camera/*
