#!/bin/sh
# 参数：MODEL SPEC 编译选项
# 编译选项个数不定

# killall -V命令执行失败说明不存在该命令，需要重新安装
echo "*********************************************"
killall -V
echo "*********************************************"
if [ $? != 0 ]
then
	apt-get install psmisc # 安装后才会有killall命令
fi

if [[ "$2" == "" ]]
then
  make_compile_options="MODEL=$1"
else
  make_compile_options="MODEL=$1 SPEC=$2"
fi

timer_start=`date "+%Y-%m-%d %H:%M:%S"`

rm -rf nohup.out && touch nohup.out
tail -f nohup.out&
pid_of_tail=$!

if [ $3 = "all" ]
then
  echo -e "\\n\\n\\nThe ALL compile option is not supported\\n\\n\\n"
  exit -1
else
  i=3;
  while (( i <= $# ))
  do
     # 间接引用! 直接 $1 这样处理会出问题，不加 ! ，输出的就是数字!??因为外面的参数是 i 的值，而我们需要使用i,需要 ! 间接引用!
	 make_compile_options="$make_compile_options ${!i}"
     let i++;
  done
fi
make $make_compile_options 
kill $pid_of_tail

timer_end=`date "+%Y-%m-%d %H:%M:%S"`
converts_the_entered_seconds_into_minutes_and_displays_them()
{
  hour=$(( $1/3600 ))
  min=$(( ($1-${hour}*3600)/60 ))
  sec=$(( $1-${hour}*3600-${min}*60 ))
  echo ${hour}hour:${min}min:${sec}sec
}
converts_the_entered_seconds_into_minutes_and_displays_them  $(($(date +%s -d "${timer_end}") - $(date +%s -d "${timer_start}")))
