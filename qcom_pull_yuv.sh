#!/bin/bash
adb root
cd $(pwd)
mkdir ./yuv
rm -r ./yuv/*
adb remount
adb shell ls /data/|grep .yuv

adb pull /data/misc/camera/ ./yuv/
adb shell rm /data/misc/camera/*.yuv
