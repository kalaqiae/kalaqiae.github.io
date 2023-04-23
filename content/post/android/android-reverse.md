---
title: "Android Reverse"
date: 2023-04-23T15:54:24+08:00
draft: true
tags: ["Android","Reverse"]
categories: ["Android"]
---

[JADX](https://github.com/skylot/jadx)

[AndroidKiller](https://down.52pojie.cn/Tools/Android_Tools/AndroidKiller_v1.3.1.zip)

[apktool](https://ibotpeaches.github.io/Apktool/)

<!--more-->

### JADX

Command line and GUI tools for producing Java source code from Android Dex and Apk files

### AndroidKiller

AndroidKiller 默认的 apktool 版本比较旧，需要替换，直接改名替换路径下里 AndroidKiller_v1.3.1\bin\apktool\apktool\ShakaApktool.jar 或修改 bin\apktool 下的 apktool.bat 和 apktool.ini

修改 smali ，重新打包,记得保存修改才生效

最上面一排选 Android ，点击编译就可以重新编译签名，编译按钮下有个小三角，改为 AndroidKiller，否则会报错 java.lang.ClassNotFoundException: sun.misc.BASE64Encoder

### Other

jd-gui dex2jar 个人觉得不太好用

[基础](https://www.anquanke.com/post/id/273348#h2-8)
