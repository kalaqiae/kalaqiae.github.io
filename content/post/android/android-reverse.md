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

平常可以用 JADX 看，用 AndroidKiller 改  
apktool 可以反编译得到 smali 文件等  
dex2jar 可以将 classes.dex 转化成 classes_dex2jar.jar 文件  
jd-gui 查看 classes_dex2jar.jar 文件内的源码  
重新签名打包分别用到 keystore jarsigner ，安装 Java 环境就有，Android SDK 中的 apksigner 执行 v1、v2   v3 签名，具体没试过可以直接用 AndroidKiller  
在 Android 7.0 及以上的版本中，默认签名工具从 jarsigner 切换到了 apksigner

[逆向基础](https://www.anquanke.com/post/id/273348)

[Android Studio debug 调试 Smali 代码](https://blog.csdn.net/PLA12147111/article/details/98179217)

[Smali 基础](https://juejin.cn/post/7020960576666861576)

[apktool 简单使用](https://juejin.cn/post/7216968724938195001)
