#!/bin/sh

# 宿主机的/etc/crontab
# 0  10  * * * root  docker exec docker容器名 docker脚本绝对路径
# 0  18  * * * root  docker exec docker容器名 docker脚本绝对路径

# $1：独一无二的项目ID（项目名加branch）
# $2：project_name
# $3：branch
# $4：git_clone_command，例如 git@spcodes.rd.tp-link.net:PON/PON_trunk_bba_2_5.git
# $5：commit_msg_hook_command
# $6：build_path
# $7：image_path
# $8：image_file_name
# $9：the_file_used_to_check_if_the_compile_was_successful
# ${10}：MODEL # 注意，$10 不能获取第十个参数，获取第十个参数需要${10}。当n>=10时，需要使用${n}来获取参数。
# ${11}：SPEC
eval `ssh-agent` && ssh-add
A_function_that_auto_clone_make_copy_image_when_a_new_commit_occurs()
{	
	# No changes needed
	work_path=/opt/bba/compile_newest_commit/$1 
	target_path=/opt/bba/image
	logfile=/tmp/jkn.script.$1.log

	# changes needed
	project_name=$2
	branch=$3
	git_clone_command="git clone $4 -b $branch" 
	commit_msg_hook_command=$5
	build_path=$6
	image_path=$7
	image_file_name=$8
	the_file_used_to_check_if_the_compile_was_successful=$9
	MODEL=${10} # 注意，$10 不能获取第十个参数，获取第十个参数需要${10}。当n>=10时，需要使用${n}来获取参数。
	SPEC=${11}
	
	echo "=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>start `date`" >> $logfile 2>&1 </dev/null

	#【本地仓库存在】且【已经成功编译了】且【远程仓库也没有最新的提交】则不需要重新clone代码并编译
	if [ -f $work_path/$project_name/$image_path/$the_file_used_to_check_if_the_compile_was_successful ]
	then
		cd $work_path/$project_name
		git fetch -f
		local_commit_date="git log -1 --format="%at" | xargs -I{} date -d @{} +%Y-%m-%d\ %H:%M:%S"
		local_commit_date=`echo ${local_commit_date} |awk '{run=$0;system(run)}'`
		
		remote_commit_date="git log remotes/origin/`echo $branch` -1 --format="%at" | xargs -I{} date -d @{} +%Y-%m-%d\ %H:%M:%S"
		remote_commit_date=`echo ${remote_commit_date} |awk '{run=$0;system(run)}'`
		
		local_commit_date=`date -d "$local_commit_date" +%s`
		remote_commit_date=`date -d "$remote_commit_date" +%s`
		
		echo local_commit_date=$local_commit_date >> $logfile 2>&1 </dev/null
		echo remote_commit_date=$remote_commit_date >> $logfile 2>&1 </dev/null
		 
		if [ $local_commit_date -gt $remote_commit_date ]; then
			echo "$local_commit_date > $remote_commit_date 一般不会出现这种情况" >> $logfile 2>&1 </dev/null
			return -1
		elif [ $local_commit_date -eq $remote_commit_date ]; then
			echo "$local_commit_date = $remote_commit_date 没有最新的提交，不需要重新clone编译" >> $logfile 2>&1 </dev/null
			return -1
		else
			echo "$local_commit_date < $remote_commit_date 有最新的提交，需要重新clone编译" >> $logfile 2>&1 </dev/null
			echo "<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=end `date`" >> $logfile 2>&1 </dev/null
		fi
	else
		echo "【本地仓库不存在】或者【编译失败了】，下面将自动重新clone代码并编译" >> $logfile 2>&1 </dev/null
	fi


	# prepare work
	mkdir -p $work_path
	cd 		 $work_path
	rm -rf   $work_path/$project_name

	# git clone
	eval `ssh-agent` && ssh-add
	echo $git_clone_command >> $logfile 2>&1 </dev/null
	nohup $git_clone_command >> $logfile 2>&1 </dev/null
	if [[ "$commit_msg_hook_command" != "" ]]
	then
		echo $commit_msg_hook_command  >> $logfile 2>&1 </dev/null
		nohup $commit_msg_hook_command  >> $logfile 2>&1 </dev/null
	fi
	if [ ! -d $work_path/$project_name/.git ]
	then
		echo git clone failed >> $logfile 2>&1 </dev/null
		echo "<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=end `date`" >> $logfile 2>&1 </dev/null
		return -1
	fi
	cd  $work_path/$project_name

	# git checkout branch
	echo git checkout -f $branch >> $logfile 2>&1 </dev/null
	nohup git checkout -f $branch >> $logfile 2>&1 </dev/null

	# make
	cd /opt
	ls | grep -v bba | grep -v share_data_folder | xargs rm -rf # 删除交叉编译工具
	cd $work_path/$project_name/$build_path
	if [[ "$SPEC" == "" ]]
	then
		make_compile_options="MODEL=$MODEL"
	else
		make_compile_options="MODEL=$MODEL SPEC=$SPEC"
	fi
	nohup make $make_compile_options env_build >> $logfile 2>&1 </dev/null
	nohup make $make_compile_options boot_build >> $logfile 2>&1 </dev/null
	nohup make $make_compile_options kernel_build >> $logfile 2>&1 </dev/null
	nohup make $make_compile_options modules_build >> $logfile 2>&1 </dev/null
	nohup make $make_compile_options apps_build >> $logfile 2>&1 </dev/null
	nohup make $make_compile_options cmm -B >> $logfile 2>&1 </dev/null
	nohup make $make_compile_options fs_build >> $logfile 2>&1 </dev/null
	nohup make $make_compile_options image_build >> $logfile 2>&1 </dev/null

	# copy image
	cd $work_path/$project_name/$image_path
	if [ -f $the_file_used_to_check_if_the_compile_was_successful ]
	then
		echo Compile to generate image successfully >> $logfile 2>&1 </dev/null
		current_time=$(date +%Y_%m_%d_%H_%M_%S)
		destination_folder=$target_path/$current_time-$project_name-$branch-`git rev-parse --short HEAD`-newest
		mkdir -p $destination_folder
		cp -rf $image_file_name $destination_folder
		git log > $destination_folder/git\ log.txt
	else
		echo Compile to generate image failed >> $logfile 2>&1 </dev/null
	fi

	echo "<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=end `date`" >> $logfile 2>&1 </dev/null
}

