#!/bin/bash
rt5572_new_name=wifi_rt5572

# 参数检查
# if [ "$1" = "" ] || [ "$2" = "" ]
if [ "$1" = "" ]
then
echo 请输入要抓包的信道, 不抓包则指定0信道...
exit -1
fi

# 抓包接口没有up时up抓包接口
if [ `ifconfig | grep $rt5572_new_name | wc -l` -eq 0 ]
then
    ifconfig $rt5572_new_name up
fi

# 设置抓包信道
if [ $1 -ne 0 ]
then
    echo -e "\n在网卡$rt5572_new_name信道$1上抓包"
    iwconfig $rt5572_new_name channel $1
    iwlist   $rt5572_new_name channel 
else
    ifconfig $rt5572_new_name down
fi

# wireshark没有启动时启动wireshark
if [ `ps -aux | grep wireshark | grep -v "grep" | wc -l` -eq 0 ]
then
    wireshark&
fi
