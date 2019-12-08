  * [能<strong>上网查到</strong>的就不要记了](#%E8%83%BD%E4%B8%8A%E7%BD%91%E6%9F%A5%E5%88%B0%E7%9A%84%E5%B0%B1%E4%B8%8D%E8%A6%81%E8%AE%B0%E4%BA%86)
  * [书签备份](#%E4%B9%A6%E7%AD%BE%E5%A4%87%E4%BB%BD)
  * [v2ray](#v2ray)
  * [VMware虚拟机](#vmware%E8%99%9A%E6%8B%9F%E6%9C%BA)
  * [tmux使用手册](#tmux%E4%BD%BF%E7%94%A8%E6%89%8B%E5%86%8C)
  * [securecrt配置](#securecrt%E9%85%8D%E7%BD%AE)
  * [git手册](#git%E6%89%8B%E5%86%8C)
  * [vim配置文件](#vim%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6)
  * [typora配置文件](#typora%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6)
  * [python转exe](#python%e8%bd%acexe)
* [Ubuntu](#ubuntu)
  * [ubuntu新系统配置](#ubuntu%E6%96%B0%E7%B3%BB%E7%BB%9F%E9%85%8D%E7%BD%AE)
  * [Ubuntu1604源码安装wireshak最新版3\.0\.7](#ubuntu1604%E6%BA%90%E7%A0%81%E5%AE%89%E8%A3%85wireshak%E6%9C%80%E6%96%B0%E7%89%88307)
  * [ubuntu开启混杂模式后用wireshark抓包](#ubuntu%E5%BC%80%E5%90%AF%E6%B7%B7%E6%9D%82%E6%A8%A1%E5%BC%8F%E5%90%8E%E7%94%A8wireshark%E6%8A%93%E5%8C%85)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc.go)

#### 能**上网查到**的就不要记了

#### 书签备份

* [bookmarks_2019_12_7.7z](https://www.lanzous.com/i7vu99g)

#### v2ray

* [V2Ray搭建详细图文教程](https://github.com/233boy/v2ray/wiki/V2Ray搭建详细图文教程)
* [BBR安装教程：Debian9、CentOS](https://fangeqiang.com/2012.html)
* [v2ray免费账号·Alvin9999 / new-pac Wiki·GitHub](https://github.com/Alvin9999/new-pac/wiki/v2ray免费账号)


#### VMware虚拟机

* [VMware虚拟机扩展Linux根目录磁盘空间（Centos）](https://my.oschina.net/u/876354/blog/967848)
* 虚拟机linux设置静态IP
  - [Linux重启网卡报错：Bringing up interface eth0:1...... - 弗兰-随风小欢的博客 - CSDN博客](https://blog.csdn.net/qq_32575047/article/details/78896534)
  - [Linux虚拟机设置静态IP - Baishu的专栏 - CSDN博客](https://blog.csdn.net/sinat_32660629/article/details/80080880)

#### tmux使用手册

* [Tmux使用手册]([http://louiszhai.github.io/2017/09/30/tmux/#Tmux%E5%BF%AB%E6%8D%B7%E6%8C%87%E4%BB%A4](http://louiszhai.github.io/2017/09/30/tmux/#Tmux快捷指令))
* [Tmux 快捷键 & 速查表 & 简明教程](https://gist.github.com/ryerh/14b7c24dfd623ef8edc7)

#### securecrt配置

* 导出日志，行数无限制

- [SecureCRT配置屏幕内容输出到log文件 - quietly_brilliant的专栏 - CSDN博客](https://blog.csdn.net/quietly_brilliant/article/details/78125599)
- [10个提升工作效率的Secure CRT小窍门 - 你玩转了几个？-sandshell-51CTO博客](https://blog.51cto.com/sandshell/2118024)

#### git手册

* [常用 Git 命令清单](https://www.ruanyifeng.com/blog/2015/12/git-cheat-sheet.html)

#### vim配置文件

```shell
filetype on
filetype indent on
set autoindent
set smartindent
set tabstop=4
set noexpandtab
set shiftwidth=4
set nu
syntax on
inoremap { {}<ESC>i<CR><ESC>ko

nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> [B :bfisrt<CR>
nnoremap <silent> ]B :blast<CR>
```

#### typora配置文件

```c
/* 打开偏好设置 -> 打开主题文件夹 -> 新建 github.user.css 文件，填入如下内容。 */
/* 调整视图正文宽度 */
#write{
    max-width: 90%;
}
/* 调整源码正文宽度 */
#typora-source .CodeMirror-lines {
    max-width: 90%;
}
/* 调整输出 PDF 文件宽度 */
@media print {
    #write{
        max-width: 95%;
    }
    @page {
        size: A3;
    }
}
/* 调整正文字体,字体需单独下载 */
body {
    font-family: IBM Plex Sans;
}
```

#### python转exe

* [简单3步将你的python转成exe格式](https://zhuanlan.zhihu.com/p/38659588)
* 

### Ubuntu

#### ubuntu新系统配置

```shell
# 主文件夹改为英文
export LANG=en_US
xdg-user-dirs-gtk-update # 跳出对话框询问是否将目录转化为英文路径,同意并关闭.
export LANG=zh_CN # 关闭终端,并重起.下次进入系统,系统会提示是否把转化好的目录改回中文.选择不再提示,并取消修改.主目录的中文转英文就完成了~
```

#### Ubuntu1604源码安装wireshak最新版3.0.7

* [Ubuntu源码安装wireshark](https://blog.csdn.net/weixin_40850689/article/details/93466848)

* [Wireshark3.0 ubuntu16.04上编译](https://blog.csdn.net/cjqqschoolqq/article/details/89737648)

* 安装步骤

  * [下载源码：wireshark-master-3.0.zip](https://www.lanzous.com/i7kvtpc)
  
    ```shell
    wget -c http://download.qt-project.org/archive/qt/5.11/5.11.2/qt-opensource-linux-x64-5.11.2.run # 下载qt5.11.2
    # 安装工具包
    sudo apt-get install libglib2.0-dev
    sudo apt-get install libgcrypt20-dev
    sudo apt-get install flex bison
    sudo apt-get install libssh-dev
    sudo apt-get install libpcap-dev
    sudo apt-get install libssh-dev
    sudo apt-get install libsystemd-dev
    sudo apt-get install qmake-qt-gui
    sudo apt-get install libgl1-mesa-dev libglu1-mesa-dev freeglut3-dev
    
    chmod 777 qt-opensource-linux-x64-5.11.2.run && ./qt-opensource-linux-x64-5.11.2.run # 除了两个android不要选，其他都选上。 
    mkdir build && cd build 
    export CMAKE_PREFIX_PATH="/opt/Qt5.11.2/5.11.2/gcc_64/lib/cmake/Qt5Core:/opt/Qt5.11.2/5.11.2/gcc_64/lib/cmake/Qt5LinguistTools:/opt/Qt5.11.2/5.11.2/gcc_64/lib/cmake/Qt5Multimedia:/opt/Qt5.11.2/5.11.2/gcc_64/lib/cmake/Qt5PrintSupport:/opt/Qt5.11.2/5.11.2/gcc_64/lib/cmake/Qt5Svg"
    
    cmake -G "Unix Makefiles" ../wireshark-master-3.0/  # 注意：**如果已经进入了管理员模式就不要在使用sudo了，否则上一步的环境变量不会生效。**
    make && make install
    sudo wireshark
    ```

#### ubuntu开启混杂模式后用wireshark抓包

* ```shell
  service network-manager stop # 彻底关闭网络模块，防止开了混杂模式后一连网又退出混杂模式了
  # 将网卡设置为混杂模式
  ifconfig wlan0 down
  iwconfig wlan0 mode monitor
  ifconfig wlan0 up
  apt install aircrack-ng
  # 设置无线网卡既抓取2.4G的帧，也抓取5G的帧
  airodump-ng wlan0 --bssid ff:ff:ff:ff:ff:ff -C 2400-5900 
  # wireshark筛选出2.4G和5G的beacon帧
  wlan.fc.type==0x00 && wlan.fc.type_subtype==0x08 && (wlan.addr==00:12:23:38:38:38 || wlan.addr==00:12:23:38:38:399) 
  ```

* 

