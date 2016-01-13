#!/bin/bash
adb root
cd $(pwd)
adb remount
adb pull /sdcard/DCIM/Camera/ ./
adb shell rm /sdcard/DCIM/Camera/*
