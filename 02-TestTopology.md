
* [测试拓扑搭建教程](#%E6%B5%8B%E8%AF%95%E6%8B%93%E6%89%91%E6%90%AD%E5%BB%BA%E6%95%99%E7%A8%8B)
  * [相关知识](#%E7%9B%B8%E5%85%B3%E7%9F%A5%E8%AF%86)
  * [DNS](#dns)
  * [DHCP](#dhcp)
  * [PPPOE](#pppoe)
  * [dibbler\-server、radvd](#dibbler-serverradvd)
  * [PPPOEv6](#pppoev6)
  * [转发功能](#%E8%BD%AC%E5%8F%91%E5%8A%9F%E8%83%BD)
  * [静态IP](#%E9%9D%99%E6%80%81ip)
  * [组播](#%E7%BB%84%E6%92%AD)
  * [VLAN](#vlan)
* [配置文件](#%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6)
  * [静态IP、DNS](#%E9%9D%99%E6%80%81ipdns)
  * [dhcp配置文件](#dhcp%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6)
  * [radvd配置文件](#radvd%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6)
  * [dibbler配置文件](#dibbler%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6)
  * [pppoe配置文件](#pppoe%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6)
  * [pppoev6配置文件](#pppoev6%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6)
* [测试](#%E6%B5%8B%E8%AF%95)
* [踩的坑](#%E8%B8%A9%E7%9A%84%E5%9D%91)
  * [glibc升级](#glibc%E5%8D%87%E7%BA%A7)
  * [dibbler启动](#dibbler%E5%90%AF%E5%8A%A8)
* [拓扑目前依旧存在的问题](#%E6%8B%93%E6%89%91%E7%9B%AE%E5%89%8D%E4%BE%9D%E6%97%A7%E5%AD%98%E5%9C%A8%E7%9A%84%E9%97%AE%E9%A2%98)
  * [网关上的ipv6路由表要自己搭建](#%E7%BD%91%E5%85%B3%E4%B8%8A%E7%9A%84ipv6%E8%B7%AF%E7%94%B1%E8%A1%A8%E8%A6%81%E8%87%AA%E5%B7%B1%E6%90%AD%E5%BB%BA)
  * [pppoe拨号获取ipv6相关信息失败](#pppoe%E6%8B%A8%E5%8F%B7%E8%8E%B7%E5%8F%96ipv6%E7%9B%B8%E5%85%B3%E4%BF%A1%E6%81%AF%E5%A4%B1%E8%B4%A5)
  * [Dynamic拨号获取ipv6相关信息失败](#dynamic%E6%8B%A8%E5%8F%B7%E8%8E%B7%E5%8F%96ipv6%E7%9B%B8%E5%85%B3%E4%BF%A1%E6%81%AF%E5%A4%B1%E8%B4%A5)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc.go)
------------------分隔符------------------不要删除------------------分隔符------------------不要删除------------------分隔符------------------

### 测试拓扑搭建教程

#### 相关知识

* host www.debian.cn 192.168.23.179  指定域名服务器，正向查询

* host 192.168.23.179  192.168.23.179 指定域名服务器，反向查询

* ufw disable 关闭防火墙

* netstat -uap查看本机运行的服务

* vim /var/log/syslog 查看系统日志，会有各种服务器启动失败的原因

* 开机执行脚本 **/etc/rc.local**

* killall 进程名，kill 进程PID

* [linux中grep命令的用法：如何使用正则表达式筛选](https://www.cnblogs.com/flyor/p/6411140.html)

* [Linux（Ubuntu 16.04）搭建ftp服务器](https://blog.csdn.net/null_qiao/article/details/76919234)

* [ubuntu登录自动运行脚本(解决root权限问题)](https://blog.csdn.net/mao0514/article/details/55094615)

* [Ubuntu全盘备份与恢复，亲自总结，实测可靠](https://blog.csdn.net/sinat_27554409/article/details/78227496)

    * 将下面的脚本拷贝到/backup文件夹并执行
    * [ubuntu 系统备份和还原策略](https://github.com/hayifeng/Just_For_Fun/issues/7)：备份到最后系统会提示`tar: 由于前次错误,将以上次的错误状态退出`，这个警告可以忽略，没什么影响的。

    ```makefile
    echo $(date)
    cd /
    tar cvpzf /backup/`date +%Y%m%d%H%M`.tgz --exclude=/proc --exclude=/lost+found --exclude=/backup --exclude=/mnt --exclude=/tmp --exclude=/media /
    echo $(date)
    ```

#### DNS

* [Linux系统下搭建DNS服务器——DNS原理总结](https://zhuanlan.zhihu.com/p/31568450)
* [Ubuntu采用bind9配置DNS服务器](https://blog.csdn.net/colourzjs/article/details/44491479)
* [DNS记录类型介绍(A记录、MX记录、NS记录等)](https://blog.csdn.net/tvk872/article/details/80683480)
* [[DNS]ubuntu搭建DNS服务器（bind9）- IPv6](https://blog.csdn.net/u012503786/article/details/86579178)
* [localhost 127.0.0.1 127.1 本地回送IP地址](https://zhidao.baidu.com/question/120305135.html)
* [bind配置工具rndc使用](https://www.jianshu.com/p/f08cf7cebf3f)
* 最终可用的配置：
    * [DNS软件bind使用（一）](https://blog.51cto.com/cuchadanfan/1710387)
    * [Debian 环境下简单配置 Bind9 服务](https://cloud.tencent.com/developer/article/1374805)

#### DHCP

* [Ubuntu-16.04搭建DHCP服务](https://blog.51cto.com/tong707/2124716)
* [Ubuntu 14.04 isc-dhcp-server 启动失败(no IPv4 addresses)问题解决方法](https://blog.csdn.net/yingang_fu/article/details/39400845)

#### PPPOE

* VlanID：局端会剥去从样机过来的VlanID为35的头部，从局端出来的所有的数据都没有VlanID，所以服务器不需要划分VlanID，下面的四个网页看看就好，用不到的。

    * [单lan PPPoE服务器，多lan PPPoE服务器，VLAN PPPoE服务器搭建](https://en.ikuai8.com/support_article.php?id=0000000732)
    * [搭建网关系列 —— VLAN篇](https://onebitbug.me/2014/05/28/building-a-gateway-vlan/)
    * [Ubuntu上建立PPPoE server,并使用VLAN，用于常用双VLAN测试](http://blog.chinaunix.net/uid-22490342-id-3405506.html)
    * [LINUX (UBUNTU) 双网卡多VLAN的Server 配置](https://blog.51cto.com/jingshengsun888/1265947)

* 最终使用

    * [基于Linux环境的PPPOE服务器搭建](https://zhuanlan.zhihu.com/p/41499761)

    * ```makefile
        pppoe-server -I enp1s0  -L 192.168.5.1 -R 192.168.5.3 -N 200
        ```

#### dibbler-server、radvd

* 内网：培训时李伟杰的ppt、Ubuntu下测试环境搭建doc

* 虽然无状态拨号用不到ICMPV6交互，但是还是要安装radvd并配置启动，因为不仅仅无状态拨号用到了ICMPV6交互，NDP邻居发现协议、DVD重复地址检测都用到了ICMPv6，如果不配置radvd可能就会获取不到网关等信息。

* 配置dibbler-server后进行DHCPV6有状态dynamic拨号时如果发现DNS获取失败、LAN前缀获取失败，那就:

    * 没有DNS、网关就重启radvd
    * 没有ip就重启dibbler-server
    * 重启服务器、路由器、换一个样机再试试。我最开始使用的样机出现了上面的问题导致我以为我自己的配置文件写的有问题，然后在这个上面耗费了很长的一段时间，后来也怀疑过是样机的问题，但是换了几个样机后ipv6的dynamic拨号仍旧会出现上面的问题，最后碰巧使用了晓龙的样机居然没有任何的问题，感觉前面花费的时间都白费了。

* ping服务器时服务器收到了icmpv6报文却不进行回复，这时需要配置路由表，配置命令如下：

    ```makefile
    ip -6 route add 2001::/50 via fe80::4216:9fff:feaa:bb3a dev enp1s0
    ```

    * 2001::/50为dibbler服务器分给DUT样机的LAN口前缀
    * fe80::4216:9fff:feaa:bb3a为DUT wan口的本地链路地址，这里也可以填写dibbler分配給WAN口的全球链路地址，也就是说ipv6的网关既可以是本地链路地址，也可以是全球链路地址。
    * enp1s0为dibbler服务器所在的网卡名，也是DUT wan口直连的服务器网卡名。

#### PPPOEv6

* `/etc/ppp/pppoe-server-options`多一项配置`+ipv6`
* [基于Linux的IPv6接入服务器配置过程](https://wenku.baidu.com/view/12ae3149852458fb770b5684.html)的`PPPoEv6服务器配置`章节中解释了必须配置/etc/ppp/ipv6-up.d脚本的原因。脚本的唯一作用：**`将/etc/radvd.conf和/etc/dibbler/server.conf中的iface网口名enp1s0替换为pppoe服务器启动时新建的网口名ppp0或ppp1或ppp2等，并重启radvd、dibbler-server `**

#### 转发功能

* [ubuntu 双网卡转发网线直接连接配置](https://blog.csdn.net/tiger_he/article/details/80805075): vim /etc/sysctl.conf 
* 参考：[ubuntu双网卡设置内外网上网问题,实现路由转发](https://wenku.baidu.com/view/1920c29b4693daef5ef73df7.html)
* `sysctl -p`全为1表示ipv4、ipv6的转发功能都开启了

#### 静态IP

* 在Ubuntu1404中通过`/etc/network/interfaces`配置ipv4、ipv6地址时ipv4不生效，重启电脑也不行，Ubuntu1604中则没有这个问题，通过反复执行下面的命令可以使配置生效，具体哪个起的作用我也不清楚
    * `ifdown eth0 && ifup eth0 && ifconfig ` **这个命令可能会执行失败，所以需要反复执行，如果能成功执行就能使配置生效**
    * `ifconfig eth0 down up`
    * `/etc/init.d/network restart`
    * `/etc/init.d/network-manager restart`
* **注意：**在``/etc/NetworkManager/system-connections``中的配置信息可能会和`/etc/network/interfaces`中的配置信息冲突，所以最好删除``/etc/NetworkManager/system-connections``中的所有文件，然后重启电脑。

#### 组播

*   [组播转发开启方法](http://www.sskywatcher.com/blog/archives/336)
*   vlc3.0.2 ubuntu1604 snap 安装方法
    * 谷歌搜索：snap  vlc download下载离线snap安装包
    * apt install snapd
    * snap install xxxxx.snap --dangerous

#### VLAN

* [理解Switch中的PVID / VID /标签/取消标签](http://www.wdroot.com/articles/167.html)
* [VLAN的理解和应用](https://blog.csdn.net/zhangxinbiao2011/article/details/40144959)

### 配置文件

#### 静态IP、DNS

* vim /etc/network/interfaces

    ```makefile
    auto lo
    iface lo inet loopback
    
    auto  enp1s0
    iface enp1s0 inet static
            address         192.168.5.1
            netmask         255.255.255.0
            broadcast       192.168.5.255
    #        gateway        10.112.18.254
    #           dns-nameservers    10.112.18.1 10.112.18.2  vim  /etc/resolv.conf 
    iface enp1s0 inet6 static
            address         2404:5555::1
            netmask         64
    ```

    auto  enp3s0
    iface enp3s0 inet static
            address         10.0.0.1
            netmask         255.255.255.0
            broadcast       10.0.0.255
    iface enp3s0 inet6 static
            address         2404:0000::1
            netmask         64

```
##### dns 配置文件

* vim /etc/bind/named.conf.local

  ```makefile
  zone "debian.cn" {
      type master;
      file "/etc/bind/zones/db.debian.cn";
  };

  zone "168.192.in-addr.arpa"  {
      type master;
      file "/etc/bind/zones/db.192.168";
  };
```

* vim /etc/bind/zones/db.debian.cn

    ```makefile
    $TTL    604800
    @   IN  SOA debian.cn. admin.debian.cn. (
                      2     ; Serial
                 604800     ; Refresh
                  86400     ; Retry
                2419200     ; Expire
                 604800 )   ; Negative Cache TTL
    ;
    @   IN  NS  ns.debian.cn.
    @   IN  A   192.168.5.2
    ns  IN  A   192.168.5.2
    www IN  A   192.168.5.3
    ipv4 IN A   10.0.0.100
    ipv6  IN  AAAA 2404::100
    proxy IN CNAME @
    blog IN CNAME @
    mysql IN CNAME @
    * IN A 192.168.5.4
    ```

* vim /etc/bind/zones/db.192.168 

    ```makefile
    $TTL    604800
    @   IN  SOA debian.cn. admin.debian.cn. (
                      1     ; Serial
                 604800     ; Refresh
                  86400     ; Retry
                2419200     ; Expire
                 604800 )   ; Negative Cache TTL
    ;
    @   IN  NS  ns.debian.cn.
    3.5 IN  PTR www.debian.cn.
    ```

#### dhcp配置文件

* vim /etc/sysctl.conf开启ipv4和ipv6转发，并用sysctl -p检查是否开启成功

    ```makefile
    net.ipv4.ip_forward=1
    net.ipv6.conf.all.forwarding=1
    ```

* vim /etc/default/isc-dhcp-server

    ```makefile
    INTERFACES="enp1s0"
    ```

* vim /etc/dhcp/dhcpd.conf

    ```makefile
    #subnet后跟子网网段，netmask后跟子网掩码
    subnet 192.168.5.0 netmask 255.255.255.0 {
            #地址池
            range 192.168.5.3 192.168.5.244;
            #DNS服务器地址(多个地址用","隔开)
            option domain-name-servers 192.168.5.1;
            #为所分配的域分配域名
    #       option domain-name "mylab.com";
            #为所分配的主机分发子网掩码
            option subnet-mask 255.255.255.0;
            #分发默认网关
            option routers 192.168.5.1;
            #分发广播地址
            option broadcast-address 192.168.5.255;
            #默认租期时间(秒)
            default-lease-time 6000000;
            #最大租期时间(秒)
            max-lease-time 72000000;
    }
    ddns-update-style none;
    option domain-name "example.org";
    default-lease-time 600;
    max-lease-time 7200;
    ```

#### radvd配置文件

* vim /etc/radvd.conf

    ```makefile
    interface enp1s0 {
            MaxRtrAdvInterval 600;
            MinRtrAdvInterval 360;
            IgnoreIfMissing on;
            AdvSendAdvert on;
            AdvOtherConfigFlag off;
            AdvManagedFlag on;
    };
    ```

#### dibbler配置文件

* vim /etc/dibbler/server.conf

    ```makefile
    log-level 8
    log-mode short
    preference 100
    
    iface enp1s0 {
             t1 100
             t2 400
             prefered-lifetime 6000000
             valid-lifetime 6000000
    
             class {
               pool 2404:5555::/64
             }
    
             ta-class {
                pool 2004::/64
             }
    
             pd-class {
                 pd-pool 2001::/50
                 pd-length 64
             }
             option dns-server 2404:5555::1
    }
    ```

#### pppoe配置文件

* vim /etc/ppp/options

    ```makefile
    ms-dns 192.168.5.1
    asyncmap 0
    auth
    crtscts
    lock
    hide-password
    modem
    netmask 255.255.255.0
    passive
    -ac
    -pap
    +chap
    debug
    proxyarp
    lcp-echo-interval 30
    lcp-echo-failure 4
    noipx
    ```

* vim /etc/ppp/pppoe-server-options

    ```makefile
    require-chap
    lcp-echo-interval 60
    lcp-echo-failure 5
    logfile /var/log/pppd.log
    +ipv6
    ```

* vim /etc/ppp/chap-secrets

    ```makefile
    ttt    *    ttt         *
    ```

#### pppoev6配置文件

* ```makefile
    /etc/skel/dibbler_server_for_eth.conf
    /etc/skel/dibbler_server_for_pppoe.conf
    配置文件和/etc/dibbler/server.conf相同，只是接口名都换成了IFNAME
    
    /etc/skel/radvd_for_eth.conf
    /etc/skel/radvd_for_pppoe.conf
    配置文件和/etc/radvd.conf相同，只是接口名都换成了IFNAME
    ```

* vim /etc/ppp/ipv6-up.d/00radvd

    ```makefile
    #! /bin/bash
    
    CONFSKEL=/etc/skel/radvd_for_pppoe.conf
    CONFREAL=/etc/radvd.conf
    IFNAME="$1"
    
    logger -p user.info  restart radvd on interface $IFNAME
    
    cp "${CONFSKEL}" "${CONFREAL}"
    sed -i "s/IFNAME/${IFNAME}/g" "${CONFREAL}"
    
    service radvd restart
    service radvd restart
    service radvd restart
    
    ip -6 route delete 2001::/50
    ip -6 route add 2001::/50 dev $IFNAME
    ```

* vim /etc/ppp/ipv6-up.d/01dibbler

    ```makefile
    #! /bin/bash
    
    CONFSKEL=/etc/skel/dibbler_server_for_pppoe.conf
    CONFREAL=/etc/dibbler/server.conf
    IFNAME="$1"
    
    logger -p user.info restart dibbler-server on interface $IFNAME
    
    service dibbler-server stop
    rm -rf /var/lib/dibbler/*
    
    cp "${CONFSKEL}" "${CONFREAL}"
    sed -i "s/IFNAME/${IFNAME}/g" "${CONFREAL}"
    
    service dibbler-server start
    service dibbler-server restart
    service dibbler-server restart
    service dibbler-server restart
    ```

* vim /etc/ppp/ipv6-down.d/00dibbler

    ```makefile
    #! /bin/bash
    
    CONFSKEL=/etc/skel/dibbler_server_for_eth.conf
    CONFREAL=/etc/dibbler/server.conf
    PPPIFNAME="$1"
    ETHIFNAME="enp1s0"
    
    logger -p user.info stop dibbler-server on interface $PPPIFNAME
    
    service dibbler-server stop
    rm -rf /var/lib/dibbler/*
    
    logger -p user.info start dibbler-server on interface $ETHIFNAME
    cp "${CONFSKEL}" "${CONFREAL}"
    sed -i "s/IFNAME/${ETHIFNAME}/g" "${CONFREAL}"
    
    service dibbler-server start
    service dibbler-server restart
    service dibbler-server restart
    service dibbler-server restart
    service dibbler-server restart
    ```

* vim /etc/ppp/ipv6-down.d/01radvd

    ```makefile
    #! /bin/bash
    
    CONFSKEL=/etc/skel/radvd_for_eth.conf
    CONFREAL=/etc/radvd.conf
    PPPIFNAME="$1"
    ETHIFNAME="enp1s0"
    
    logger -p user.info  stop radvd on interface $PPPIFNAME
    service radvd stop
    
    cp "${CONFSKEL}" "${CONFREAL}"
    sed -i "s/IFNAME/${ETHIFNAME}/g" "${CONFREAL}"
    
    logger -p user.info  start radvd on interface $ETHIFNAME
    service radvd start
    service radvd start
    service radvd start
    service radvd start
    
    ip -6 route delete 2001::/50
    ip -6 route add 2001::/50 dev enp1s0
    ```

```
* 给4个脚本可执行权限

  ```makefile
  chmod 777 -R /etc/ppp/ipv6-up.d/*
  chmod 777 -R /etc/ppp/ipv6-down.d/*
```

* 开机自启动：`vim /etc/rc.local`

    ```makefile
    pppoe-server -I enp1s0  -L 192.168.5.1 -R 192.168.5.3 -N 200
    ```

* **注意：**因为每次进行pppoe连接时都会新建一个ppp接口，而dibbler-server必须要在指定的ppp接口上启动才可以给该ppp接口连接的DUT样机分配IPV6地址，而上面脚本的作用就是每来一个ppp连接就将dibbler-server的启动接口修改为新建的ppp连接接口，从而给新建的连接分配ipv6地址，但是这样就不能给旧有的ppp连接分配ipv6地址了，所以我采用了以下两点策略：

* 将dibbler-server的地址有效时间修改的长一点，这样旧有的ppp连接有了地址之后的很长一段时间都不用再次获取ipv6地址。

    * pppoe拨号获取ipv6失败就反复重拨，因为每次拨号都会将dibbler-server的启动接口修改为新建的ppp接口，同时还会重启dibbler-server服务器。

### 测试

* sip服务器上已经注册过的电话

    ```c
    101 102 103 104 105
    ```

* dns：能ping通`ipv4.debian.cn（10.0.0.100）`和`ipv6.debian.cn(2404::100)`

* http：直接在样机连接的pc的浏览器上输入`10.0.0.100`或者输入对应的域名`ipv4.debian.cn`可以连接到http文件服务器

* acs：直接在样机连接的pc的浏览器上输入`10.0.0.100:8080//login`或者输入对应的域名`ipv4.debian.cn:8080//login`可以连接到acs服务器

* voip：能注册并拨通电话

* chariot：[linux的endpoint下载地址（下载tar压缩包）](https://support.ixiacom.com/support-links/ixchariot/endpoint-library/platform-endpoints)

    * [Ubuntu14.04下Endpoint5.1的安装及使用方法](https://blog.csdn.net/snaking616/article/details/79094171)**注意不要使用这里的安装包，回报错的，使用上面的**。

    * ```makefile
        /usr/local/Ixia/endpoint 1>>/var/local/endpoint.console 2>&1 & 启动endpoint（放/etc/rc.local可以开机自启动）
        cp /usr/local/Ixia/rc2exec.lnx /etc/init.d/endpoint
        ln -fs /etc/rc.d/init.d/endpoint /etc/rc2.d/S81endpoint
        ln -fs /etc/rc.d/init.d/endpoint /etc/rc3.d/S81endpoint
        ln -fs /etc/rc.d/init.d/endpoint /etc/rc6.d/K81endpoint
        ```

    * 测试的吞吐量UDP只有5Mbps，TCP也只有56Mbps，不知道为什么，具体有拍照

* 组播IPTV

    * [关于组播IPTV的讲解](https://blog.csdn.net/qq_34228570/article/details/80152133)

* iperf

    * [[网络性能测试工具iperf详细使用图文教程【转载】](https://www.cnblogs.com/yingsong/p/5682080.html)](https://www.cnblogs.com/yingsong/p/5682080.html)

### 踩的坑

#### glibc升级

* 千万不要升级glibc！！！

* 在源码安装chariot endpoint时提示glibc版本太低，于是升级glibc，然后系统就崩了，再也起不来了，只能找网管重装系统再来一遍，下面的恢复教程都没用。

* [编译升级glibc与修复](https://github.com/levinit/itnotes/wiki/%E7%BC%96%E8%AF%91%E5%8D%87%E7%BA%A7glibc%E4%B8%8E%E4%BF%AE%E5%A4%8D#%E4%BF%AE%E5%A4%8Dglibc)

* [记GLIBC升级失败后的恢复](http://blog.koko.vc/a/33/%E8%AE%B0glibc%E5%8D%87%E7%BA%A7%E5%A4%B1%E8%B4%A5%E5%90%8E%E7%9A%84%E6%81%A2%E5%A4%8D)

#### dibbler启动

* dibbler-server在enp1s0接口上能正常启动分配IP，在进行pppoev6拨号时在ppp接口上启动失败，询问师兄后得知：使用`rm -rf /var/lib/dibbler/*`将原来的配置信息给清除掉就可以了

### 拓扑目前依旧存在的问题

#### 网关上的ipv6路由表要自己搭建

#### pppoe拨号获取ipv6相关信息失败

* 解决1：反复几次重新拨号或者干脆删掉连接后重新建立连接。
* 解决2：使用串口查看自己的ppp接口名，然后在服务器上将radvd、dibbler的启动接口修改为自己的ppp接口并重启。
* 原因说明：因为每次pppoe拨号启动时都会将dibbler-server的启动接口修改为新建的ppp接口并重启dibbler-server服务器，而每次pppoe拨号断开时会将dibbler-server的启动接口修改为enp1s0接口并重启dibbler-server服务器，如果pppoe拨号获取ipv6失败就反复几次重新拨号或者干脆删掉连接后重新建立连接，因为dibbler-server服务器有小概率会启动失败，而每次拨号都会重启dibbler-server服务器

#### Dynamic拨号获取ipv6相关信息失败

* 解决1：新建一个pppoe拨号并删除，然后在进行Dynamic拨号。
* 解决2：使用串口查看自己的ppp接口名，然后在服务器上将radvd、dibbler的启动接口修改为自己的ppp接口并重启。
* 原因说明：因为每次pppoe拨号启动时都会将dibbler-server的启动接口修改为新建的ppp接口并重启dibbler-server服务器，而每次pppoe拨号断开时会将dibbler-server的启动接口修改为enp1s0接口并重启dibbler-server服务器，如果Dynamic拨号获取ipv6失败就先新建一个pppoe拨号并删除，然后在进行Dynamic拨号即可获取ipv6地址，因为每次pppoe拨号断开时会将dibbler-server的启动接口修改为enp1s0接口并重启dibbler-server服务器。

