#!/bin/bash
# 使用方法：放到/etc/crontab中定时执行该脚本
# 0  9    * * *   root    /home/share_data_folder/4-script/opengrok_update_index_script.sh

logfile=/run/opengrok.log
bool=false
eval `ssh-agent` && ssh-add

# $1为git仓库所在路径，$2为仓库目前的分支
Check_if_the_Git_repository_in_the_specified_path_has_the_latest_commit()
{
        echo "=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>start `date`" >> $logfile 2>&1 </dev/null
        if [ -d $1 ]
        then
                cd $1
                git fetch -f >> $logfile 2>&1 </dev/null
                local_commit_date="git log -1 --format="%at" | xargs -I{} date -d @{} +%Y-%m-%d\ %H:%M:%S"
                local_commit_date=`echo ${local_commit_date} |awk '{run=$0;system(run)}'`

                remote_commit_date="git log remotes/origin/$2 -1 --format="%at" | xargs -I{} date -d @{} +%Y-%m-%d\ %H:%M:%S"
                remote_commit_date=`echo ${remote_commit_date} |awk '{run=$0;system(run)}'`

                local_commit_date=`date -d "$local_commit_date" +%s`
                remote_commit_date=`date -d "$remote_commit_date" +%s`

                echo local_commit_date=$local_commit_date >> $logfile 2>&1 </dev/null
                echo remote_commit_date=$remote_commit_date >> $logfile 2>&1 </dev/null
                 
                if [ $local_commit_date -gt $remote_commit_date ]; then
                        echo "$1 $2：$local_commit_date > $remote_commit_date" >> $logfile 2>&1 </dev/null
                elif [ $local_commit_date -eq $remote_commit_date ]; then
                        echo "$1 $2：$local_commit_date = $remote_commit_date" >> $logfile 2>&1 </dev/null
                else
                        echo "$1 $2：$local_commit_date < $remote_commit_date" >> $logfile 2>&1 </dev/null
						# 更新索引前强制用远程代码覆盖本地代码
                        bool=true
                        git reset --hard remotes/origin/$2 
                        git pull -f
                fi
        else
                echo "指定的仓库$1不存在，请手动重新clone" >> $logfile 2>&1 </dev/null
        fi
        echo "<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=end `date`" >> $logfile 2>&1 </dev/null
}

Check_if_the_Git_repository_in_the_specified_path_has_the_latest_commit "/home/opengrok/src/BBA_2_5_Platform_BCM/BBA_2_5_Platform_BCM/" "EX220_USSP_v1.2"
Check_if_the_Git_repository_in_the_specified_path_has_the_latest_commit "/home/opengrok/src/BBA_2_5_Platform_BCM.2/BBA_2_5_Platform_BCM/" "VX420-G2h-P1"
Check_if_the_Git_repository_in_the_specified_path_has_the_latest_commit "/home/opengrok/src/PON_trunk_bba_2_5/PON_trunk_bba_2_5/" "linux_XC220-G3v_v1"

if [ "$bool" == true ]
then
        echo "正在更新索引..." >> $logfile 2>&1 </dev/null
        docker exec opengrok rm -rf /var/run/opengrok-indexer
        docker exec opengrok /scripts/index.sh >> $logfile 2>&1 </dev/null
else
        echo "不需要更新索引..." >> $logfile 2>&1 </dev/null
fi

#end 结尾占位
