[TOC]

# 能**上网查到**的就不要记了

#### 书签备份

* [bookmarks_2019_12_7.7z](https://www.lanzous.com/i7vu99g)

#### varay

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

