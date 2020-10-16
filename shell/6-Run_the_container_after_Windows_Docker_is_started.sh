#!/bin/bash
# 当docker服务启动后使用git bash自动运行指定的容器
# 注意：要先把docker desktop设置为开机自启动


# 如果`docker ps`的结果中包含"CONTAINER ID"说明docker启动成功了
while :
do
	if [[ "`docker ps`" =~ "CONTAINER ID" ]]
	then 
		`docker start ubuntu1804`
		exit 0
	else 
		sleep 2
	fi
done
