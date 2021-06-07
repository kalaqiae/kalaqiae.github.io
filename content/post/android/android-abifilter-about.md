---
title: "Android abiFilter相关"
date: 2021-04-22T21:48:37+08:00
draft: false
tags: ["Android","ABI","优化"]
categories: ["Android"]
---

为了优化apk的大小，一般会只选择支持一种ABI，可以在AS中双击apk，在lib路径下查看so文件占用大小

### Android ABI概念

Application Binary Interface [官方文档](https://developer.android.com/ndk/guides/abis?hl=zh-cn)

### cpu架构选择

* arm64-v8a 作为最新一代架构，应该是目前的主流  
* 兼容性越好，则性能越差。兼容性：armeabi>armeabi-v7a>arm64-v8a  
* armeabi armeabi-v7a arm64-v8a 按顺序向下兼容  
举个栗子：  
armeabi 兼容 armeabi-v7a arm64-v8a  
arm64-v8a 不兼容 armeabi armeabi-v7a

```Groovy
android {
    defaultConfig {
        ndk {
            abiFilter "armeabi"
        }
    }
}
```

### 流程

![ABI流程](https://cdn.jsdelivr.net/gh/kalaqiae/picBank/img/find_abi.png)

对于一个cpu是arm64-v8a架构的手机，它运行app时，进入jnilibs去读取库文件时，先看有没有arm64-v8a文件夹，如果没有该文件夹，去找armeabi-v7a文件夹，如果没有，再去找armeabi文件夹，如果连这个文件夹也没有，就抛出异常；

如果有arm64-v8a文件夹，那么就去找特定名称的.so文件，注意：如果没有找到想要的.so文件，不会再往下（armeabi-v7a文件夹）找了，而是直接抛出异常。

### 小孩才做选择，我全都要

ABI 配置多个 APK，[官方文档](https://developer.android.com/studio/build/configure-apk-splits)  
部分应用市场支持上传多个apk，比如谷歌

```Groovy
android {
  ...
  splits {

    // Configures multiple APKs based on ABI.
    abi {

      // Enables building multiple APKs per ABI.
      enable true

      // By default all ABIs are included, so use reset() and include to specify that we only
      // want APKs for x86 and x86_64.

      // Resets the list of ABIs that Gradle should create APKs for to none.
      reset()

      // Specifies a list of ABIs that Gradle should create APKs for.
      include "armeabi", "armeabi-v7a", "arm64-v8a"

      // Specifies that we do not want to also generate a universal APK that includes all ABIs.
      universalApk false
    }
  }
}
```

### 其他

* 如果仅保留armeabi-v7a，而有些第三方包未提供v7a的包，可以尝试将对应armeabi包拷贝到armeabi-v7a

<!-- https://segmentfault.com/a/1190000023517574 -->
