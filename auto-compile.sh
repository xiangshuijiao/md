#!/bin/sh

# 宿主机的/etc/crontab
# 0  10  * * * root  docker exec docker容器名 docker脚本路径
# 0  18  * * * root  docker exec docker容器名 docker脚本路径

# No changes needed
work_path=/opt/bba/auto_compile 
target_path=/opt/bba/auto_compile/image
logfile=/tmp/jkn.script.auto_compile.log

# changes needed
git_clone_command="git clone ssh://jiangkainan@172.29.88.140:29418/BBA_2_5_Platform_BCM -b EX220_USSP_v1.2" # 注意要加上-b参数指定分支
commit_msg_hook_command="scp -p -P 29418 jiangkainan@172.29.88.140:hooks/commit-msg BBA_2_5_Platform_BCM/.git/hooks/"
project_name=BBA_2_5_Platform_BCM
branch=EX220_USSP_v1.2

build_path=platform/build/
image_path=platform/targets/EX220-G2uV1/USSP/image
image_file_name="EX220-G2u_FLASH.bin.w EX220-G2u_UP_BOOT.bin rootfs boot.bin"
the_file_used_to_check_if_the_compile_was_successful="EX220-G2u_FLASH.bin.w"
MODEL=EX220-G2uV1
SPEC=USSP

# 检查使用的容器是否正确
if [ ! -d /opt/bba/$project_name ]
then
	echo The wrong container was used >> $logfile 2>&1 </dev/null
	exit -1
fi

# auto_compile【本地仓库存在】且【已经成功编译了】且【远程仓库也没有最新的提交】则不需要重新clone代码并编译
if [ -f $work_path/$project_name/$image_path/$the_file_used_to_check_if_the_compile_was_successful ]
then
	cd $work_path/$project_name
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
		exit -1
	elif [ $local_commit_date -eq $remote_commit_date ]; then
		echo "$local_commit_date = $remote_commit_date 没有最新的提交，不需要重新clone编译" >> $logfile 2>&1 </dev/null
		exit -1
	else
		echo "$local_commit_date < $remote_commit_date 有最新的提交，需要重新clone编译" >> $logfile 2>&1 </dev/null
	fi
else
	echo "【本地仓库不存在】或者【编译失败了】" >> $logfile 2>&1 </dev/null
fi


# prepare work
echo "=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>start `date`" >> $logfile 2>&1 </dev/null
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
if [ ! -d $work_path/$project_name ]
then
	echo git clone failed >> $logfile 2>&1 </dev/null
	echo "<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=end `date`" >> $logfile 2>&1 </dev/null
	exit -1
fi
cd  $work_path/$project_name


# git checkout branch
echo git checkout -f $branch >> $logfile 2>&1 </dev/null
nohup git checkout -f $branch >> $logfile 2>&1 </dev/null
cd $build_path

# make
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
	mkdir -p $target_path/$current_time
	cp -rf $image_file_name $target_path/$current_time
else
	echo Compile to generate image failed >> $logfile 2>&1 </dev/null
fi

echo "<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=end `date`" >> $logfile 2>&1 </dev/null
