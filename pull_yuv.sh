#!/bin/bash
adb root
cd $(pwd)
mkdir ./yuv
rm -r ./yuv/*
adb remount
adb shell ls /data/|grep .yuv
adb shell mkdir /data/yuv/
adb shell mv /data/*yuv /data/yuv/
adb pull /data/yuv/ ./yuv/
adb shell rm /data/*.yuv
adb shell rm /data/yuv/*.yuv
