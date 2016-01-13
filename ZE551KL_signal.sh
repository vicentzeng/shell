i=1;
while [ $i -gt 0 ] 
do 
let i+=1
echo "switch time $i"
am start com.asus.camera/.CameraApp
sleep 2
sendevent /dev/input/event0 1 330 1
sendevent /dev/input/event0 3 58 94
sendevent /dev/input/event0 3 48 5
sendevent /dev/input/event0 3 53 550
sendevent /dev/input/event0 3 54 1800
sleep 2
sendevent /dev/input/event0 3 360 50
sendevent /dev/input/event0 0 0 0
sendevent /dev/input/event0 1 330 0
sendevent /dev/input/event0 0 0 0
sleep 2
done
