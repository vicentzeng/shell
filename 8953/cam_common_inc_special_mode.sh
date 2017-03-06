#550KL录影键
Recording_550KL_1(){
	Panel_Check
	if [ $? -eq 0 ]; then
		input tap 200 1200
	else
		input tap 300 1830
	fi
}

Recording_8953(){
	input tap 329 1844
}


#550KL拍照键
Touch_Af_550KL_1(){
	input tap 360 360
}

#8953拍照键
Capture_8953(){
		input tap 540 1830
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
	input tap 540 127
}

Switch_8953_1(){
	input tap 1000 127
}

Switch_8953_dev(){
	input tap 670 127
	input tap 540 127
}



TouchAf_8953_1(){
	input tap 540 900
}

Capture_8953_1(){
	input tap 540 1880
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
		LOG "第$i次	"
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
	LOG "Aging over!!! 一共拍摄$i次 拍摄$picture_num张	结束时间:$(date +%c)"
	#保存shell log,在sdcard/camera_sh.log中
}

Aging_SignalCapture(){
	#加入while循环拍摄
	i=1;
	sleep 2
	while [ $i -gt 0 ] 
	do 
		#切换拍照
		#echo "第$i次	"
		#echo "第$i次	">>/sdcard/camera_sh.log
		#MemInfo
		sleep 2		
		Capture_8953
		sleep 2
		input tap 540 1880
		#sleep $sleep_s_after_capture
		input tap 540 1880
		Check_Capture_Suc_Clear $capture_num
		input tap 540 1880
		sleep 2
		input tap 540 1880
		let i+=1
	done

	#打印结束时候已经拍摄照片的张数
	LOG "Aging over!!! 一共拍摄$i次 拍摄$picture_num张	结束时间:$(date +%c)"
	#保存shell log,在sdcard/camera_sh.log中
}

Aging_Switch(){
	#加入while循环拍摄
	i=1;
	while [ $i -gt 0 ] 
	do 
		#切换拍照
		LOG "第$i次	fail $aging_fail_num次 "

		#meminfo
		#MemInfo
		Capture_8953_1
		input tap 540 1880
		input tap 540 1880
		#Check_Capture_Suc $capture_num
		Check_Capture_Suc_Clear $capture_num
		input tap 540 1880
		input tap 540 1880
		#Switch_8953_1
		Switch_8953_dev
		TouchAf_8953_1
		IsAsusCamera_Run_Preview_ForeHead
		if [ $? -gt 0 ]; then
			restartAsusCamera
			sleep 3
		fi
		let i+=1
	done
	#打印结束时候已经拍摄照片的张数
	LOG "Aging over!!! 一共拍摄$i次 拍摄$picture_num张	结束时间:$(date +%c)"
	#保存shell log,在sdcard/camera_sh.log中
}

Aging_Recording(){
	#加入while循环拍摄
	i=1;
	while [ $i -gt 0 ] 
	do 
		#切换拍照

		LOG "第$i次	"
		#MemInfo BeforeRec
		#sreen shot
		sleep 2
		screencap -p /sdcard/camera_sh_log/$i.png
		sleep 1
		Recording_8953 $?
		sleep 7
		#MemInfo DuringRec
		Recording_8953 $?
		sleep 3
		#Check_Capture_Suc_Clear $capture_num

		#IsAsusCamera_Run_Preview_ForeHead
#		if [ $? -gt 0 ]; then
#			restartAsusCamera
#			sleep 3
#		fi
		let i+=1
	done

	#打印结束时候已经拍摄照片的张数
	LOG "Aging over!!! 一共拍摄$i次 录影$capture_num次	结束时间:$(date +%c)"
	#保存shell log,在sdcard/camera_sh.log中
}

