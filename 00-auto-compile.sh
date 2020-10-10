#!/bin/sh

# 使用/etc/crontab脚本每天10点、18点各执行一次
# 0  10  * * * root  sudo bash 脚本路径
# 0  18  * * * root  sudo bash 脚本路径

# No changes needed
work_path=/opt/bba/jenkins 
target_path=/opt/bba/image
logfile=/tmp/jkn.script.auto_compile.log
makefile_target="env_build boot_build kernel_build modules_build apps_build  fs_build image_build"

# changes needed
project_name=PON_trunk_bba_2_5
repository=git@spcodes.rd.tp-link.net:PON/PON_trunk_bba_2_5.git
branch=feature_XC220_mesh
build_path=BBA2.5_platform/build
image_path=EN7528DU_SDK/tplink/output/XC220G3vv1/image
image_file_name="XC220-G3v(SP)v1_1.1.0_0.8.0_up_boot.bin XC220-G3v(SP)v1_1.1.0_0.8.0_flash.bin rootfs"
MODEL=XC220G3vv1
SPEC=

echo start >> $logfile 2>&1 </dev/null
date >> $logfile 2>&1 </dev/null

mkdir -p $work_path
cd 		 $work_path
rm -rf   $work_path/$project_name

# git clone
echo git clone $repository -b $branch >> $logfile 2>&1 </dev/null
git clone $repository -b $branch >> $logfile 2>&1 </dev/null
cd  $work_path/$project_name

# git checkout branch
echo git checkout -f $branch >> $logfile 2>&1 </dev/null
git checkout -f $branch >> $logfile 2>&1 </dev/null
cd $build_path

# make
if [[ "$SPEC" == "" ]]
then
	echo nohup make MODEL=$MODEL $makefile_target >> $logfile 2>&1 </dev/null
	nohup make MODEL=$MODEL $makefile_target
else
	echo nohup make MODEL=$MODEL SPEC=$SPEC $makefile_target >> $logfile 2>&1 </dev/null
	nohup make MODEL=$MODEL SPEC=$SPEC $makefile_target
fi

# copy image
current_time=$(date +%Y_%m_%d_%H_%M_%S)
mkdir -p $target_path/$current_time
cd $work_path/$project_name/$image_path
cp -rf $image_file_name $target_path/$current_time

echo end >> $logfile 2>&1 </dev/null
date >> $logfile 2>&1 </dev/null
