#!/bin/sh
if [[ "$2" == "" ]]
then
  make_compile_options="MODEL=$1"
else
  make_compile_options="MODEL=$1 SPEC=$2"
fi

rm -rf nohup.out && touch nohup.out && tail -f nohup.out&
nohup make $make_compile_options env_build && if [ $? -ne 0 ]; then echo "failed"; exit -1; else echo "succeed"; fi 
nohup make $make_compile_options boot_build  && if [ $? -ne 0 ]; then echo "failed"; exit -1; else echo "succeed"; fi
nohup make $make_compile_options kernel_build  && if [ $? -ne 0 ]; then echo "failed"; exit -1; else echo "succeed"; fi
nohup make $make_compile_options modules_build  && if [ $? -ne 0 ]; then echo "failed"; exit -1; else echo "succeed"; fi
nohup make $make_compile_options apps_build  && if [ $? -ne 0 ]; then echo "failed"; exit -1; else echo "succeed"; fi
nohup make $make_compile_options cmm -B  && if [ $? -ne 0 ]; then echo "failed"; exit -1; else echo "succeed"; fi
nohup make $make_compile_options fs_build  && if [ $? -ne 0 ]; then echo "failed"; exit -1; else echo "succeed"; fi
nohup make $make_compile_options image_build  && if [ $? -ne 0 ]; then echo "failed"; exit -1; else echo "succeed"; fi