Aging_Front_Recording(){
	#加入while循环拍摄
	i=1;
	#start rec
	Recording_550KL_1
	sleep 3

	while [ $i -gt 0 ] 
	do 
		let i+=1
		#切换拍照
		LOG "第$i次	"
		#MemInfo BeforeRec
		sleep 1
		#start rec
		Capture_550KL_1
		sleep 5
		#stop rec
		Capture_550KL_1
		sleep 2
		IsAsusCamera_Run
		Check_Capture_Suc_Clear $capture_num
	done

	#打印结束时候已经拍摄照片的张数
	LOG "Aging over!!! 一共拍摄$i次 录影$capture_num次	结束时间:$(date +%c)"
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
		LOG "第$i次	"
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
		LOG "第$i次	"
		#sleep 0.1
		Panel_Check
		if [ $? -eq 0 ]; then
			input tap 649 1200
		else
			input tap 986 1830
		fi
		sleep $sleep_s_after_capture
		MemInfo
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
		LOG "第$i次	"
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

Aging_Switch_Camera_Mode(){
	#加入while循环拍摄
	i=1;
	while [ $i -gt 0 ] 
	do
		let i+=1
		LOG "第$i次	"
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

AgingPrintMemInfo(){
	#加入while循环拍摄
	i=1;
	while [ $i -gt 0 ] 
	do
		let i+=1
		LOG "第$i次	"
		MemInfo
		sleep 2
	done
}

Aging_Google_Camera_Switch(){
		#加入while循环拍摄
	am start com.google.android.GoogleCamera/com.android.camera.CameraLauncher>>/sdcard/camera_sh.log
	i=1;
	while [ $i -gt 0 ] 
	do
		let i+=1
		LOG "第$i次	"
		MemInfo
		Panel_Check
		if [ $? -eq 0 ]; then
			#550 capture
			sleep 1
			input tap 362 1150
			#switch
			sleep 2
			input tap 657 972
			input tap 597 982
		else
			sleep 1
		fi
		sleep 2

		#检查Camera是否退出
		Check_Capture_Suc_Clear
		if [ $capture_fail_num -eq 4 ]; then
			LOG "第$i次	restart "
			am start com.google.android.GoogleCamera/com.android.camera.CameraLauncher>>/sdcard/camera_sh.log
		fi
		#am force-stop com.asus.camera
	done
}

Aging_Google_Camera_Signal(){
		#加入while循环拍摄
	am start com.google.android.GoogleCamera/com.android.camera.CameraLauncher>>/sdcard/camera_sh.log
	i=1;
	while [ $i -gt 0 ] 
	do
		let i+=1
		LOG "第$i次	"
		MemInfo
		Panel_Check
		if [ $? -eq 0 ]; then
			#550 capture
			sleep 1
			input tap 362 1150
			#switch
		else
			sleep 1
		fi
		sleep 2
	
		#检查Camera是否退出
		Check_Capture_Suc_Clear
		if [ $capture_fail_num -eq 4 ]; then
			LOG "第$i次	restart "
			am start com.google.android.GoogleCamera/com.android.camera.CameraLauncher>>/sdcard/camera_sh.log
		fi
		#am force-stop com.asus.camera
	done
}

Aging_Burst(){
	i=1;
	sleep 4
	#input tap 782 1814
	sleep 2

	while [ $i -gt 0 ] 
	do
		let i+=1
		LOG "第$i次	"
		MemInfo
			input tap 540 960
			sleep 1
			input swipe 551 1800  551 1800 10000
			sleep 3
			input tap 675 1864	#select all
			sleep 1
			input tap 870 1864	#save all
			#switch
		sleep 5
		#检查Camera是否退出
		Check_Capture_Suc_Clear
	done
}

Aging_Kill_processmedia(){
	i=1;
	sleep 1

	while [ $i -gt 0 ] 
	do
		let i+=1
		ps_str=$(ps|grep android.process.media)
		echo "ps_str"
		m_pid=${ps_str:10:5}
		m_pid=${m_pid/" "/""}
		m_pid=${m_pid/" "/""}

		kill $m_pid
		sleep 1
	done
}

Aging_Preview(){
	i=1;
	sleep 1

	while [ $i -gt 0 ] 
	do
		MemInfo
		input tap 300 300
		sleep 1
	done
}

AgingMonkey(){
	i=1;
	j=0;
	sleep 1

	while [ $i -gt 0 ] 
	do
		monkey --pkg-blacklist-file /sdcard/camera_sh.txt --pct-anyevent 0 --pct-trackball 0 --pct-flip 0 --ignore-crashes --ignore-timeouts --ignore-security-exceptions --monitor-native-crashes --ignore-native-crashes -v -v -v -s 4225 --throttle 1000 5000 
		while [ $j -le 9 ] 
		do
			let j+=1
			am force-stop com.asus.camera
			sleep 1
			am start com.asus.camera/.CameraApp
			sleep 6
			LOG "vicent 第$j次 openCamera "
			#logcat -t 3000|grep -i "CameraApp">>/sdcard/camera_sh.log
			echo "get log beg"
			logcat -d|grep -i "CameraApp">>/sdcard/camera_sh.log
			echo "get log end"
		done
		j=0;
		let i+=1
	done
}

AgingCpFile(){
	echo "AgingCpFile"
	mkdir /sdcard/Download/
	cd /sdcard/Download/
	i=80;
	while [ $i -lt 150 ] 
	do
		mkdir $i
		cp /sdcard/test.iso /sdcard/Download/$i/
		let i+=1
		echo "AgingCpFile=$i"

		mem_Free=$(df /sdcard/|grep sdcard)
		#mem_Free=$(echo ${mem_Free%/sdcard/*})
		#mem_Free=$(echo ${mem_Free% *})
		#mem_Free=$(echo ${mem_Free##*//sdcard/})
		#mem_Free=$(echo ${mem_Free##*//G/})
		mem_Free=$(echo ${mem_Free#* })
		mem_Free=$(echo ${mem_Free#* })
		mem_Free=$(echo ${mem_Free#* })
		mem_Free=$(echo ${mem_Free% *})
		mem_Free=$(echo ${mem_Free%G*})
		mem_Free=$(echo ${mem_Free%.*})
		echo $mem_Free
		if [ $mem_Free -lt 2 ]; then
			echo "suc"
			exit
		fi
	done
}

AgingSleepSreen(){
	i=0
	while [ $i -gt -1 ]
	do
		let i+=1
		input keyevent 26
		sleep 2
		input keyevent 26
		sleep 2
		stat=$(ls /sdcard/ |grep "run"| wc -l);
		echo "$stat:$i"
		if [ $stat = 0 ]; then
			echo "exit"
			exit
		fi
	done

}

#non-ZSL
#Aging_Google_Camera_Switch
#Aging_Google_Camera_Signal

#AsusCamera
################打开camera, Start Aging####################
#am start com.asus.camera/.CameraApp>>/sdcard/camera_sh.log
#AgingPrintMemInfo
#Aging_Preview
#Aging_Switch
#Aging_SignalCapture

#AgingBokeh
#Aging_Recording
#Aging_Front_Recording
#Aging_OpenCamera
#Switch_HDR_SR_550
#Aging_Preview_Select_RS
#Aging_Burst
#Aging_Kill_processmedia
#AgingMonkey
#AgingCpFile
#AgingSleepSreen

