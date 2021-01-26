#!/bin/sh

# 使用方法：宿主机的/etc/crontab添加如下内容
# 0  9    * * *   root    docker exec auto_compile /opt/share_data_folder/4-script/compile_newest_commit.sh
# 0 14    * * *   root    docker exec auto_compile /opt/share_data_folder/4-script/compile_newest_commit.sh

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
# ${12}：使用make编译时额外使用的其他编译参数，比如：-j1指定单线程编译
eval `ssh-agent` && ssh-add
A_function_that_auto_clone_make_copy_image_when_a_new_commit_occurs()
{	
	# No changes needed
	work_path=/opt/bba/compile_newest_commit/$1 
	target_path=/opt/bba/image
	tar_path=/opt/share_data_folder/9-tar
	logfile=/run/jkn.script.$1.log

	# changes needed
	project_name=$2
	branch=$3
	git_clone_command="git clone $4" 
	commit_msg_hook_command=$5
	build_path=$6
	image_path=$7
	image_file_name=$8
	the_file_used_to_check_if_the_compile_was_successful=$9
	MODEL=${10} # 注意，$10 不能获取第十个参数，获取第十个参数需要${10}。当n>=10时，需要使用${n}来获取参数。
	SPEC=${11}
	Compile_parameters=${12}

	# Delete the log file when the log file is greater than 60M
	if [ `ls -l $logfile | awk '{ print $5 }' ` -gt `expr 60 \* 1000 \* 1000` ]
	then  
		rm -rf $logfile
		echo "$logfile大于60M已经被删除清空了..." >> $logfile 2>&1 </dev/null
	fi


	echo -e "\n\n\n\n=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>start `date`" >> $logfile 2>&1 </dev/null

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
			echo "<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=end `date`" >> $logfile 2>&1 </dev/null
			return -1
		else
			echo "$local_commit_date < $remote_commit_date 有最新的提交，需要重新clone编译" >> $logfile 2>&1 </dev/null
		fi
	else
		echo -e "【本地仓库不存在】或者【编译失败了】，下面将自动重新clone代码并编译" >> $logfile 2>&1 </dev/null
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
		echo -e "<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=end `date`" >> $logfile 2>&1 </dev/null
		return -1
	fi
	cd  $work_path/$project_name

	# git checkout branch
	echo git checkout -f $branch >> $logfile 2>&1 </dev/null
	nohup git checkout -f $branch >> $logfile 2>&1 </dev/null

	# 项目定制
	if [ $1 == "PON_trunk_bba_2_5.linux_XC220-G3v_v1" ]
	then
		git apply /opt/share_data_folder/8-gdb/xc220_cmm_cmd_table.patch # git apply patch，such as：cmm gdb debug、open cmm table sh(telnet)
	fi
	if [ $1 == "private_project.master" ]
	then
		rm -rf /usr/local/bin/aclocal-1.13 /usr/local/bin/automake-1.13
		ln -s /opt/trendchip/mips-linux-uclibc-4.3.6-v2/usr/bin/aclocal /usr/local/bin/aclocal-1.13
		ln -s /opt/trendchip/mips-linux-uclibc-4.3.6-v2/usr/bin/automake /usr/local/bin/automake-1.13
		touch $work_path/$project_name/apps/public/ipsectools/*  # 更新时间戳解决MD5_Init编译问题
	fi
	if [ $1 == "bba_3_0_platform.hc220-g5_bba3.0" ]
	then
		nohup git submodule init >> $logfile 2>&1 </dev/null
		nohup git submodule update --init --recursive >> $logfile 2>&1 </dev/null
		nohup git submodule foreach git checkout -f master >> $logfile 2>&1 </dev/null
		nohup git submodule foreach git pull -f >> $logfile 2>&1 </dev/null
	fi
	
	# make
	cd /opt
	ls | grep -v bba | grep -v share_data_folder | xargs rm -rf # 删除交叉编译工具
	mkdir trendchip # 有些项目要求手动创建
	cd $work_path/$project_name/$build_path
	if [[ "$SPEC" == "" ]]
	then
		make_compile_options="MODEL=$MODEL $Compile_parameters"
	else
		make_compile_options="MODEL=$MODEL SPEC=$SPEC $Compile_parameters"
	fi
	echo make $make_compile_options env_build >> $logfile 2>&1 </dev/null
	nohup make $make_compile_options env_build >> $logfile 2>&1 </dev/null
	echo make $make_compile_options boot_build >> $logfile 2>&1 </dev/null
	nohup make $make_compile_options boot_build >> $logfile 2>&1 </dev/null
	echo make $make_compile_options kernel_build >> $logfile 2>&1 </dev/null
	nohup make $make_compile_options kernel_build >> $logfile 2>&1 </dev/null
	echo make $make_compile_options modules_build >> $logfile 2>&1 </dev/null
	nohup make $make_compile_options modules_build >> $logfile 2>&1 </dev/null
	echo make $make_compile_options apps_build >> $logfile 2>&1 </dev/null
	nohup make $make_compile_options apps_build >> $logfile 2>&1 </dev/null
	echo make $make_compile_options cmm -B >> $logfile 2>&1 </dev/null
	nohup make $make_compile_options cmm -B >> $logfile 2>&1 </dev/null
	echo make $make_compile_options fs_build >> $logfile 2>&1 </dev/null
	nohup make $make_compile_options fs_build >> $logfile 2>&1 </dev/null
	echo make $make_compile_options image_build >> $logfile 2>&1 </dev/null
	nohup make $make_compile_options image_build >> $logfile 2>&1 </dev/null

	# Copy the image and create the archive file
	cd $work_path/$project_name/$image_path
	if [ -f $the_file_used_to_check_if_the_compile_was_successful ]
	then
		echo -e "Compile to generate image successfully  `date`" >> $logfile 2>&1 </dev/null

		# Copy the image
		current_time=$(date +%Y_%m_%d_%H_%M_%S)
		destination_folder=$target_path/$current_time-$project_name-$branch-`git rev-parse --short HEAD`-newest
		mkdir -p $destination_folder
		cp -rf $image_file_name $destination_folder
		git log > $destination_folder/git\ log.txt

		# touch pre_make.sh，将项目拷贝到其他位置并进行编译之前需要先执行该脚本创建软链接
		rm -rf $work_path/$project_name/$build_path/pre_make.sh
		echo -e "rm -rf $work_path && mkdir -p $work_path" >> $work_path/$project_name/$build_path/pre_make.sh
		echo -e "ln -s \`cd ../.. && pwd\` $work_path/$project_name" >> $work_path/$project_name/$build_path/pre_make.sh
		chmod 777 $work_path/$project_name/$build_path/pre_make.sh

		# create the archive file
		echo -e "Start compressing the entire project `date`" >> $logfile 2>&1 </dev/null
		cd $tar_path && rm -rf $1.tar
		cd $work_path && tar --warning=no-file-changed -c $project_name > $tar_path/$1.tar
		echo -e "Compression is complete `date`"  >> $logfile 2>&1 </dev/null
	else
		echo Compile to generate image failed >> $logfile 2>&1 </dev/null
	fi

	echo "<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=end `date`" >> $logfile 2>&1 </dev/null
}


# xc220
A_function_that_auto_clone_make_copy_image_when_a_new_commit_occurs \
	"PON_trunk_bba_2_5.linux_XC220-G3v_v1" "PON_trunk_bba_2_5" "linux_XC220-G3v_v1"  \
	"ssh://jiangkainan@172.29.88.140:29418/PON_trunk_bba_2_5" \
	"scp -p -P 29418 jiangkainan@172.29.88.140:hooks/commit-msg PON_trunk_bba_2_5/.git/hooks/" \
	"BBA2.5_platform/build" "EN7528DU_SDK/tplink/output/XC220G3vv1/image" \
	"XC220-G3v(SP)v1_1.1.0_0.8.0_flash.bin XC220-G3v(SP)v1_1.1.0_0.8.0_up_boot.bin rootfs" \
	"XC220-G3v(SP)v1_1.1.0_0.8.0_flash.bin" "XC220G3vv1" "" ""

# hc220
A_function_that_auto_clone_make_copy_image_when_a_new_commit_occurs \
	"bba_3_0_platform.hc220-g5_bba3.0" "bba_3_0_platform" "hc220-g5_bba3.0"  \
	"ssh://jiangkainan@sohoiipf.rd.tp-link.net:29418/access/bba/bba_3_0_platform" \
	"scp -p -P 29418 jiangkainan@sohoiipf.rd.tp-link.net:hooks/commit-msg bba_3_0_platform/.git/hooks/" \
	"platform/build" "platform/targets/HC220-G5V1/THSP" \
	"image/HC220-G5V1_UP.w boot/boot.bin" \
	"image/rootfs" "HC220-G5V1" "THSP" "FORCE_UNSAFE_CONFIGURE=1 -j1 V=s"

# vc220_g3u
A_function_that_auto_clone_make_copy_image_when_a_new_commit_occurs \
	"private_project.master" "private_project" "master"  \
	"git@spcodes.rd.tp-link.net:pengjinfeng/private_project.git" \
	"" \
	"build" "targets" \
	"tprootfs.bin image_VC220_G3U_TT_V1\VC220_G3U_TT_V1_official_v2_0.1.0_0.8.0_flash.*bin" \
	"tprootfs.bin" "VC220_G3U_TT_V1" "" ""
	
	
	
