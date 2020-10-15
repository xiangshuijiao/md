#!/bin/sh
if [[ "$2" == "" ]]
then
  make_compile_options="MODEL=$1"
else
  make_compile_options="MODEL=$1 SPEC=$2"
fi

timer_start=`date "+%Y-%m-%d %H:%M:%S"`

rm -rf nohup.out && touch nohup.out && tail -f nohup.out&
nohup make $make_compile_options env_build && if [ $? -ne 0 ]; then echo "failed"; exit -1; else echo "succeed"; fi 
nohup make $make_compile_options boot_build  && if [ $? -ne 0 ]; then echo "failed"; exit -1; else echo "succeed"; fi
nohup make $make_compile_options kernel_build  && if [ $? -ne 0 ]; then echo "failed"; exit -1; else echo "succeed"; fi
nohup make $make_compile_options modules_build  && if [ $? -ne 0 ]; then echo "failed"; exit -1; else echo "succeed"; fi
nohup make $make_compile_options apps_build  && if [ $? -ne 0 ]; then echo "failed"; exit -1; else echo "succeed"; fi
nohup make $make_compile_options cmm -B  && if [ $? -ne 0 ]; then echo "failed"; exit -1; else echo "succeed"; fi
nohup make $make_compile_options fs_build  && if [ $? -ne 0 ]; then echo "failed"; exit -1; else echo "succeed"; fi
nohup make $make_compile_options image_build  && if [ $? -ne 0 ]; then echo "failed"; exit -1; else echo "succeed"; fi

timer_end=`date "+%Y-%m-%d %H:%M:%S"`
converts_the_entered_seconds_into_minutes_and_displays_them()
{
  hour=$(( $1/3600 ))
  min=$(( ($1-${hour}*3600)/60 ))
  sec=$(( $1-${hour}*3600-${min}*60 ))
  echo ${hour}hour:${min}min:${sec}sec
}
converts_the_entered_seconds_into_minutes_and_displays_them  $(($(date +%s -d "${timer_end}") - $(date +%s -d "${timer_start}")))
