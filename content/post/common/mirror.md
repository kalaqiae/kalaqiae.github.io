---
title: "常用镜像"
date: 2021-04-07T20:59:09+08:00
draft: false
tags: ["Mirror"]
categories: ["Mirror"]
---

### Android

按顺序写  
>maven { url 'https://maven.aliyun.com/repository/public/' }  
maven { url 'https://maven.aliyun.com/repository/google' }  
maven { url 'https://maven.aliyun.com/repositories/jcenter' }  
google()  
jcenter()

<!--more-->

### Flutter

推荐用社区或清华的

Flutter 社区  
>export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

上海交大 Linux 用户组  
>export PUB_HOSTED_URL=https://mirrors.sjtug.sjtu.edu.cn/dart-pub  
export FLUTTER_STORAGE_BASE_URL=https://mirrors.sjtug.sjtu.edu.cn

清华大学 TUNA 协会  
>export PUB_HOSTED_URL=https://mirrors.tuna.tsinghua.edu.cn/dart-pub  
export FLUTTER_STORAGE_BASE_URL=https://mirrors.tuna.tsinghua.edu.cn/flutter

OpenTUNA  
>export PUB_HOSTED_URL=https://opentuna.cn/dart-pub  
export FLUTTER_STORAGE_BASE_URL=https://opentuna.cn/flutter

腾讯云开源镜像站  
>export PUB_HOSTED_URL=https://mirrors.cloud.tencent.com/dart-pub  
export FLUTTER_STORAGE_BASE_URL=https://mirrors.cloud.tencent.com/flutter

CNNIC  
>export PUB_HOSTED_URL=http://mirrors.cnnic.cn/dart-pub  
export FLUTTER_STORAGE_BASE_URL=http://mirrors.cnnic.cn/flutter

### NPM

#### 临时使用

>npm --registry https://registry.npm.taobao.org install express

#### 持久使用

>npm config set registry https://registry.npm.taobao.org
npm config list

#### 获取配置镜像地址

>npm get registry

#### 还原默认

>npm config set registry https://registry.npmjs.org  
或删除恢复默认镜像  
npm config delete registry

#### 或通过cnpm使用

>npm install -g cnpm --registry=https://registry.npm.taobao.org  
使用cnpm代替npm

<!-- 参考:  
<https://developer.aliyun.com/article/754038>  
<https://flutter.cn/community/china>  
<https://segmentfault.com/a/1190000038458140> -->
