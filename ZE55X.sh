
#adb shell sendevent /dev/input/event0 1 330 1 //touch
#adb shell sendevent /dev/input/event0 3 54 1220
#adb shell sendevent /dev/input/event0 3 360 50
#adb shell sendevent /dev/input/event0 0 0 0//it must have
#adb shell sendevent /dev/input/event0 1 330 0 //untouch
#adb shell sendevent /dev/input/event0 0 0 0//it must have

# declear
Capture_550KL(){
	#550KL拍照键
	sendevent /dev/input/event0 1 330 1
	sendevent /dev/input/event0 3 58 94
	sendevent /dev/input/event0 3 48 5
	sendevent /dev/input/event0 3 53 330
	sendevent /dev/input/event0 3 54 1220
	sendevent /dev/input/event0 3 360 50
	sendevent /dev/input/event0 0 0 0
	sendevent /dev/input/event0 1 330 0
	sendevent /dev/input/event0 0 0 0
}

Capture_550KL_1(){
	input tap 360 1180
}

Switch_550KL(){
	echo "switch_camera 550"
	sendevent /dev/input/event0 1 330 1
	sendevent /dev/input/event0 3 58 94
	sendevent /dev/input/event0 3 48 5
	sendevent /dev/input/event0 3 53 380
	sendevent /dev/input/event0 3 54 70
	sendevent /dev/input/event0 0 0 0
	sendevent /dev/input/event0 3 58 94
	sendevent /dev/input/event0 3 48 5
	sendevent /dev/input/event0 3 53 381
	sendevent /dev/input/event0 3 54 73
	sendevent /dev/input/event0 0 0 0
	sendevent /dev/input/event0 1 330 0
	sendevent /dev/input/event0 0 0 0
}

Switch_550KL_1(){
	input tap 360 90
}

Capture_551(){
	#551拍照键
	sendevent /dev/input/event0 1 330 1
	sendevent /dev/input/event0 3 58 127
	sendevent /dev/input/event0 3 48 8
	sendevent /dev/input/event0 3 53 521
	sendevent /dev/input/event0 3 54 1830
	sendevent /dev/input/event0 0 0 0
	sendevent /dev/input/event0 1 330 0
	sendevent /dev/input/event0 0 0 0
}

Capture_551_1(){
	input tap 540 1830
}


Switch_551(){
	echo "switch_camera 551"
	sendevent /dev/input/event0 1 330 1
	sendevent /dev/input/event0 3 58 127
	sendevent /dev/input/event0 3 48 8
	sendevent /dev/input/event0 3 53 521
	sendevent /dev/input/event0 3 54 113
	sendevent /dev/input/event0 0 0 0
	sendevent /dev/input/event0 1 330 0
	sendevent /dev/input/event0 0 0 0
}

Switch_551_1(){
	input tap 540 127
}


#picture_num
picture_num=0;
#判断551/550
panel=HD;
cat /proc/aphd|grep -q 0
	if [ $? -eq 0 ]; then
	panel=FHD;
fi
echo "Aging begin panel:$panel	Time:$(date +%c)"



################打开camera, Start Aging####################
am start com.asus.camera/.CameraApp>>/sdcard/camera_sh.log
#加入while循环拍摄
i=1;
j=5;
while [ $i -gt 0 ] 
do 
	let i+=1
	#拍照，切换sleep 2
	echo "第$i次	Time:$(date +%c)">>/sdcard/camera_sh.log

		if [ $panel = HD ]; then
			Capture_550KL_1
			sleep 1
			Switch_550KL_1
		    else
		    	Capture_551_1
		    	sleep 1
		    	Switch_551_1
		fi
	#检查AsusCamera是否关闭
	ps |grep -q com.asus.camera
		if [ $? -eq 0 ]; then
			sleep 2
		   else
		   	echo "Asuscamera 异常退出!	Time:$(date +%c)">>/sdcard/camera_sh.log
			break;
		fi
	#check is capturing,连续拍照失败5次，则退出脚本
	picture_num_cur=$(ls /sdcard/DCIM/Camera | wc -l);
	if [ $picture_num_cur =  $picture_num ]; then
		echo "Capture Err Stoped!	已拍摄$picture_num_cur张	Time:$(date +%c)">>/sdcard/camera_sh.log
		let j-=1;
			if [ $j -le 1 ]; then
				break;
			fi
	    else
		echo "Capture Suc!	已拍摄$picture_num_cur张">>/sdcard/camera_sh.log
		picture_num=$picture_num_cur;
		j=5;
	fi
done

#打印结束时候已经拍摄照片的张数
echo "Aging over!!! 一共拍摄$i次 拍摄$picture_num张	结束时间:$(date +%c)">>/sdcard/camera_sh.log
#保存shell log,在sdcard/camera_sh.log中

