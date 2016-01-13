i=1;
while [ $i -gt 0 ] 
do 
let i+=1
echo "switch time $i"
sleep 2
sendevent /dev/input/event0 1 330 1
sendevent /dev/input/event0 3 58 94
sendevent /dev/input/event0 3 48 5
sendevent /dev/input/event0 3 53 330
sendevent /dev/input/event0 3 54 1220
sendevent /dev/input/event0 0 0 0
sendevent /dev/input/event0 3 58 94
sendevent /dev/input/event0 3 48 5
sendevent /dev/input/event0 3 53 331
sendevent /dev/input/event0 3 54 1220
sendevent /dev/input/event0 0 0 0
sendevent /dev/input/event0 1 330 0
sendevent /dev/input/event0 0 0 0
sleep 3
#pid=`ps |grep com.asus.camera | awk '{print $2}'`
#if [ "$pid" == "" ]; then
#	echo "find the bug!"	
#	exit 0
#fi
sendevent /dev/input/event0 1 330 1
sendevent /dev/input/event0 3 58 94
sendevent /dev/input/event0 3 48 5
sendevent /dev/input/event0 3 53 337
sendevent /dev/input/event0 3 54 1125
sendevent /dev/input/event0 0 0 0
sendevent /dev/input/event0 3 58 94
sendevent /dev/input/event0 3 48 5
sendevent /dev/input/event0 3 53 336
sendevent /dev/input/event0 3 54 1125
sendevent /dev/input/event0 0 0 0
sendevent /dev/input/event0 1 330 0
sendevent /dev/input/event0 0 0 0
sleep 5
done

