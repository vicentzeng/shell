#!/bin/bash
adb root
sleep 1
adb remount
adb push ./ZE550KL_signal_dev.sh /system/bin
adb shell chmod 777 /system/bin/ZE550KL_signal_dev.sh
