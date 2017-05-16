# declear
defalut_log_path="/sdcard/camera_sh.log"
. /system/bin/cam_common_inc.sh
. /system/bin/cam_common_inc_special_mode.sh

initAgingBokeh(){
	LOG "Init bokeh mode open camera"
	let continuousInitTimes+=1
	#am start com.asus.camera/.CameraApp &
	touchToOpenCameraApp
	CameraAppInfo_monitor
	sleep 3
	LOGI "touch DFP mode"
	input tap 770 1715	#switch
	sleep 2
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
		Device_Info_Monitor
		input tap 540 960	#focus
		sleep 1
		LOG "第$i次"	
		Capture_8953
		sleep 2
		Check_Capture_Suc_Clear
		#sleep 1

		((mod=$i%10))
		if [ $mod -eq 2 ]; then
			LOG "to auto"
			input tap 770 1715	#auto
			sleep 3
		fi
		if [ $mod -eq 4 ]; then
			LOG "to dfp"
			input tap 770 1715	#dfp
			sleep 4
		fi
		if [ $mod -eq 6 ]; then
			sleep 6
			input tap 1000 1720	#miniview
			LOG "to miniView"
			sleep 2
			input keyevent KEYCODE_BACK
			LOG "return to dfp"
			sleep 1
			CameraAppInfo_monitor
			sleep 4
			CameraAppInfo_monitor
		fi
		#if [ $mod -eq 5 ]; then
			#LOG "to dfp "
			#input tap 770 1815	#dfp
			#sleep 3
		#fi
		if [ $mod -eq 9 ]; then
			LOG "to exitCamera"
			input keyevent KEYCODE_BACK	#exitCamera
			sleep 3
			LOG "reopen to dfp"
			initAgingBokeh #ret bokeh
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
		Check_Capture_Suc_Clear
		sleep 1
		let i+=1
	done
}

######################Aging Shell begin#####################
common_init

if [ $# -eq 1 ]; then
	if [ $1 = "-h" ]; then
		echo "arg:\n [-h] help\n [stop]\n [single]:auto single\n [bsignal]:bokeh single"
		exit
	fi
	if [ $1 = "stop" ]; then
		echo 0 > /sdcard/shell_run
		exit
	fi
	if [ $1 = "single" ]; then
		Aging_SignalCapture
		exit
	fi
	if [ $1 = "bsingle" ]; then
		AgingBokehCapture
		exit
	fi
	#if [ $1 = "dump" ]; then
	setenforce 0
	sleep 1
	setenforce 0
	LOG "getenforce: $(getenforce)"
	setprop persist.camera.bokehmode.dump 0
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

#AgingBokehCapture
AgingBokehSwitch

