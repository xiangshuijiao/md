#!/bin/sh
apt-get install psmisc # 安装后才会有killall命令

if [[ "$2" == "" ]]
then
	make_compile_options="MODEL=$1"
else
	make_compile_options="MODEL=$1 SPEC=$2"
fi

rm nohup.out && touch nohup.out && tail -f nohup.out&
nohup make $make_compile_options env_build 
nohup make $make_compile_options boot_build 
nohup make $make_compile_options kernel_build 
nohup make $make_compile_options modules_build 
nohup make $make_compile_options apps_build 
nohup make $make_compile_options cmm -B 
nohup make $make_compile_options fs_build 
nohup make $make_compile_options image_build 


