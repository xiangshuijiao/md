#!/bin/sh
logfile=/run/boot_time
echo 开机时间：`date` >> $logfile 2>&1

docker start auto_compile
docker start opengrok
docker start gitlab
docker start docker1

# 抓包网卡重命名
rt5572_old_name=wlx6466b31cf75b
rt5572_new_name=wifi_rt5572
/etc/init.d/network-manager stop
ifconfig $rt5572_old_name down
rfkill unblock wifi  # 避免SIOCSIFFLAGS: 由于 RF-kill 而无法操作
ip link set $rt5572_old_name name $rt5572_new_name # 网卡重命名
iwconfig $rt5572_new_name mode Monitor
ifconfig $rt5572_new_name up
ifconfig $rt5572_new_name down


# 提前解压成功编译的被压缩的项目，后续使用只需要mv过去不需要重新解压一遍
# $1 独一无二的项目ID（项目名加branch）
# $2 项目名
Unzip_successfully_compiled_compressed_projects()
{
    cd /home/share_data_folder/9-tar
    # 预处理：有压缩包更新提醒文件时，kill掉正在运行的tar解压进程、删掉旧的解压文件，强制重新解压
    if [ -f "$1.have_update" ]
    then
        rm -rf $1.have_update
        ps aux | grep "$1.tar -C" | grep -v grep | awk '{ print $2 }' | xargs kill
        ps aux | grep "$1.tar -C" >> $logfile 2>&1
        rm -rf $2
    fi
 
    # 项目不存在且压缩包存在则进行解压
    if [ ! -d "$2" ] && [ -f $1.tar ]
    then
        echo "目录$2不存在，将会解压$1.tar..."  >> $logfile 2>&1
        touch  $1.unzipping && \
        tar -xf $1.tar -C ./ && \
        rm -rf $1.unzipping &
    fi

    # tar解压进程不存在且文件$1.unzipping存在则说明解压失败，比如解压过程中重启了电脑，此时需要重新解压
    sleep 5
    if [ -f $1.tar ] && [ `ps -aux | grep "$1.tar -C" | grep -v "grep" | wc -l` -eq 0 ] && [ -f $1.unzipping ]
    then
        echo "上一次解压失败，将会重新解压$1.tar..."  >> $logfile 2>&1
        rm -rf $2
        touch  $1.unzipping && \
        tar -xf $1.tar -C ./ && \
        rm -rf $1.unzipping &  
    fi
}


count=0
while :
do
    # 当抓包接口up且wireshark进程连续5分钟不存在也即没有在抓包时就down掉抓包接口，避免抓包网卡过度工作
    echo "\n\n\n\n\n`date` 监控抓包网卡是否需要关闭"  >> $logfile 2>&1
    if [ `ifconfig | grep $rt5572_new_name | wc -l` -ne 0 ]
    then
        if [ `ps -aux | grep wireshark | grep -v "grep" | wc -l` -ne 0 ]
        then 
            count=0
        else
            count=`expr $count + 1` 
        fi

        if [ $count -gt 5 ]
        then   
            ifconfig $rt5572_new_name down
            count=0
        fi
    else
        count=0
    fi

    # 对指定目录进行git备份，必须要指定用户运行git，因为： 
    # rc.local开机自启脚本不在任何一个用户上运行所以不能配置email、name从而导致commit失败
    echo "`date` 备份 8-gdb..."  >> $logfile 2>&1
    su - root -c "cd /home/share_data_folder/8-gdb && git add -A && git commit -m \"`date`\"" >> $logfile 2>&1
    echo "`date` 备份 4-script..."  >> $logfile 2>&1
    su - root -c "cd /home/share_data_folder/4-script && git add -A && git commit -m \"`date`\"" >> $logfile 2>&1

    # 提前解压成功编译的被压缩的项目，后续使用只需要mv过去不需要重新解压一遍
    Unzip_successfully_compiled_compressed_projects "PON_trunk_bba_2_5.linux_XC220-G3v_v1" "PON_trunk_bba_2_5"
    Unzip_successfully_compiled_compressed_projects "BBA_2_5_Platform_BCM.EX220_USSP_v1.2" "BBA_2_5_Platform_BCM"
    Unzip_successfully_compiled_compressed_projects "bba_3_0_platform.hc220-g5_bba3.0" "bba_3_0_platform"
    Unzip_successfully_compiled_compressed_projects "private_project.master" "private_project"
    
    # 指定目录赋777权限
    echo "`date` 赋目录777权限"  >> $logfile 2>&1
    chmod -R 777 /home/bba/
    chmod -R 777 /home/share_data_folder/

    # gitlab docker没有启动时启动gitlab docker
    if [ `docker ps | grep gitlab | wc -l` -eq 0 ]
    then
        docker start gitlab
    fi

    sleep 60
done
