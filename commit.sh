#!/bin/bash
export PATH

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


# 临时文件“生成的TOC目录.md”已经存在则删除
if [ -f "生成的TOC目录.md" ]
then
	rm 生成的TOC目录.md
	echo "清理旧的文件“生成的TOC目录.md”"
else
	echo “旧的文件“生成的TOC目录.md”不存在，所以不需要清理”
fi


# 临时文件“ 01-ToBeModifide-merge.md”已经存在则删除
if [ -f " 01-ToBeModifide-merge.md" ]
then
        rm  01-ToBeModifide-merge.md
        echo "清理旧的文件“ 01-ToBeModifide-merge.md”"
else
        echo “旧的文件“ 01-ToBeModifide-merge.md”不存在，所以不需要清理”
fi


# 生成目录
./00-gh-md-toc.exe $1 > 生成的TOC目录.md


# 删除目录前3行对应的一级标题“Table of Contents”
sed -i '1,3d' 生成的TOC目录.md
cat 生成的TOC目录.md $1 > 01-ToBeModifide-merge.md


# 合并后的文件“01-ToBeModifide-merge.md”如果已经成功生成则删除合并前的文件，且修改名字为合并前的文件
if [ -f "01-ToBeModifide-merge.md" ]
then
	rm $1 生成的TOC目录.md
	mv 01-ToBeModifide-merge.md $1
	echo "成功生成TOC目录并合并到文件开头"
else
	echo "文件合并失败"
fi

echo ""
echo "git pull"
git pull
echo ""
echo "git diff"
git diff
echo ""
echo "git add *"
git add * 
echo ""
echo "git commit -m 1"
git commit -m 1
echo ""
echo "git push"
git push
echo ""
echo "git status"
git status
