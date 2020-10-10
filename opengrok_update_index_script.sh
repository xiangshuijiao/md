#!/bin/bash
# 放到/etc/crontab中定时执行

logfile=/tmp/opengrok.log
bool=false

# $1为git仓库所在路径，$2为仓库目前的分支
Check_if_the_Git_repository_in_the_specified_path_has_the_latest_commit()
{
	echo "=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>" >> $logfile 2>&1 </dev/null
	if [ -d $1 ]
	then
		cd $1
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
			bool=true
		fi
	else
		echo "指定的仓库$1不存在，请手动重新clone" >> $logfile 2>&1 </dev/null
	fi
	echo "<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=" >> $logfile 2>&1 </dev/null
}

Check_if_the_Git_repository_in_the_specified_path_has_the_latest_commit "/home/opengrok/src/BBA_2_5_Platform_BCM/BBA_2_5_Platform_BCM/" "EX220_USSP_v1.2"
Check_if_the_Git_repository_in_the_specified_path_has_the_latest_commit "/home/opengrok/src/BBA_2_5_Platform_BCM.2/BBA_2_5_Platform_BCM/" "VX420-G2h-P1"
Check_if_the_Git_repository_in_the_specified_path_has_the_latest_commit "/home/opengrok/src/PON_trunk_bba_2_5/PON_trunk_bba_2_5/" "feature_XC220_mesh"

if [ "$bool" == true ]
then
	echo "正在更新索引..." >> $logfile 2>&1 </dev/null
	docker exec opengrok /scripts/index.sh >> $logfile 2>&1 </dev/null
else
	echo "不需要更新索引..." >> $logfile 2>&1 </dev/null
fi
