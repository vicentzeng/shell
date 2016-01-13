#!/bin/bash

i=1;
while [ $i -gt 0 ]
do
let i+=1
# flash press
echo "flash press"
sendevent /dev/input/event0 3 57 00
sendevent /dev/input/event0 3 53 422
sendevent /dev/input/event0 3 54 24
sendevent /dev/input/event0 3 48 23
sendevent /dev/input/event0 3 50 23
sendevent /dev/input/event0 0 0 0
sendevent /dev/input/event0 3 57 4294967295
sendevent /dev/input/event0 0 0 0
sleep 1
#recording start
echo "recording start"
sendevent /dev/input/event0 3 57 00
sendevent /dev/input/event0 3 53 149
sendevent /dev/input/event0 3 54 818
sendevent /dev/input/event0 3 48 30
sendevent /dev/input/event0 3 50 30
sendevent /dev/input/event0 0 0 0
sendevent /dev/input/event0 3 57 4294967295
sendevent /dev/input/event0 0 0 0
sleep 7
#recording end
echo "recording end"
sendevent /dev/input/event0 3 57 00
sendevent /dev/input/event0 3 53 149
sendevent /dev/input/event0 3 54 818
sendevent /dev/input/event0 3 48 30
sendevent /dev/input/event0 3 50 30
sendevent /dev/input/event0 0 0 0
sendevent /dev/input/event0 3 57 4294967295
sendevent /dev/input/event0 0 0 0
sleep 3
done