A_function_that_auto_clone_make_copy_image_when_a_new_commit_occurs \
	"PON_trunk_bba_2_5.feature_XC220_mesh" "PON_trunk_bba_2_5" "feature_XC220_mesh"  \
	"git@spcodes.rd.tp-link.net:PON/PON_trunk_bba_2_5.git" \
	"" \
	"BBA2.5_platform/build" "EN7528DU_SDK/tplink/output/XC220G3vv1/image" \
	"XC220-G3v(SP)v1_1.1.0_0.8.0_flash.bin XC220-G3v(SP)v1_1.1.0_0.8.0_up_boot.bin rootfs" \
	"XC220-G3v(SP)v1_1.1.0_0.8.0_flash.bin" "XC220G3vv1" "" 
	
A_function_that_auto_clone_make_copy_image_when_a_new_commit_occurs \
	"PON_trunk_bba_2_5.linux_XC220-G3v_v1" "PON_trunk_bba_2_5" "linux_XC220-G3v_v1"  \
	"git@spcodes.rd.tp-link.net:PON/PON_trunk_bba_2_5.git" \
	"" \
	"BBA2.5_platform/build" "EN7528DU_SDK/tplink/output/XC220G3vv1/image" \
	"XC220-G3v(SP)v1_1.1.0_0.8.0_flash.bin XC220-G3v(SP)v1_1.1.0_0.8.0_up_boot.bin rootfs" \
	"XC220-G3v(SP)v1_1.1.0_0.8.0_flash.bin" "XC220G3vv1" "" 
	
A_function_that_auto_clone_make_copy_image_when_a_new_commit_occurs \
	"BBA_2_5_Platform_BCM.EX220_USSP_v1.2" "BBA_2_5_Platform_BCM" "EX220_USSP_v1.2"  \
	"ssh://jiangkainan@172.29.88.140:29418/BBA_2_5_Platform_BCM" \
	"scp -p -P 29418 jiangkainan@172.29.88.140:hooks/commit-msg BBA_2_5_Platform_BCM/.git/hooks/" \
	"platform/build/" "platform/targets/EX220-G2uV1/USSP/image" \
	"EX220-G2u_FLASH.bin.w EX220-G2u_UP_BOOT.bin rootfs boot.bin" \
	"EX220-G2u_FLASH.bin.w" "EX220-G2uV1" "USSP"
	
	
	
	
