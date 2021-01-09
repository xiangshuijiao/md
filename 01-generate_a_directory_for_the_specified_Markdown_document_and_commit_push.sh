#!/bin/bash
# 给参数指定的markdown文件生成目录并add commit push
export PATH

# 准备工作
echo "git pull -f" && git pull -f
generated_TOC_directory="generated_TOC_directory.md"
A_temporary_file_composed_of_directories_and_text="A_temporary_file_composed_of_directories_and_text.md"

# 检查参数是否存在
if [ "$1" = "" ]
then
echo 请输入脚本要操作的文件...
exit -1
fi

# 查找是否存在自定义分界线，找不到就异常退出
bool=false
while read line
do
	# 如果读取的行中包含有自定义的分隔符就结束读取，注意if判断中的*表示匹配任意多的任意字符
	if [[ "$line" == *"------------------分隔符------------------不要删除------------------分隔符------------------不要删除------------------分隔符------------------"* ]]
	then
		bool=true
		break
	fi
done < $1
if [ "$bool" == true ]
then
echo "成功匹配自定义分隔符"
else
echo "没有在指定文档中找到自定义分界线，将会异常退出..."
exit -1
fi


# 以自定义分界线为分隔符，删除旧的目录
while read line
do
	# 如果读取的行中包含有自定义的分隔符就结束读取，注意if判断中的*表示匹配任意多的任意字符
	if [[ "$line" == *"------------------分隔符------------------不要删除------------------分隔符------------------不要删除------------------分隔符------------------"* ]]
	then
		echo "成功匹配自定义分隔符" 
		break
	else
		sed -i '1d' $1 # 删除文件的第一行数据
	fi
done < $1


# 删除临时文件 $generated_TOC_directory $A_temporary_file_composed_of_directories_and_text
rm -rf $generated_TOC_directory
rm -rf $A_temporary_file_composed_of_directories_and_text
echo 临时文件清理完成


# 生成目录
./00-gh-md-toc.exe $1 > $generated_TOC_directory || (echo 生成目录失败; exit -1)
echo 生成目录完成

# 删除目录前3行对应的一级标题 Table of Contents
sed -i '1,3d' $generated_TOC_directory
cat $generated_TOC_directory $1 > $A_temporary_file_composed_of_directories_and_text


# 合并后的文件 $A_temporary_file_composed_of_directories_and_text 如果已经成功生成则删除合并前的文件，且修改名字为合并前的文件
if [ -f "$A_temporary_file_composed_of_directories_and_text" ]
then
	rm $1 $generated_TOC_directory
	mv $A_temporary_file_composed_of_directories_and_text $1
	echo "成功生成TOC目录并合并到文件开头"
else
	echo "文件合并失败"
fi


echo "" && echo "git diff" 				&& git diff
echo "" && echo "git add -A" 			&& git add -A
echo "" && echo "git commit -m `date`" 	&& git commit -m "`date`"
echo "" && echo "git push" 				&& git push
echo "" && echo "git status" 			&& git status

