# declear

Panel_Check(){
	#判断551/550
	panel=0;
	cat /proc/aphd|grep -q 0
		if [ $? -eq 0 ]; then
		panel=1;
	fi
	return $panel
}

IsAsusCamera_Run(){
	#检查AsusCamera是否关闭 0:run 1:exit
	ps |grep -q com.asus.camera
	if [ $? -eq 0 ]; then
		sleep 2
	   else
	   	echo "Asuscamera 异常退出!	Time:$(date +%c)">>/sdcard/camera_sh.log
	fi
	return $?
}

Check_Capture_Suc(){
	#check is capturing,连续拍照失败5次，则重新打开AsusCamera App
	picture_num_cur=$(ls /sdcard/DCIM/Camera | wc -l);
	if [ $picture_num_cur = $1 ]; then
		echo "/********Capture Err Stoped!	已拍摄$picture_num_cur张	Time:$(date +%c) *******/">>/sdcard/camera_sh.log
			let capture_fail_num+=1;
			if [ $capture_fail_num -eq 5 ]; then
				echo "Restart AsusCamera App	Time:$(date +%c)"
				am start com.asus.camera/.CameraApp>>/sdcard/camera_sh.log
				sleep 3
				capture_fail_num=0;
			fi
		return 1
	    else
		echo "Capture Suc!	已拍摄$picture_num_cur张">>/sdcard/camera_sh.log
		rm -rf /sdcard/DCIM/Camera/*
		capture_num=$picture_num_cur
		capture_fail_num=0;
		return 0
	fi
}

Check_Capture_Suc_Clear(){
		#check is capturing,连续拍照失败5次，则重新打开AsusCamera App
	picture_num_cur=$(ls /sdcard/DCIM/Camera | wc -l);
	if [ $picture_num_cur = 0 ]; then
		echo "/********Capture Err Stoped!	已拍摄$picture_num_cur张	Time:$(date +%c) *******/">>/sdcard/camera_sh.log
			let capture_fail_num+=1;
			if [ $capture_fail_num -eq 5 ]; then
				echo "Restart AsusCamera App	Time:$(date +%c)"
				am start com.asus.camera/.CameraApp>>/sdcard/camera_sh.log
				sleep 3
				capture_fail_num=0;
			fi
		return 1
	    else
		echo "Capture Suc!	已拍摄$capture_num张">>/sdcard/camera_sh.log
		rm -rf /sdcard/DCIM/Camera/*
		let capture_num+=1;
		capture_fail_num=0;
		return 0
	fi
}
#550KL录影键
Recording_550KL_1(){
	if [ $1 -eq 0 ]; then
		input tap 200 1200
	else
		input tap 300 1830
	fi
}

#550KL拍照键
Capture_550KL_1(){
	input tap 360 1180
}

Switch_550KL_1(){
	echo "switch_camera 550"
	input tap 360 90
}

#551拍照键
Capture_551_1(){
	input tap 540 1830
}

Switch_551_1(){
	echo "switch_camera 551"
	input tap 540 127
}

Aging_Switch(){
	#加入while循环拍摄
	i=1;
	while [ $i -gt 0 ] 
	do 
		let i+=1
		#切换拍照
		echo "第$i次	Time:$(date +%c)">>/sdcard/camera_sh.log
		Panel_Check
			if [ $? -eq 0 ]; then
				sleep 4
				Recording_550KL_1
				sleep 5
				Recording_550KL_1
				sleep 6
			    else
			    	Capture_551_1
			    	sleep 1
			    	Switch_551_1
			fi
		IsAsusCamera_Run 
		Check_Capture_Suc $capture_num
		echo $capture_num
		echo $capture_fail_num
	done

	#打印结束时候已经拍摄照片的张数
	echo "Aging over!!! 一共拍摄$i次 拍摄$picture_num张	结束时间:$(date +%c)">>/sdcard/camera_sh.log
	#保存shell log,在sdcard/camera_sh.log中
}

Aging_Recording(){
	#加入while循环拍摄
	i=1;
	while [ $i -gt 0 ] 
	do 
		let i+=1
		#切换拍照
		echo "第$i次	Time:$(date +%c)">>/sdcard/camera_sh.log
		
		Panel_Check
		sleep 4
		Recording_550KL_1 $?
		sleep 10
		Recording_550KL_1 $?
		sleep 4

		IsAsusCamera_Run 
		Check_Capture_Suc_Clear $capture_num
	done

	#打印结束时候已经拍摄照片的张数
	echo "Aging over!!! 一共拍摄$i次 录影$capture_num次	结束时间:$(date +%c)">>/sdcard/camera_sh.log
	#保存shell log,在sdcard/camera_sh.log中
}
######################Aging begin#####################
echo "Aging Begin $(date +%c)"
capture_num=0
capture_fail_num=0
################打开camera, Start Aging####################
am start com.asus.camera/.CameraApp>>/sdcard/camera_sh.log
#Aging_Switch
Aging_Recording



