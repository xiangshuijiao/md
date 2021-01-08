#!/bin/sh

# 使用方法：运行命令 docker exec docker容器名 docker脚本绝对路径

# $1：独一无二的项目ID（项目名加branch）
# $2：project_name
# $3：branch
# $4：git_clone_command，例如 git@spcodes.rd.tp-link.net:PON/PON_trunk_bba_2_5.git
# $5：commit_msg_hook_command
# $6：build_path
# $7：image_path
# $8：image_file_name
# $9：the_file_used_to_check_if_the_compile_was_successful
# ${10}：MODEL # 注意，$10 不能获取第十个参数，获取第十个参数需要${10}。当n>=10时，需要使用${n}来获取参数。
# ${11}：SPEC
# ${12}：specific_commit
need_to_re_clone_the_project=true
A_function_that_compile_specified_commit()
{ 
  # No changes needed
  work_path=/opt/bba/compile_specified_commit/$1 
  target_path=/opt/bba/image
  logfile=/tmp/jkn.script.compile_specified_commit.$1.log

  # changes needed
  project_name=$2
  branch=$3
  git_clone_command="git clone $4 -b $branch" 
  commit_msg_hook_command=$5
  build_path=$6
  image_path=$7
  image_file_name=$8
  the_file_used_to_check_if_the_compile_was_successful=$9
  MODEL=${10} # 注意，$10 不能获取第十个参数，获取第十个参数需要${10}。当n>=10时，需要使用${n}来获取参数。
  SPEC=${11}
  commit_specific=${12}
  
  echo "=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>start `date`" >> $logfile 2>&1 </dev/null

  # prepare work
  mkdir -p $work_path && cd $work_path

  # git clone
  if [ "$need_to_re_clone_the_project" == true ]
  then
    rm -rf   $work_path/$project_name
    eval `ssh-agent` && ssh-add
    echo $git_clone_command >> $logfile 2>&1 </dev/null
    nohup $git_clone_command >> $logfile 2>&1 </dev/null
    if [[ "$commit_msg_hook_command" != "" ]]
    then
      echo $commit_msg_hook_command  >> $logfile 2>&1 </dev/null
      nohup $commit_msg_hook_command  >> $logfile 2>&1 </dev/null
    fi
    if [ ! -d $work_path/$project_name/.git ]
    then
      echo git clone failed >> $logfile 2>&1 </dev/null
      echo "<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=end `date`" >> $logfile 2>&1 </dev/null
      return -1
    fi
  fi

  # git checkout branch
  cd $work_path/$project_name
  echo git checkout -f $branch >> $logfile 2>&1 </dev/null
  nohup git checkout -f $branch >> $logfile 2>&1 </dev/null

  # make
  for i in ${commit_specific[*]}; do
    commit_id=$i
    cd /opt && ls | grep -v bba | grep -v share_data_folder | xargs rm -rf # 删除交叉编译工具
    cd $work_path/$project_name && git clean -dfx
    echo git reset --hard $commit_id >> $logfile 2>&1 </dev/null
    git reset --hard $commit_id >> $logfile 2>&1 </dev/null
    
    cd $work_path/$project_name/$build_path
    if [[ "$SPEC" == "" ]]
    then
      make_compile_options="MODEL=$MODEL"
    else
      make_compile_options="MODEL=$MODEL SPEC=$SPEC"
    fi
    nohup make $make_compile_options env_build >> $logfile 2>&1 </dev/null
    nohup make $make_compile_options boot_build >> $logfile 2>&1 </dev/null
    nohup make $make_compile_options kernel_build >> $logfile 2>&1 </dev/null
    nohup make $make_compile_options modules_build >> $logfile 2>&1 </dev/null
    nohup make $make_compile_options apps_build >> $logfile 2>&1 </dev/null
    nohup make $make_compile_options cmm -B >> $logfile 2>&1 </dev/null
    nohup make $make_compile_options fs_build >> $logfile 2>&1 </dev/null
    nohup make $make_compile_options image_build >> $logfile 2>&1 </dev/null

    # copy image
    cd $work_path/$project_name/$image_path
    if [ -f $the_file_used_to_check_if_the_compile_was_successful ]
    then
      echo Compile to generate image successfully >> $logfile 2>&1 </dev/null
      current_time=$(date +%Y_%m_%d_%H_%M_%S)
      destination_folder=$target_path/$current_time-$project_name-$branch-`git rev-parse --short HEAD`-specific
      mkdir -p $destination_folder
      cp -rf $image_file_name $destination_folder
      git log > $destination_folder/git\ log.txt
    else
      echo Compile to generate image failed >> $logfile 2>&1 </dev/null
    fi
  done
  echo "<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=end `date`" >> $logfile 2>&1 </dev/null
}

specific_commit=("bff0609" "3e7a552" "563a477")
need_to_re_clone_the_project=true
A_function_that_compile_specified_commit \
  "PON_trunk_bba_2_5.linux_XC220-G3v_v1" "PON_trunk_bba_2_5" "linux_XC220-G3v_v1"  \
  "ssh://jiangkainan@172.29.88.140:29418/PON_trunk_bba_2_5" \
  "scp -p -P 29418 jiangkainan@172.29.88.140:hooks/commit-msg PON_trunk_bba_2_5/.git/hooks/" \
  "BBA2.5_platform/build" "EN7528DU_SDK/tplink/output/XC220G3vv1/image" \
  "XC220-G3v(SP)v1_1.1.0_0.8.0_flash.bin XC220-G3v(SP)v1_1.1.0_0.8.0_up_boot.bin rootfs" \
  "XC220-G3v(SP)v1_1.1.0_0.8.0_flash.bin" "XC220G3vv1" ""  "${specific_commit[*]}"
  
  

# A_function_that_compile_specified_commit \
#   "PON_trunk_bba_2_5.linux_XC220-G3v_v1" "PON_trunk_bba_2_5" "linux_XC220-G3v_v1"  \
#   "git@spcodes.rd.tp-link.net:PON/PON_trunk_bba_2_5.git" \
#   "" \
#   "BBA2.5_platform/build" "EN7528DU_SDK/tplink/output/XC220G3vv1/image" \
#   "XC220-G3v(SP)v1_1.1.0_0.8.0_flash.bin XC220-G3v(SP)v1_1.1.0_0.8.0_up_boot.bin rootfs" \
#   "XC220-G3v(SP)v1_1.1.0_0.8.0_flash.bin" "XC220G3vv1" "" 
  
# A_function_that_compile_specified_commit \
#   "BBA_2_5_Platform_BCM.EX220_USSP_v1.2" "BBA_2_5_Platform_BCM" "EX220_USSP_v1.2"  \
#   "ssh://jiangkainan@172.29.88.140:29418/BBA_2_5_Platform_BCM" \
#   "scp -p -P 29418 jiangkainan@172.29.88.140:hooks/commit-msg BBA_2_5_Platform_BCM/.git/hooks/" \
#   "platform/build/" "platform/targets/EX220-G2uV1/USSP/image" \
#   "EX220-G2u_FLASH.bin.w EX220-G2u_UP_BOOT.bin rootfs boot.bin" \
#   "EX220-G2u_FLASH.bin.w" "EX220-G2uV1" "USSP"

