---
title: "git,svn使用"
date: 2021-04-05T18:53:42+08:00
draft: false
tags: ["git"]
categories: ["git"]
---

## git常用命令

### 提交

提交到master  
>git add .  
git commit -s -m "message"  
git push origin master

<!--more-->

### 拉取

如果只有一个分支  
>git pull

拉取origin/next分支到当前分支  
>git pull origin/next

pull=fetch+merge 结果相同，过程不同

### rebase和merge区别

merge 是合并的意思，rebase是复位基底的意思

merge操作会生成一个新的节点，之前提交分开显示。而rebase操作不会生成新的节点，是将两个分支融合成一个线性的操作

简单的说，merge会保留更多信息，处理冲突方便，rebase只有一条线看的更清晰，方便回滚

可以先rebase，如果有冲突，git rebase --abort，再换用merge

### 克隆

>git clone 路径

### 撤销commit

找到想要撤销的id  
>git log  

然后
>git reset id

### 切换分支

>git checkout branchName

切换后新建分支  
>git checkout -b 分支名

切换远程分支  
>git checkout -b 分支名 路径

### 查看分支

查看所有分支  
>git branch -a

## SVN使用

工具TortoiesSVN

在文件夹右击repo-browser可以查看项目

右击SVN Checkou下拉项目

右击项目可以comit和git区别不用再push

右击项目TortoiseSvn,Banrch/tag创建分支

在项目路径下右击tortoiseSVN->properties->new other,选global ignore填选项  

可以添加类似以下内容
>*.gradle  
*.idea  
*.iml  
build  

<!-- <https://developer.aliyun.com/article/652579>  
<https://www.zhihu.com/question/36509119> -->
