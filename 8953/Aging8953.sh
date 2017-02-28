# declear

LOG(){
	echo "$(date +%m-%d\ %H:%M:%S) $1"
	echo "$(date +%m-%d\ %H:%M:%S) $1">>/sdcard/camera_sh.log
}


Panel_Check(){
	#判断551/550 ret=0:550 ret=1:551
	panel=0;
	cat /proc/aphd|grep -q 0
		if [ $? -eq 0 ]; then
		panel=1;
	fi
	return $panel
}

# $1 pid_name
#/proc/pid/stat utime=1587该任务在用户态运行的时间
#/proc/pid/oom_score

Update_Pid_info(){
	camera_app_pid=0
	m_pid=0
		ps_str=$(ps|grep $1)
		m_pid=${ps_str:10:5}	#sub string
		m_pid=${m_pid/" "/""}	#delete space
		m_pid=${m_pid/" "/""}	#delete space
		#echo "pid:$m_pid"
	if [ $m_pid -gt 0 ]; then
		camera_app_pid=$m_pid
		ps_stat_str=$(cat /proc/$camera_app_pid/stat)
		ps_stat_str=$(echo ${ps_stat_str#* * * * * * * * * * * * * *})	#delete left
		ps_stat_str=$(echo ${ps_stat_str%% *})	#delete right
		#echo "utime:$ps_stat_str"
		camera_app_oom_score=$(cat /proc/$camera_app_pid/oom_score)
		#echo "oom_score:$camera_app_oom_score"
		camera_app_utime=$ps_stat_str
	fi

	return $m_pid
}


restartAsusCamera(){
	if [ $is_restart_camera = 1 ]; then
		am force-stop com.asus.camera
		echo "Restart(am force-stop) AsusCamera  Time:$(date +%c) "
		echo "Restart(am force-stop) AsusCamera  Time:$(date +%c) ">>/sdcard/camera_sh.log
		am start com.asus.camera/.CameraApp>>/sdcard/camera_sh.log
		Update_Pid_info com.asus.camera
		sleep 7
		input tap 540 95
		echo "restartAsusCamera input tap 540 95"
		IsAsusCamera_Run_Preview_ForeHead
		if [ $? = 1 ]; then
			echo "restart fail Time:$(date +%c)"
			kill -9 $camera_app_pid
			Update_Pid_info mediaserver
			kill -9 $camera_app_pid
			Update_Pid_info mm-qcamera-daemon
			kill -9 $camera_app_pid
			sleep 5
			#start again
			am start com.asus.camera/.CameraApp>>/sdcard/camera_sh.log
			sleep 5
			input tap 540 95
		fi
		let aging_fail_num+=1
	else
		echo "\n\n\n=============Asuscamera Run unnormally! Stop Script!!!============\n\n\n"
		exit
	fi
}

IsAsusCamera_Run_Preview_ForeHead(){
	exit=$(ps|grep com.asus.camera|wc -l)
	if [ exit = 0 ]; then
		echo "cameraapp err exit completed."
		return 1;
	fi
	Update_Pid_info com.asus.camera
	if [ $camera_app_utime -gt $pre_camera_app_utime ]; then
		pre_camera_app_utime=$camera_app_utime
		return 0
	else
		echo "cameraapp err exit in background."
		echo "camera_app_utime:$camera_app_utime pre_camera_app_utime:$pre_camera_app_utime"
		pre_camera_app_utime=0
		return 1;
	fi
}

#mem内存分析,打印内存信息到/sdcard/camera_sh_log/camera_maps文件
MemInfo(){
	if [ $is_dump_mediaserver_ps_info = 1 ]; then
		#echo "$1 dumpsys meminfo: $(dumpsys meminfo mediaserver|grep TOTAL:)">>/sdcard/camera_sh.log
		echo "dumpsys meminfo: $(dumpsys meminfo|grep "RAM")">>/sdcard/camera_sh.log
		
		#echo "$1 top meminfo: $(top -n 1|grep  "medias")"
		#echo "$1 top meminfo: $(top -n 1|grep  "camera")"
		#echo "$1 top meminfo: $(top -n 1|grep medias)">>/sdcard/camera_sh.log
		
		echo "$1 ps_meminfo: $(ps|grep "medias")"
		echo "$1 ps_meminfo: $(ps|grep "medias")">>/sdcard/camera_sh.log
		echo "$1 ps_meminfo: $(ps|grep "camera")">>/sdcard/camera_sh.log
		#echo "$1 ps_meminfo: $(ps|grep com.asus.atd.devicecheck)">>/sdcard/camera_sh.log

		#procrank
		#echo "$1 procrank: $(procrank|grep "medias")"
		#echo "$1 procrank: $(procrank|grep "camera")"
		#echo "$1 procrank: $(procrank)">>/sdcard/camera_sh.log	#spend 5s
		#echo "$1 procrank: $(procrank|grep "camera")">>/sdcard/camera_sh.log	#spend 5s
	fi
	if [ $is_dump_mediaserver_maps = 1 ]; then
		ps_str=$(ps|grep medias)
		media_pid=${ps_str:10:5}
		media_pid=${media_pid/" "/""}
		media_pid=${media_pid/" "/""}
		echo "media_pid$media_pid"
		echo "$(date +%c)">>/sdcard/media_maps/camera_maps_$1$i.log
		echo "$(date +%c)">>/sdcard/media_maps/camera_smaps_$1$i.log
		cat /proc/$media_pid/maps>>/sdcard/media_maps/camera_maps_$1$i.log
		cat /proc/$media_pid/smaps>>/sdcard/media_maps/camera_smaps_$1$i.log
	fi
	}

Check_Capture_Suc(){
	#check is capturing,连续拍照失败5次，则重新打开AsusCamera App
	picture_num_cur=$(ls /sdcard/DCIM/Camera | wc -l);
	if [ $picture_num_cur = $1 ]; then
		echo "/********Capture Err Stoped!	已拍摄$picture_num_cur张	Time:$(date +%c) *******/">>/sdcard/camera_sh.log
			let capture_fail_num+=1;
			if [ $capture_fail_num -eq 3 ]; then
				echo "Restart(am force-stop) AsusCamera App failtime:$capture_fail_num   Time:$(date +%c) ">>/sdcard/camera_sh.log
				if [ $is_restart_camera = 1 ]; then
				#am force-stop com.asus.camera
				am start com.asus.camera/.CameraApp>>/sdcard/camera_sh.log
				fi
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
	Update_Pid_info asus.camera
	picture_num_cur=$(ls /sdcard/DCIM/Camera | wc -l);
	ret=0
	if [ $picture_num_pre = $picture_num_cur ]; then
		IsAsusCamera_Run_Preview_ForeHead
		if [ $? = 0 ]; then
			let capture_fail_num+=1;
				echo "/********Capture Miss	happened $capture_fail_num次 Time:$(date +%c) *******/"
				echo "/********Capture Miss	happened $capture_fail_num次	Time:$(date +%c) *******/">>/sdcard/camera_sh.log
				if [ $capture_fail_num -eq 3 ]; then
					#save log
					errlogdir=$(date "+%Y-%m-%d--%H%M%S")
					#mkdir /sdcard/camera_sh_log/$errlogdir
					#echo "mkdir errlogdir:$errlogdir"
					#echo "mkdir errlogdir:$errlogdir">>/sdcard/camera_sh.log
					#cp /data/logcat_log/logcat.txt /sdcard/camera_sh_log/$errlogdir/
					#cp /data/logcat_log/logcat.txt.01 /sdcard/camera_sh_log/$errlogdir/

					#restart?
					restartAsusCamera
					capture_fail_num=0;
				fi
				sleep 1
		else
			restartAsusCamera
		fi
		ret=1
	else
		picture_num_pre=$picture_num_cur
		let capture_num+=1;
		capture_fail_num=0;
		echo "Capture Suc!	已拍摄$capture_num张"
		echo "Capture Suc!	已拍摄$capture_num张">>/sdcard/camera_sh.log
		if [ $is_clear_pic = 1 ]; then
			rm -rf /sdcard/DCIM/Camera/*
		fi
		ret=0
	fi

	stat=$(ls /sdcard/ |grep "run"| wc -l);
	echo $stat
	if [ $stat = 0 ]; then
		echo "exit"
		exit
	fi
	return $ret
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
	echo "switch_camera 551"
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
	sleep 2
	while [ $i -gt 0 ] 
	do 
		#切换拍照
		#echo "第$i次	Time:$(date +%c)"
		#echo "第$i次	Time:$(date +%c)">>/sdcard/camera_sh.log
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
	echo "Aging over!!! 一共拍摄$i次 拍摄$picture_num张	结束时间:$(date +%c)">>/sdcard/camera_sh.log
	#保存shell log,在sdcard/camera_sh.log中
}

AgingBokeh(){

	#加入while循环拍摄
	i=1;
	sleep 2
	while [ $i -gt 0 ] 
	do 
		#切换拍照
		#echo "第$i次	Time:$(date +%c)"
		#echo "第$i次	Time:$(date +%c)">>/sdcard/camera_sh.log
		#MemInfo
		input tap 540 960
		sleep 2		
		Capture_8953
		sleep 4
		#input tap 540 1880
		#sleep $sleep_s_after_capture
		#input tap 540 1880
		Check_Capture_Suc_Clear $capture_num
		#input tap 540 1880
		sleep 2
		#input tap 540 1880
		let i+=1
	done

	#打印结束时候已经拍摄照片的张数
	#保存shell log,在sdcard/camera_sh.log中
}

Aging_Switch(){
	#加入while循环拍摄
	i=1;
	while [ $i -gt 0 ] 
	do 
		#切换拍照
		echo "第$i次	fail $aging_fail_num次 Time:$(date +%c)"
		echo "第$i次	fail $aging_fail_num次 Time:$(date +%c)">>/sdcard/camera_sh.log
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
	echo "Aging over!!! 一共拍摄$i次 拍摄$picture_num张	结束时间:$(date +%c)">>/sdcard/camera_sh.log
	#保存shell log,在sdcard/camera_sh.log中
}

Aging_Recording(){
	#加入while循环拍摄
	i=1;
	while [ $i -gt 0 ] 
	do 
		#切换拍照
		#echo "第$i次	Time:$(date +%c)">>/sdcard/camera_sh.log
		echo "第$i次	Time:$(date +%c)"
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
	echo "Aging over!!! 一共拍摄$i次 录影$capture_num次	结束时间:$(date +%c)">>/sdcard/camera_sh.log
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
		echo "第$i次	Time:$(date +%c)">>/sdcard/camera_sh.log
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

Aging_Switch_Camera_Mode(){
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

AgingPrintMemInfo(){
	#加入while循环拍摄
	i=1;
	while [ $i -gt 0 ] 
	do
		let i+=1
		echo "第$i次	Time:$(date +%c)">>/sdcard/camera_sh.log
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
		echo "第$i次	Time:$(date +%c)">>/sdcard/camera_sh.log
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
			echo "第$i次	restart Time:$(date +%c)">>/sdcard/camera_sh.log
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
		echo "第$i次	Time:$(date +%c)">>/sdcard/camera_sh.log
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
			echo "第$i次	restart Time:$(date +%c)">>/sdcard/camera_sh.log
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
		echo "第$i次	Time:$(date +%c)">>/sdcard/camera_sh.log
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
			echo "vicent 第$j次 openCamera Time:$(date +%c)"
			echo "vicent 第$j次 openCamera Time:$(date +%c)">>/sdcard/camera_sh.log
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

######################Aging Shell begin#####################
echo "Aging Begin $(date +%c)"
mkdir /sdcard/media_maps
mkdir /sdcard/run
mkdir /sdcard/camera_sh_log
capture_num=0
capture_fail_num=0
retry_check=0
aging_fail_num=0
picture_num_pre=$(ls /sdcard/DCIM/Camera | wc -l);

#globle camera info
camera_app_pid=0
camera_app_oom_score=0
camera_app_utime=0
pre_camera_app_utime=0

#config
is_dump_mediaserver_ps_info=0
is_dump_mediaserver_maps=0
is_restart_camera=1
is_clear_pic=0
sleep_s_after_capture=0	#test
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

AgingBokeh
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
