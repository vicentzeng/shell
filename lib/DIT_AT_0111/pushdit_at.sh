#!/bin/bash
adb root
adb remount

#----------DIT so -----------

adb push ./libxditk_AT.so /system/lib/
adb push ./libxditk_ISP.so /system/lib/
adb push ./msgchk.db system/lib/DataSet/ditSCidGen/
adb push ./libxditk_SR.so /system/lib/
adb push ./ParameterDB.db /system/lib/DataSet/ispDB/ParameterDB.db

adb shell setprop persist.asus.audbg 1
adb shell ps|grep medias
