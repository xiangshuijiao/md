#!/bin/bash
export PATH
while read line
do
	# 如果读取的行中包含有自定义的分隔符就结束读取，注意if判断中的*表示匹配任意多的任意字符
	if [[ "$line" == *"------------------分隔符------------------不要删除------------------分隔符------------------不要删除------------------分隔符------------------"* ]]
	then
		echo "成功匹配自定义分隔符" 
		break
	else
		sed -i '1d' 01-ToBeModifide.md # 删除文件的第一行数据
	fi

done < 01-ToBeModifide.md 

# 文件“生成的TOC目录.md”已经存在则删除
if [ -f "生成的TOC目录.md" ]
then
	rm 生成的TOC目录.md
	echo "清理旧的文件“生成的TOC目录.md”"
else
	echo “旧的文件“生成的TOC目录.md”不存在，所以不需要清理”
fi


# 文件“ 01-ToBeModifide-merge.md”已经存在则删除
if [ -f " 01-ToBeModifide-merge.md" ]
then
        rm  01-ToBeModifide-merge.md
        echo "清理旧的文件“ 01-ToBeModifide-merge.md”"
else
        echo “旧的文件“ 01-ToBeModifide-merge.md”不存在，所以不需要清理”
fi



./00-gh-md-toc.exe 01-ToBeModifide.md > 生成的TOC目录.md
# 删除前3行对应的一级标题“Table of Contents”
sed -i '1,3d' 生成的TOC目录.md
cat 生成的TOC目录.md 01-ToBeModifide.md > 01-ToBeModifide-merge.md

# 合并后的文件“01-ToBeModifide-merge.md”如果已经成功生成则删除合并前的文件，且修改名字为合并前的文件
if [ -f "01-ToBeModifide-merge.md" ]
then
	rm 01-ToBeModifide.md 生成的TOC目录.md
	mv 01-ToBeModifide-merge.md 01-ToBeModifide.md
	echo "成功生成TOC目录并合并到文件开头"
else
	echo "文件合并失败"
fi

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
