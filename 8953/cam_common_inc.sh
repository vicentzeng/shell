LOG(){
	echo "$(date +%m-%d\ %H:%M:%S) $1"
	#write log to file
	if [ $defalut_log_path ]; then
		echo "$(date +%m-%d\ %H:%M:%S) $1">>$defalut_log_path
	else
		if [ $2 ]; then
			echo "$(date +%m-%d\ %H:%M:%S) $1">>$2
		fi
	fi
}

LOGI(){
	echo "$(date +%m-%d\ %H:%M:%S) $1"
	#write log to file
	if [ $defalut_log_path ]; then
		echo "$(date +%m-%d\ %H:%M:%S) $1">>$defalut_log_path
	else
		if [ $2 ]; then
			echo "$(date +%m-%d\ %H:%M:%S) $1">>$2
		fi
	fi
}


TryCaptureUtilSuc(){
	tryTime=0
	while [ $tryTime -le 5 ] 
	do 
		input tap 540 960	#focus
		sleep 1		
		Capture_8953
		sleep 2
		Check_Capture_Suc_Clear
		if [ $? -eq 0 ]; then
			LOGI "TryCapture_8953 suc."
			return;
		fi
		if [ $tryTime -eq 4 ]; then
			LOGI "TryCapture_8953 fail."
			return;
		fi
		sleep 1
		let tryTime+=1
	done
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
	if [ $(ps|grep $1|wc -l) -eq 0 ]; then
		LOG "$1 not run, get PID fail"
		return 0
	fi

	ps_str=$(ps|grep $1)
	m_pid=${ps_str:10:5}	#sub string
	m_pid=${m_pid/" "/""}	#delete space
	m_pid=${m_pid/" "/""}	#delete space
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

#judged by utime change or not
#IsAsusCamera_Run_Preview_ForeHead(){
#	Update_Pid_info com.asus.camera
#	utime_beg=$camera_app_utime#
#	sleep 3
#	Update_Pid_info com.asus.camera
#	utime_end=$camera_app_utime
#	if [ $utime_end -gt $utime_beg ]; then
#		return 0
#	else
#		return 1;
#	fi
#}

restartAsusCamera(){
	#save log
	storeLog

	if [ $is_restart_camera = 1 ]; then
		am force-stop com.asus.camera
		LOG "Restart(am force-stop) AsusCamera"
		$ReInitModeCall	#restart in this function
		sleep 2
		is_cameraapp_run=$(top -n 1 -m 20 -s cpu -d 0|grep "com.asus.camera"|wc -l)
		if [ $is_cameraapp_run = 0 ]; then
			LOG "Restart fail kill all daemon, mediaserver && AsusCamera"
			camera_app_pid=0
			Update_Pid_info com.asus.camera
			if [ $m_pid -gt 0 ]; then
			kill -9 $camera_app_pid
			fi
			Update_Pid_info mediaserver
			if [ $m_pid -gt 0 ]; then
			kill -9 $camera_app_pid
			fi
			Update_Pid_info mm-qcamera-daemon
			if [ $m_pid -gt 0 ]; then
			kill -9 $camera_app_pid
			fi
			sleep 5
			#start again
			$ReInitModeCall
		else
			LOG "Restart suc!!!"
		fi
	else
		LOG "\n\n\n=============Asuscamera Run unnormally! Stop Script!!!============\n\n\n"
		exit
	fi
}

#mem内存分析,打印内存信息到/sdcard/camera_sh_log/camera_maps文件
MemInfo(){
	if [ $is_dump_mediaserver_ps_info = 1 ]; then
		#echo "$1 dumpsys meminfo: $(dumpsys meminfo mediaserver|grep TOTAL:)">>/sdcard/camera_sh.log
		LOG "dumpsys meminfo: $(dumpsys meminfo|grep "RAM"|grep "Lost RAM:")"

		#echo "$1 top meminfo: $(top -n 1|grep  "medias")"
		LOG "$1 top meminfo: $(top -n 1|grep  "asus.camera")"
		
		LOG "$1 ps_meminfo: $(ps|grep "medias")"
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
		LOG "media_pid$media_pid"
		echo "$(date +%c)">>/sdcard/media_maps/camera_maps_$1$i.log
		echo "$(date +%c)">>/sdcard/media_maps/camera_smaps_$1$i.log
		cat /proc/$media_pid/maps>>/sdcard/media_maps/camera_maps_$1$i.log
		cat /proc/$media_pid/smaps>>/sdcard/media_maps/camera_smaps_$1$i.log
	fi
	}

CPU_info_monitor(){
	max_freq_path=/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
	cur_freq_path=/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
	LOG "CPU max_freq:$(cat $max_freq_path) cur_freq:$(cat $cur_freq_path)"
}

CameraAppInfo_monitor(){
	is_cameraapp_run=$(top -n 1 -m 20 -s cpu -d 0|grep "com.asus.camera"|wc -l) #獲取一次cpu消耗 top20的程序列表，中是否有asuscamera
	if [ $is_cameraapp_run = 0 ]; then
		LOG "AsusCamera not Run"
	is_miniview_run=$(dumpsys activity|grep Run|grep com.asus.miniviewer|wc -l)	#獲取當前運行的activity
	if [ $is_miniview_run = 1 ]; then
		LOG "Miniviewer still Running"
	fi
	fi
}
Check_Capture_Suc_Clear(){
	#check is capturing,连续拍照失败5次，则重新打开AsusCamera App
	Update_Pid_info asus.camera
	picture_num_cur=$(ls /sdcard/DCIM/Camera | wc -l);
	ret=0
	if [ $picture_num_pre = $picture_num_cur ]; then
		is_cameraapp_run=$(top -n 1 -m 20 -s cpu -d 0|grep "com.asus.camera"|wc -l)
		if [ $is_cameraapp_run = 1 ]; then
			let capture_fail_num+=1;
				LOG "/********Capture Miss	happened $capture_fail_num次 *******/"
				if [ $capture_fail_num -eq 4 ]; then
					#restart?
					restartAsusCamera
					#capture_fail_num=0;
				fi
				if [ $continuousInitTimes -gt 5 ]; then
					#exit?
					LOG "Keep restart fail 5 times. Camera can't restart normal. Exit Aging!"
					exit
					#capture_fail_num=0;
				fi
				sleep 1
		else
			LOG "/********CameraApp unexpected goto Background *******/"
			restartAsusCamera
			#capture_fail_num=0;
		fi
		ret=1
	else
		picture_num_pre=$picture_num_cur
		let capture_num+=1;
		capture_fail_num=0;
		continuousInitTimes=0;
		LOG "Capture Suc!	成功拍攝$capture_num次 已拍摄$picture_num_cur张"
		if [ $is_clear_pic = 1 ]; then
			rm -rf /sdcard/DCIM/Camera/*
		fi
		ret=0
	fi

	stat=$(cat /sdcard/shell_run);
	if [ $stat = 0 ]; then
		echo "exit"
		exit
	fi
	return $ret
}

storeLog(){
	Crash_Reason
	tombstone_num=$(ls /data/tombstones/|grep tombstone_|wc -l)
	if [ $tombstone_num -gt 0 ]; then
		let tombstone_times+=1
		LOG "Backtrace detected! Coping tombstone&logcat to /sdcard/camera_sh_log/tombstone$tombstone_times"
		mkdir -p /sdcard/camera_sh_log/tombstone$tombstone_times
		mkdir -p /sdcard/camera_sh_log/tombstone$tombstone_times/tombstone
		mkdir -p /sdcard/camera_sh_log/tombstone$tombstone_times/logcat
		mv /data/tombstones/* /sdcard/camera_sh_log/tombstone$tombstone_times/tombstone/
		cp /data/logcat_log/logcat.txt.01 /sdcard/camera_sh_log/tombstone$tombstone_times/logcat/
		cp /data/logcat_log/logcat.txt /sdcard/camera_sh_log/tombstone$tombstone_times/logcat/
	else
		let commone_fail_times+=1
		LOG "Common fail detected! Coping logcat to /sdcard/camera_sh_log/logcat$commone_fail_times"
		mkdir -p /sdcard/camera_sh_log/logcat$commone_fail_times
		cp /data/logcat_log/logcat.txt.01 /sdcard/camera_sh_log/logcat$commone_fail_times/
		cp /data/logcat_log/logcat.txt /sdcard/camera_sh_log/logcat$commone_fail_times/
	fi
}

touchToOpenCameraApp(){
	input keyevent KEYCODE_HOME
	sleep 3
	input tap  980 1820	#touch CameraApp Icon
}

Exit_StorageFull(){

	storage_info2=$(dumpsys diskstats|grep "Data-Free")
	storage_info2=$(echo ${storage_info2%\% free*})
	storage_info2=$(echo ${storage_info2##* = })

	if [ $storage_info2 = 0 ]; then
		LOG "Storage is less than 1% Free! exit"
		echo 0 > /sdcard/shell_run
		exit
	fi
}

Device_Info_Monitor(){
	CameraAppInfo_monitor
	#CPU_info_monitor
	#MemInfo
	Exit_StorageFull
}

Crash_Reason(){
	sof_count=$(cat /data/logcat_log/logcat.txt|grep -i "SOF fre"|wc -l)
	if [ $sof_count -gt 0 ]; then
		let sof_times+=1
		LOG "SOF detected:$sof_times selinux:$(getenforce)"
		LOG "SOF_dump removed:$(ll /data/misc/camera/sof_freeze_dump.txt)"
		rm /data/misc/camera/sof_freeze_dump.txt
	fi

	#search within 60 seconds, cover 2 minuites
	pre_60s_data=$(date +%m-%d\ %H:%M -d "$(date +%m%d%H)$(($(date +%M)-1))")
	app_crash=$(cat /data/logcat_log/logcat.txt|grep "$pre_60s_data\|$(date +%m-%d\ %H:%M)"|grep -i "force.*asus.*camera")
	if [ $app_crash -gt 0 ]; then
		$((app_crash_times+=1))
		LOG "App_Crash detected:$app_crash_times within 2 minuites"
	fi
}

common_init(){
LOG "Aging Begin"
mkdir -p /sdcard/media_maps
echo 1 > /sdcard/shell_run
mkdir -p /sdcard/camera_sh_log
capture_num=0
capture_fail_num=0
continuousInitTimes=0
retry_check=0
picture_num_pre=$(ls /sdcard/DCIM/Camera | wc -l);
ReInitModeCall=touchToOpenCameraApp

#globle camera info
is_cameraapp_run=1
camera_app_pid=0
camera_app_oom_score=0
camera_app_utime=0

#fail info
commone_fail_times=0
tombstone_times=$(ls /data/tombstones/ | wc -l);
sof_times=0
app_crash_times=0
#config
is_dump_mediaserver_ps_info=1
is_dump_mediaserver_maps=0
is_restart_camera=1
is_clear_pic=0
sleep_s_after_capture=0	#test
}

