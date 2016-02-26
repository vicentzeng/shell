# declear

Panel_Check(){
	#判断551/550 ret=0:550 ret=1:551
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
		sleep 0
	   else
	   	echo "Asuscamera 异常退出!	Time:$(date +%c)">>/sdcard/camera_sh.log
	fi
	return $?
}

IsAsusCamera_Run_Preview_ForeHead(){
	#检查AsusCamera是否在前台 0:run 1:exit
	ps |grep -q com.asus.camera
	if [ $? -eq 0 ]; then
		sleep 0
		ps_str=$(ps|grep mm-qcamera-daemon)
		mem_VSS=$(echo ${ps_str%poll_sched*})
		mem_VSS=$(echo ${mem_VSS% *})
		mem_VSS=$(echo ${mem_VSS##* })
		echo $mem_VSS
		if [ $mem_VSS -lt 127288 ]; then
			echo "Asuscamera 异常退出! VSS:$mem_VSS	Time:$(date +%c)">>/sdcard/camera_sh.log
			return 1
		else
			return 0
		fi
	   else
	   	echo "Asuscamera 异常退出!	Time:$(date +%c)">>/sdcard/camera_sh.log
	fi
	return $?
}

#mem内存分析,打印内存信息到/sdcard/camera_sh_log/camera_maps文件
MemInfo(){
	#echo "$1 dumpsys meminfo: $(dumpsys meminfo mediaserver|grep TOTAL:)">>/sdcard/camera_sh.log
	#echo "$1 top meminfo: $(top -n 1|grep medias)"
	#echo "$1 top meminfo: $(top -n 1|grep medias)">>/sdcard/camera_sh.log

	ps_str=$(ps|grep medias)
	media_pid=${ps_str:10:5}
	media_pid=${media_pid/" "/""}
	media_pid=${media_pid/" "/""}
	echo "media_pid$media_pid"
	echo "$(date +%c)">>/sdcard/camera_sh_log/camera_maps_$1$i.log
	echo "$(date +%c)">>/sdcard/camera_sh_log/camera_smaps_$1$i.log
	cat /proc/$media_pid/maps>>/sdcard/camera_sh_log/camera_maps_$1$i.log
	cat /proc/$media_pid/smaps>>/sdcard/camera_sh_log/camera_smaps_$1$i.log
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
	Panel_Check
	if [ $? -eq 0 ]; then
		input tap 200 1200
	else
		input tap 300 1830
	fi
}

#550KL拍照键
Touch_Af_550KL_1(){
	input tap 360 360
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

#切换preview start/stop
Preview_Res_Sel(){
	Panel_Check
	if [ $? -eq 0 ]; then
	#input tap 64 64
	#input swipe 360 640 360 320 5
	input tap 360 780
	input tap 360 780
	else
		input tap 300 1830
	fi
	}

Aging_Preview_Mem(){
	#加入while循环拍摄
	i=1;
	while [ $i -gt 0 ] 
	do 
		let i+=1
		#切换拍照
		echo "第$i次	Time:$(date +%c)">>/sdcard/camera_sh.log
		Panel_Check
			if [ $? -eq 0 ]; then
				MemInfo
				Touch_Af_550KL_1
				sleep 5
			    else
			    	Capture_551_1
			    	sleep 1
			fi
		IsAsusCamera_Run 
		#Check_Capture_Suc $capture_num
	done

	#打印结束时候已经拍摄照片的张数
	echo "Aging over!!! 一共拍摄$i次 拍摄$picture_num张	结束时间:$(date +%c)">>/sdcard/camera_sh.log
	#保存shell log,在sdcard/camera_sh.log中
}

Aging_SignalCapture(){
	#加入while循环拍摄
	i=1;
	while [ $i -gt 0 ] 
	do 
		let i+=1
		#切换拍照
		echo "第$i次	Time:$(date +%c)">>/sdcard/camera_sh.log
		Panel_Check
			if [ $? -eq 0 ]; then
				MemInfo
				Capture_550KL_1
				sleep 1
			    else
			    	Capture_551_1
			    	sleep 1
			fi
		IsAsusCamera_Run 
		Check_Capture_Suc $capture_num
	done

	#打印结束时候已经拍摄照片的张数
	echo "Aging over!!! 一共拍摄$i次 拍摄$picture_num张	结束时间:$(date +%c)">>/sdcard/camera_sh.log
	#保存shell log,在sdcard/camera_sh.log中
}


Aging_Switch(){
	#加入while循环拍摄
	i=1;
	while [ $i -gt 0 ] 
	do 
		let i+=1
		#切换拍照
		echo "第$i次	Time:$(date +%c)">>/sdcard/camera_sh.log
		sleep 1
		Panel_Check
			if [ $? -eq 0 ]; then
			    MemInfo
				Capture_550KL_1
				sleep 1
				Switch_550KL_1
			    else
			    	Capture_551_1
			    	sleep 1
			    	Switch_551_1
			fi
		IsAsusCamera_Run 
		Check_Capture_Suc $capture_num
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
		#MemInfo BeforeRec
		sleep 3
		Recording_550KL_1 $?
		sleep 7 
		#MemInfo DuringRec
		Recording_550KL_1 $?
		sleep 3
		IsAsusCamera_Run
		Check_Capture_Suc_Clear $capture_num
	done

	#打印结束时候已经拍摄照片的张数
	echo "Aging over!!! 一共拍摄$i次 录影$capture_num次	结束时间:$(date +%c)">>/sdcard/camera_sh.log
	#保存shell log,在sdcard/camera_sh.log中
}

Aging_Preview_Select_RS(){
		#加入while循环拍摄
	i=1;
	#input tap 64 64
	#input swipe 360 640 360 320 5
	#input tap 360 780
	#input tap 360 780
	while [ $i -gt 0 ] 
	do
		let i+=1
		echo "第$i次	Time:$(date +%c)">>/sdcard/camera_sh.log
		#Preview_Res_Sel
		input tap 360 522
		sleep 3
		MemInfo
	done
	}

Aging_OpenCamera(){
	#加入while循环拍摄
	i=1;
	input keyevent KEYCODE_BACK
	while [ $i -gt 0 ] 
	do
		let i+=1
		echo "第$i次	Time:$(date +%c)">>/sdcard/camera_sh.log
		#sleep 0.1
		Panel_Check
		if [ $? -eq 0 ]; then
			input tap 649 1200
		else
			input tap 986 1830
		fi
		sleep 1
		input keyevent KEYCODE_BACK
		#am force-stop com.asus.camera
	done
	}

Switch_HDR_SR_550(){
	#加入while循环拍摄
	i=1;
	while [ $i -gt 0 ] 
	do
		let i+=1
		echo "第$i次	Time:$(date +%c)">>/sdcard/camera_sh.log
		Panel_Check
		if [ $? -eq 0 ]; then
			#Auto
			input tap 60 1217
			input tap 225 130			
			#HDR
			#input tap 60 1217
			#input tap 225 307
			sleep 1
			#SR
			input tap 60 1217
			input tap 225 446
		else
			#Auto
			input tap 86 1830
			input tap 355 210
			#SR
			input tap 86 1830
			input tap 316 700
			sleep 1
			#HDR
			#input tap 86 1830
			#input tap 316 421
		fi
		sleep 2
		#检查Camera是否退出
		IsAsusCamera_Run_Preview_ForeHead
		#am force-stop com.asus.camera
	done
	}


######################Aging Shell begin#####################
echo "Aging Begin $(date +%c)"
mkdir /sdcard/camera_sh_log
capture_num=0
capture_fail_num=0
################打开camera, Start Aging####################
am start com.asus.camera/.CameraApp>>/sdcard/camera_sh.log

#Aging_Switch
#Aging_SignalCapture
Aging_Recording
#Aging_OpenCamera
#Switch_HDR_SR_550
#Aging_Preview_Select_RS

