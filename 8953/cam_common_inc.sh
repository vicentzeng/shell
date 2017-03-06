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
		LOG "Restart(am force-stop) AsusCamera"
		$ReInitModeCall
		IsAsusCamera_Run_Preview_ForeHead
		if [ $? = 1 ]; then
			LOG "Restart fail kill all daemon, mediaserver && AsusCamera"
			kill -9 $camera_app_pid
			Update_Pid_info mediaserver
			kill -9 $camera_app_pid
			Update_Pid_info mm-qcamera-daemon
			kill -9 $camera_app_pid
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

#judged by utime change or not
IsAsusCamera_Run_Preview_ForeHead(){
	Update_Pid_info com.asus.camera
	utime_beg=$camera_app_utime
	sleep 3
	Update_Pid_info com.asus.camera
	utime_end=$camera_app_utime
	if [ $utime_end -gt $utime_beg ]; then
		return 0
	else
		return 1;
	fi
}

#mem内存分析,打印内存信息到/sdcard/camera_sh_log/camera_maps文件
MemInfo(){
	if [ $is_dump_mediaserver_ps_info = 1 ]; then
		#echo "$1 dumpsys meminfo: $(dumpsys meminfo mediaserver|grep TOTAL:)">>/sdcard/camera_sh.log
		LOG "dumpsys meminfo: $(dumpsys meminfo|grep "RAM")"

		#echo "$1 top meminfo: $(top -n 1|grep  "medias")"
		#echo "$1 top meminfo: $(top -n 1|grep  "camera")"
		#echo "$1 top meminfo: $(top -n 1|grep medias)">>/sdcard/camera_sh.log
		
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
		echo "media_pid$media_pid"
		echo "$(date +%c)">>/sdcard/media_maps/camera_maps_$1$i.log
		echo "$(date +%c)">>/sdcard/media_maps/camera_smaps_$1$i.log
		cat /proc/$media_pid/maps>>/sdcard/media_maps/camera_maps_$1$i.log
		cat /proc/$media_pid/smaps>>/sdcard/media_maps/camera_smaps_$1$i.log
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
				LOG "/********Capture Miss	happened $capture_fail_num次  *******/"
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

common_init(){
LOG "Aging Begin"
mkdir -p /sdcard/media_maps
echo 1 > /sdcard/shell_run
mkdir -p /sdcard/camera_sh_log
capture_num=0
capture_fail_num=0
retry_check=0
picture_num_pre=$(ls /sdcard/DCIM/Camera | wc -l);
ReInitModeCall="am start com.asus.camera/.CameraApp"

#globle camera info
camera_app_pid=0
camera_app_oom_score=0
camera_app_utime=0
#config
is_dump_mediaserver_ps_info=0
is_dump_mediaserver_maps=0
is_restart_camera=1
is_clear_pic=0
sleep_s_after_capture=0	#test
}
