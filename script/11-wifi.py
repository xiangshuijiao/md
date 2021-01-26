# -*- coding: UTF-8 -*-
import pywifi,time

import requests
api = "https://sc.ftqq.com/SCU148316T10d8251f5f1c430b0c9b971daafc18565ff9e95ed944d.send"
title = u"紧急通知"


#保存包中写义的常量
from pywifi import const
def wifi_connect_status():
    """
    判断本机是否有无线网卡,以及连接状态
    :return: 已连接或存在无线网卡返回1,否则返回0
    """
    #创建一个元线对象
    wifi = pywifi.PyWiFi()

    #取当前机器,第一个元线网卡
    iface = wifi.interfaces()[0] #有可能有多个无线网卡,所以要指定

    #判断是否连接成功
    if iface.status() in [const.IFACE_CONNECTED,const.IFACE_INACTIVE]:
        print('wifi已连接')
        return 1
    else:
        print('wifi未连接')
    return 0

def scan_wifi():
    """
    扫苗附件wifi
    :return: 扫苗结果对象
    """
    #扫苗附件wifi
    wifi = pywifi.PyWiFi()
    iface = wifi.interfaces()[0]

    iface.scan() #扫苗附件wifi
    time.sleep(1)
    basewifi = iface.scan_results()
    for i in basewifi:
        print('wifi扫苗结果:{}'.format(i.ssid)) # ssid 为wifi名称
        print('wifi设备MAC地址:{}'.format(i.bssid))
    return basewifi

def connect_wifi(SSID, PWD):
    wifi = pywifi.PyWiFi()  # 创建一个wifi对象
    ifaces = wifi.interfaces()[0]  # 取第一个无限网卡
    # print(ifaces.name())  # 输出无线网卡名称
    ifaces.disconnect()  # 断开网卡连接
    time.sleep(3)  # 缓冲3秒


    profile = pywifi.Profile()  # 配置文件
    profile.ssid = SSID  # wifi名称
    profile.auth = const.AUTH_ALG_OPEN  # 需要密码
    profile.akm.append(const.AKM_TYPE_WPA2PSK)  # 加密类型
    profile.cipher = const.CIPHER_TYPE_CCMP  # 加密单元
    profile.key = PWD #wifi密码

    ifaces.remove_all_network_profiles()  # 删除其他配置文件
    tmp_profile = ifaces.add_network_profile(profile)  # 加载配置文件

    # 连接
    ifaces.connect(tmp_profile)  

    count = 0
    while ifaces.status() != const.IFACE_CONNECTED  and count < 20 :
        time.sleep(1)  
        count += 1
        print(time.asctime(time.localtime(time.time())) + "----" + str(count) + "----")


    if ifaces.status() == const.IFACE_CONNECTED:
        print("成功连接")
        return True
    else:
        print("连接error")
        ifaces.disconnect()  
        return False

def connect_and_disconnect_wifi(SSID, PWD):
    wifi = pywifi.PyWiFi()  # 创建一个wifi对象
    ifaces = wifi.interfaces()[0]  # 取第一个无限网卡
    print(ifaces.name())  # 输出无线网卡名称
    ifaces.disconnect()  # 断开网卡连接
    time.sleep(3)  # 缓冲3秒


    profile = pywifi.Profile()  # 配置文件
    profile.ssid = SSID  # wifi名称
    profile.auth = const.AUTH_ALG_OPEN  # 需要密码
    profile.akm.append(const.AKM_TYPE_WPA2PSK)  # 加密类型
    profile.cipher = const.CIPHER_TYPE_CCMP  # 加密单元
    profile.key = PWD #wifi密码

    ifaces.remove_all_network_profiles()  # 删除其他配置文件
    tmp_profile = ifaces.add_network_profile(profile)  # 加载配置文件

    # 连接
    ifaces.connect(tmp_profile)  

    count = 0
    while ifaces.status() != const.IFACE_CONNECTED  and count < 20 :
        time.sleep(1)  
        count += 1
        print(time.asctime(time.localtime(time.time())) + "----" + str(count) + "----")

    isok = True
    if ifaces.status() == const.IFACE_CONNECTED:
        print("成功连接")
    else:
        print("连接error")
        ifaces.disconnect()  
        return False
    
    # 断开连接
    time.sleep(5) 
    ifaces.disconnect()  
    time.sleep(5)  # 尝试5秒
    if ifaces.status() != const.IFACE_CONNECTED:
        print("成功断开连接")
    else:
        print("断开连接error")
    time.sleep(1)
    return isok

if __name__ == '__main__':
    Number_of_consecutive_failures = 0
    count = 0
    while True :
        count += 1
        print(time.asctime(time.localtime(time.time())) + "------------------------------count：" + str(count) + "-------------------------------------")
        wifi_connect_status()
        if connect_and_disconnect_wifi("TP-Link_4040_5G", '12345670') == False :
            Number_of_consecutive_failures += 1
            print(time.asctime(time.localtime(time.time())) + "----Number_of_consecutive_failures：" + str(Number_of_consecutive_failures) + "----")
            # 连续15次连接5G失败则连接2.4G并给server酱推送消息
            if Number_of_consecutive_failures > 20 :
                print("给server酱推送消息")
                while connect_wifi("TP-Link_4040", '12345670')  == False :
                    pass
                content = """
                #Bug复现了
                ##请尽快查看Bug 
                """  + ", count = " + str(count) + ", time = " + time.asctime(time.localtime(time.time()))
                data = {
                   "text":title,
                   "desp":content
                }
                requests.post(api,data = data)
                Number_of_consecutive_failures = 0
        else:
            Number_of_consecutive_failures = 0
