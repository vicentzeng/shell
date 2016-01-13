i=1;
j=1;
while [ $i -gt 0 ] 
do 
let i+=1
adb reboot
launcher=`adb shell ps | grep "com.asus.launcher" | awk '{print $1}'` 
while [ -z "$launcher" ]; do
	 sleep 3
	 launcher=`adb shell ps | grep "com.asus.launcher" | awk '{print $1}'`
done
echo "whole time $i"
sleep 3
adb root
sleep 3
adb remount
adb shell am start com.asus.camera/.CameraApp
sleep 2
#adb shell ./system/bin/brightness &

sleep 2
j=1;
while [ $j -lt 20 ] 
do 
let j+=1
echo "switch time $j"
adb shell sendevent /dev/input/event0 1 330 1
adb shell sendevent /dev/input/event0 3 58 94
adb shell sendevent /dev/input/event0 3 48 5
adb shell sendevent /dev/input/event0 3 53 673
adb shell sendevent /dev/input/event0 3 54 62
adb shell sendevent /dev/input/event0 0 0 0
adb shell sendevent /dev/input/event0 3 58 94
adb shell sendevent /dev/input/event0 3 48 5
adb shell sendevent /dev/input/event0 3 53 674
adb shell sendevent /dev/input/event0 3 54 63
adb shell sendevent /dev/input/event0 0 0 0
adb shell sendevent /dev/input/event0 1 330 0
adb shell sendevent /dev/input/event0 0 0 0
sleep 2
done
#adb shell sendevent /dev/input/event0 3 57 410
#adb shell sendevent /dev/input/event0 1 330 1
#adb shell sendevent /dev/input/event0 3 57 0
#adb shell sendevent /dev/input/event0 3 58 113
#adb shell sendevent /dev/input/event0 3 53 353
#adb shell sendevent /dev/input/event0 3 54 1192
#adb shell sendevent /dev/input/event0 0 0 0
#adb shell sendevent /dev/input/event0 3 48 6
#adb shell sendevent /dev/input/event0 0 0 0
#sleep 2
pid=`adb shell ps |grep com.asus.camera | awk '{print $2}'`

if [ "$pid" == "" ]; then
	echo "find the bug!"
	exit 0
fi
echo "all right!"
adb reboot

done
