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
    su - root -c "cd /home/share_data_folder/8-gdb && git add -A && git commit -m "`date`"" >> $logfile 2>&1

    echo "`date` 备份 4-script..."  >> $logfile 2>&1
    su - root -c "cd /home/share_data_folder/4-script && git add -A && git commit -m "`date`"" >> $logfile 2>&1
    
    # 指定目录赋777权限
    echo "`date` 赋目录777权限"  >> $logfile 2>&1
    chmod -R 777 /home/bba/
    chmod -R 777 /home/share_data_folder/

    sleep 60
done
