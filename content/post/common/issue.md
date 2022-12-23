---
title: "Issue"
date: 2021-05-29T11:28:02+08:00
draft: true
tags: ["Undefined"]
categories: ["Undefined"]
---

### Android

#### at com.google.common.base.Preconditions.checkNotNull

https://blog.csdn.net/ysc123shift/article/details/118016309  
local.properties配置nkd.dir 还有可能是ndk版本问题

<!--more-->

#### All flavors must now belong to a named flavor dimension. Learn more at https://d.android.com/r/tools/flavorDimensions-missing-error-message.html

配置 productFlavors 时报错。需要配置 flavorDimensions 。可以如下配置,就能打出 x86V1 或 x86V2 的包。如果不需要可以 flavorDimensions 'default' ， dimension 都用 'default'

```gradle
android{
    flavorDimensions('abi', 'version')

    // 创建产品风味
    productFlavors {
        v1 {
            // 关联纬度
            dimension 'version'
        }

        v2 {
            dimension 'version'
        }

        v3 {
            dimension 'version'
        }

        x86 {
            dimension 'abi'
        }

        armV7 {
            dimension 'abi'
        }
    }
}
```

https://juejin.cn/post/6844903968204652551

#### json解析报错 返回对象为okhttp3.internal.http.RealResponseBody

将 response.body().toString() 改为 response.body().string()

#### Caused by: org.gradle.api.internal.plugins.PluginApplicationException: Failed to apply plugin 'com.android.internal.application

项目路径有中文，用英文路径或在 gradle.properties 文件中添加 android.overridePathCheck=true

#### Android 请求网络出现 CLEARTEXT communication to api.tianapi.com not permitted by network security policy

创建文件 res/xml/network_security_config.xml,修改 AndroidManifest.xml application 中添加属性 android:networkSecurityConfig="@xml/network_security_config"

```xml
<network-security-config>
    <debug-overrides>
        <trust-anchors>
            <!-- Trust user added CAs while debuggable only -->
            <certificates src="user" />
            <certificates src="system" />
        </trust-anchors>
    </debug-overrides>
    <base-config cleartextTrafficPermitted="true" />
</network-security-config>
```

[参考](https://blog.csdn.net/qq_42609613/article/details/108278797)

#### invoke null receiver

反射的时候 try catch 捕获的异常，类没实例化，或者调用静态方法就不会

#### Warning: debug info can be unavailable.Please close other application using ADB: Monitor, DDMS, Eclipse

adb usb

#### Expected the adapter to be 'fresh' while restoring state

使用 viewpager2 嵌套 fragment 时报错  viewpager2 设置 android:saveEnabled="false"

[android在使用viewpager嵌套fragmrnt的时候出现Expected the adapter to be ‘fresh‘ while restoring state](https://blog.csdn.net/ShiXinXin_Harbour/article/details/118413458)

#### java.lang.IllegalArgumentException: (Wrong state class, expecting View State but received class androidx.recyclerview.widget.RecyclerView$SavedState instead. This usually happens when two views of different type have the same id in the same hierarchy. This view's id is id/0x1.Make sure other views do not use the same id

viewpager2 1.0.0版本，在 onRestoreInstanceState 方法中报错，也可能是有自定义控件动态有 addview 导致，可以 try catch 捕获，或者手动赋值 id

https://issuetracker.google.com/issues/185820237  
https://stackoverflow.com/questions/37113031/wrong-state-class-expecting-view-state-but-received-class-android-widget-compou

<!-- * umeng -->