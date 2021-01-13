#!/bin/sh

echo 开机时间：`date` > /run/boot_time

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
    chmod -R 777 /home/bba/
    chmod -R 777 /home/share_data_folder/

    # 当抓包接口up且wireshark进程连续5分钟不存在也即没有在抓包时就down掉抓包接口，避免抓包网卡过度工作
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

    sleep 60
done
