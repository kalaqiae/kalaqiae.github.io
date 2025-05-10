---
title: "Issue"
date: 2021-05-29T11:28:02+08:00
draft: true
tags: ["Undefined"]
categories: ["Undefined"]
---

### Warning: debug info can be unavailable.Please close other application using ADB: Monitor, DDMS, Eclipse

adb usb

<!--more-->

### at com.google.common.base.Preconditions.checkNotNull

https://blog.csdn.net/ysc123shift/article/details/118016309  
local.properties配置nkd.dir 还有可能是ndk版本问题

### All flavors must now belong to a named flavor dimension. Learn more at https://d.android.com/r/tools/flavorDimensions-missing-error-message.html

配置 productFlavors 时报错。需要配置 flavorDimensions 。可以如下配置,就能打出 x86V1 或 x86V2 的包。如果不需要可以 flavorDimensions 'default' , dimension 都用 'default'

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

### json解析报错 返回对象为okhttp3.internal.http.RealResponseBody

将 response.body().toString() 改为 response.body().string()

### Caused by: org.gradle.api.internal.plugins.PluginApplicationException: Failed to apply plugin 'com.android.internal.application

项目路径有中文，用英文路径或在 gradle.properties 文件中添加 android.overridePathCheck=true

### Android 请求网络出现 CLEARTEXT communication to api.tianapi.com not permitted by network security policy

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

### invoke null receiver

反射的时候 try catch 捕获的异常，类没实例化，或者调用静态方法就不会

### Expected the adapter to be 'fresh' while restoring state

使用 viewpager2 嵌套 fragment 时报错  viewpager2 设置 android:saveEnabled="false"

[android在使用viewpager嵌套fragmrnt的时候出现Expected the adapter to be ‘fresh‘ while restoring state](https://blog.csdn.net/ShiXinXin_Harbour/article/details/118413458)

### java.lang.IllegalArgumentException: (Wrong state class, expecting View State but received class androidx.recyclerview.widget.RecyclerView$SavedState instead. This usually happens when two views of different type have the same id in the same hierarchy. This view's id is id/0x1.Make sure other views do not use the same id

viewpager2 1.0.0版本，在 onRestoreInstanceState 方法中报错，也可能是有自定义控件动态有 addview 导致，可以 try catch 捕获，或者手动赋值 id

https://issuetracker.google.com/issues/185820237  
https://stackoverflow.com/questions/37113031/wrong-state-class-expecting-view-state-but-received-class-android-widget-compou

### firebase google-services.json 包名不同问题

```groovy
android {
    //修改 build，在 src 的不同路径新建对应的 google-services.json ，根据条件不同复制到根目录下
    if (rootProject.ext.type) {
        copy {
            from 'src/release/'
            include '*.json'
            into '.'
        }
    } else {
        copy {
            from 'src/debug/'
            include '*.json'
            into '.'
        }
    }
}
```

### kotlin 中 TextUtils.isEmpty() 找不到类

不会报错，但是 debug 时会报 TextUtils 未初始化，获取不到值，可以用 isNullOrEmpty() 代替

### 多语言失效问题

更改语言设置，后台结束应用重开应用未生效，Android studio 再运行一遍又正常了，清了数据更改语言设置，其实还是会失效，或走开屏广告的流程也会正常生效，没找到这两个会生效的原因

问题是要适配 Androidx ，attachBaseContext() 包装了一层 ContextThemeWrapper

修改如下

```java
@Override
    protected void attachBaseContext(Context newBase) {
        //需要切换的语言
        Context context = AppUtilsKtx.Companion.getAttachBaseContext(newBase);
        final Configuration configuration = context.getResources().getConfiguration();
        // 此处的ContextThemeWrapper是androidx.appcompat.view包下的
        // 你也可以使用android.view.ContextThemeWrapper，但是使用该对象最低只兼容到API 17
        // 所以使用 androidx.appcompat.view.ContextThemeWrapper省心
        final ContextThemeWrapper wrappedContext = new ContextThemeWrapper(context,
            R.style.Theme_AppCompat_Empty) {
            @Override
            public void applyOverrideConfiguration(Configuration overrideConfiguration) {
                if (overrideConfiguration != null) {
                    overrideConfiguration.setTo(configuration);
                }
                super.applyOverrideConfiguration(overrideConfiguration);
            }
        };
        super.attachBaseContext(wrappedContext);
        //super.attachBaseContext(AppUtilsKtx.Companion.getAttachBaseContext(newBase));
    }
```

### 使用 walle 生产的渠道包加固后获取不到渠道信息

[python 多渠道打包](https://www.freesion.com/article/3733762873/)

<!-- * umeng -->