# declear
#加入while循环kill
i=1;
j=5;
while [ $i -gt 0 ] 
do 
	#kill $(ps|grep medias |awk '{print $2}')
	#echo "kill mediaserver">>/sdcard/camera_sh.log
	input tap 540 540
	sleep 1
done

