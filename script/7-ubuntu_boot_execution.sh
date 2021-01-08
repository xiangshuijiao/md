#!/bin/sh

echo 开机时间：`date` > /run/boot_time

docker start auto_compile
docker start opengrok
docker start gitlab
docker start docker1

/etc/init.d/network-manager stop

ifconfig wlx14cf92cc2987 down
rfkill unblock wifi  # 避免SIOCSIFFLAGS: 由于 RF-kill 而无法操作
ip link set wlx14cf92cc2987 name wlan_new # 网卡重命名
iwconfig wlan_new mode Monitor
ifconfig wlan_new up

ifconfig wlx6466b31cf75b down
rfkill unblock wifi  # 避免SIOCSIFFLAGS: 由于 RF-kill 而无法操作
ip link set wlx6466b31cf75b name wlan_old # 网卡重命名
iwconfig wlan_old mode Monitor
ifconfig wlan_old up


while :
do
    chmod -R 777 /home/bba/
    chmod -R 777 /home/share_data_folder/
    sleep 60
done
