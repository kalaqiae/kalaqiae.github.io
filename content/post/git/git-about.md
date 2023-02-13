---
title: "git,svn 使用"
date: 2021-04-05T18:53:42+08:00
draft: false
tags: ["git"]
categories: ["git"]
---

## git 常用命令

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

### rebase 和 merge 区别

merge 是合并的意思，rebase是复位基底的意思

merge 操作会生成一个新的节点，之前提交分开显示。而 rebase 操作不会生成新的节点，是将两个分支融合成一个线性的操作

简单的说，merge 会保留更多信息，处理冲突方便，rebase只有一条线看的更清晰，方便回滚

可以先 rebase，如果有冲突，git rebase --abort，再换用 merge

### 克隆

>git clone 路径

### 撤销 commit

找到想要撤销的 id  
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

### 查看远程仓库地址

>git remote -v

### git 合并某次提交到其他分支

android studio 有 cherry-pick 的功能，或者用命令  
git log 查看提交历史，复制出需要的 commit 编号，git checkout xx 切换到 xx 分支，执行 git cherry-pick 编号，有冲突就解决后 git push

### 配置信息

查看是否存在现有的 SSH 密钥  
打开 git bush 输入 ls -al ~/.ssh

生成 ssh  
ssh-keygen -t ed25519 -C "your_email@example.com"

查看用户名,邮箱等信息  
git config --global --list

设置用户名,邮箱  
git config --global user.name "your_name"  
git config --global user.email "your_email@example.com"

打开 GIT GUI 点击 help 也可以查看 ssh

ssh 路径一般在 C:\Users\Administrator\.ssh

[生成新的 SSH 密钥](https://docs.github.com/zh/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

## SVN 使用

工具 TortoiesSVN

在文件夹右击 repo-browser 可以查看项目

右击 SVN Checkout 下拉项目

右击项目可以 commit 和 git 区别不用再 push

右击项目 TortoiseSvn,Branch/tag 创建分支

在项目路径下右击 tortoiseSVN->properties->new other,选 global ignore 填选项  

可以添加类似以下内容
>*.gradle  
*.idea  
*.iml  
build  

<!-- <https://developer.aliyun.com/article/652579>  
<https://www.zhihu.com/question/36509119> -->
