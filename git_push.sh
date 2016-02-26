#!/bin/bash

#git remote -v
#git remote add main ssh://172.29.0.92/8916/platform/vendor/qcom/msm8916_64
# git push main HEAD:refs/for/dev/msm8916/asus/a601

echo "========================================="
echo " git_push.sh Script V3.0"
echo "========================================="

up_remote=172.29.0.92

if [ "$#" -eq 0 ];then
	git push
	exit 1
fi

isRepository=false
command="git push"
index=1
for arg in "$@"
do 
	echo "Arg #$index : 	$arg"
	
	let index+=1
	if [ -z "$(echo $arg | grep "-")" ] && [ $isRepository == false ]; then
		isRepository=true
		if [ -n "$(git remote show | grep $arg)" ];then

		projectname_pattern="remote.$arg.projectname"
		echo "projectname_pattern:	$projectname_pattern"
		remote_name=$(git config --list | awk -F "=" '{if($1=="'$projectname_pattern'") print $2}')
		local_remote_url=$(git config --list |grep $projectname_pattern)
		path=$(echo ${local_remote_url#*//*/})
		echo "path:		$echo"
		echo "up_remote:	$up_remote"
		echo "remote_name:	$remote_name"
		remote_url="ssh://$up_remote/$remote_name"

		command_add=$command
		command="$command $remote_url"
		else
			echo "fatal: can not found the remote repository '$arg'"
			exit 1;
		fi
	else
		command="$command $arg"
	fi

done

echo "command_add:	$command_add"
echo "remote_url:	$remote_url"
echo "arg:		$arg"
echo "exe command: 	$command"

#remote_url=ssh://$ip/$path
#command=git push  $remote_url $arg

#$command
#git push main $arg

exit 0





