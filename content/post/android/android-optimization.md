---
title: "APK 瘦身"
date: 2021-05-06T21:35:21+08:00
draft: false
tags: ["Android","优化"]
categories: ["Android"]
---

## 减少 res 资源大小

* 删除重复资源  
右击项目 refactor/remove unused resources ,或 lint 工具来搜索项目中不再使用的图片等资源

* 重复资源优化  
文件名不一样，但是内容一样的图片，可以通过比较 md5 值来判断是不是一样的资源，然后编辑 resources.arsc 来重定向

<!--more-->

* 图片压缩  
可以用 [tinypng](https://tinypng.com/) 等工具

* 资源混淆  
通过将资源路径 res/drawable/wechat 变为 r/d/a 的方式来减少 apk 的大小，当 apk 有较多资源项的时候，效果比较明显，这是一款微信开源的工具，详细地址是：[AndResGuard](https://github.com/shwenzhang/AndResGuard)

* 指定语言  
如果没有的需求的话，可以只编译中文，如果用不上的语言编译了，会在 resource 的表里面占用大量的空间

```Groovy
android {
    defaultConfig {
        resConfigs "zh"
    }
}
```

## 减少 so 库资源大小

* 只编译指定平台的 so  

```Groovy
android {
    defaultConfig {
        ndk {
            abiFilter "armeabi"
        }
    }
}
```

* 自己编译的 so  
release 包的 so 中移除调试符号。可以使用 Android NDK 中提供的 arm-eabi-strip 工具从原生库中移除不必要的调试符号。
如果是 cmake 来编译的话，可以再编辑脚本添加如下代码

>set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -s")  
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -s")

* 动态下发 so
通过服务器下发 so , 下载完后再进入应用，但是体验不好，但是是一个思路

## 减少代码资源大小

* 混淆  
可以减少生成class的大小

* R文件内联  
通过把 R 文件里面的资源内联到代码中，从而减少 R 文件的大小  
通过[shrink-r-plugin](https://github.com/bytedance/ByteX/blob/master/shrink-r-plugin/README-zh.md)工具来做 R 文件的内联
