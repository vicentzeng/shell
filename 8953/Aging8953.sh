# declear
defalut_log_path="/sdcard/camera_sh.log"
. /system/bin/cam_common_inc.sh
. /system/bin/cam_common_inc_special_mode.sh

initAgingBokeh(){
	LOG "Init bokeh mode open camera"
	am start com.asus.camera/.CameraApp &
	sleep 5
	input tap 770 1815	#switch 
}


AgingBokehSwitch(){
	initAgingBokeh
	ReInitModeCall=initAgingBokeh
	#加入while循环拍摄
	i=1;
	sleep 7
	while [ $i -gt 0 ] 
	do 
		#切换拍照
		LOG "第$i次	"
		CPU_info_monitor
		input tap 540 960	#focus
		sleep 1		
		Capture_8953
		sleep 2
		Check_Capture_Suc_Clear $capture_num
		#sleep 1

		((mod=$i%10))
		if [ $mod -eq 2 ]; then
			LOG "to auto "
			input tap 770 1815	#auto
			sleep 2
		fi
		if [ $mod -eq 4 ]; then
			LOG "to dfp "
			input tap 770 1815	#dfp
			sleep 3
		fi
		if [ $mod -eq 6 ]; then
			sleep 6
			input tap 1000 1820	#miniview
			sleep 2
			LOG "to miniView "
			input keyevent KEYCODE_BACK
			sleep 5
		fi
		#if [ $mod -eq 5 ]; then
			#LOG "to dfp "
			#input tap 770 1815	#dfp
			#sleep 3
		#fi
		if [ $mod -eq 9 ]; then
			LOG "to exitCamera"
		#	input keyevent KEYCODE_BACK	#exitCamera
		#	sleep 3
		#	initAgingBokeh #ret bokeh
		fi

		let i+=1
	done
}


AgingBokehCapture(){
	initAgingBokeh
	ReInitModeCall=initAgingBokeh
	#加入while循环拍摄
	i=1;
	sleep 7
	while [ $i -gt 0 ] 
	do 
		#切换拍照
		LOG "第$i次	"
		input tap 540 960	#focus
		sleep 1		
		Capture_8953
		sleep 2
		Check_Capture_Suc_Clear $capture_num
		sleep 1
		let i+=1
	done
}

######################Aging Shell begin#####################
if [ $# -eq 1 ]; then
	if [ $1 = "stop" ]; then
		echo 0 > /sdcard/shell_run
		exit
	fi
	if [ $1 = "single" ]; then
		Aging_SignalCapture
		exit
	fi
	#if [ $1 = "dump" ]; then
	setenforce 0
	sleep 1
	setenforce 0
	LOG "getenforce: $(getenforce)"
	setprop persist.camera.bokehmode.dump 2
	LOG "persist.camera.bokehmode.dump: $(getprop persist.camera.bokehmode.dump)"
	#fi
else
	#if [ $1 = "dump" ]; then
	setenforce 0
	sleep 1
	setenforce 0
	LOG "getenforce: $(getenforce)"
	setprop persist.camera.bokehmode.dump 2
	LOG "persist.camera.bokehmode.dump: $(getprop persist.camera.bokehmode.dump)"
	#fi

fi


common_init
#AgingBokehCapture
AgingBokehSwitch

