---
title: "常用镜像"
date: 2021-04-07T20:59:09+08:00
draft: false
tags: ["Mirror"]
categories: ["Mirror"]
---

### Android

按顺序写  public包含central和jcenter
>maven { url 'https://maven.aliyun.com/repository/public' }  
maven { url 'https://maven.aliyun.com/repository/google' }  
maven { url 'https://maven.aliyun.com/repositories/jcenter' }  
maven{ url 'https://maven.aliyun.com/repository/gradle-plugin'}
google()  
jcenter()

[阿里云云效 Maven](https://developer.aliyun.com/mvn/guide)

<!--more-->

（1）官网地址：https://services.gradle.org/distributions/  
（2）腾讯镜像 Gradle下载地址：https://mirrors.cloud.tencent.com/gradle/  
（3）阿里云镜像 Gradle下载地址：https://mirrors.aliyun.com/macports/distfiles/gradle/

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

>npm --registry https://registry.npmmirror.com install express

#### 持久使用

>npm config set registry https://registry.npmmirror.com
npm config list

淘宝的镜像换了，用旧的会有证书过期问题

#### 获取配置镜像地址

>npm get registry

#### 还原默认

>npm config set registry https://registry.npmjs.org  
或删除恢复默认镜像  
npm config delete registry

#### 或通过cnpm使用

>npm install -g cnpm --registry=https://registry.npm.taobao.org  
使用cnpm代替npm

### python

设置  
>pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

验证  
>pip config list

恢复  
>pip config unset global.index-url

<!-- 参考:  
<https://developer.aliyun.com/article/754038>  
<https://flutter.cn/community/china>  
<https://segmentfault.com/a/1190000038458140> -->
