# declear
defalut_log_path="/sdcard/camera_sh.log"
. /system/bin/cam_common_inc.sh
. /system/bin/cam_common_inc_special_mode.sh

initAgingBokeh(){
	LOG "Init bokeh mode open camera"
	am start com.asus.camera/.CameraApp
	sleep 5
	input tap 540 95
}

AgingBokeh(){
	initAgingBokeh
	ReInitModeCall=initAgingBokeh
	#加入while循环拍摄
	i=1;
	sleep 7
	input tap 540 95
	sleep 2
	while [ $i -gt 0 ] 
	do 
		#切换拍照
		LOG "第$i次	"
		#MemInfo
		input tap 540 960
		sleep 2		
		Capture_8953
		sleep 4
		#sleep $sleep_s_after_capture
		Check_Capture_Suc_Clear $capture_num
		#input tap 540 1880
		sleep 2
		let i+=1
	done
}

######################Aging Shell begin#####################
if [ $# -eq 1 ]; then
	if [ $1 = "stop" ]; then
		echo 0 > /sdcard/shell_run
		exit
	fi
fi
common_init
AgingBokeh


