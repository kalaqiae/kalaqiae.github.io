---
title: "Android adb 命令"
date: 2021-04-04T21:06:02+08:00
draft: false
tags: ["Android","adb"]
categories: ["Android"]
---

AS 插件 ADB IDEA  
pm 是 packagemanager 缩写, am 是 activitymanager 缩写  
[Android 调试桥 (adb)](https://developer.android.com/studio/command-line/adb?hl=zh-cn)  
[awesome-adb](https://github.com/mzlogin/awesome-adb)  

### 查看 Activity Task 栈的情况

>adb shell dumpsys activity

当前显示的 activity ，用 findstr 或 grep 过滤

>adb shell dumpsys activity | findstr "mFocusedActivity"  
效果等同  
adb shell "dumpsys activity | grep mFocusedActivity"  
8.0以上用  
adb shell dumpsys activity | findstr "mResumedActivity"

<!--more-->

### 日志

输出 tag ActivityManager 的 I 以上级别日志，输出tag MyApp的D 以上级别日志，及其它 tag 的 S 级别日志（即屏蔽其它 tag 日志）
>adb logcat ActivityManager:I MyApp:D *:S

输出到某个路径
>adb logcat > C:\Users\Administrator\Desktop\log\logcat.log

### 连接设备

>adb connect ip

### 断开设备

>adb disconnect ip

### 安装应用

>adb install path_to_apk  
eg. adb install C:\Users\Administrator\Desktop\debug.apk  
-r 重新安装现有应用，并保留其数据  
-t 允许安装测试 APK

### 卸载应用

>adb uninstall options package  
eg. adb uninstall -k com.example.application  
-k：移除软件包后保留数据和缓存目录

### 从设备复制文件

>adb pull remote local  
eg. adb pull /mnt/sdcard/kalaqiae C:/Users/Administrator/Desktop

### 将文件复制到设备

>adb push local remote  
eg. adb push C:\Users\Administrator\Desktop\temp /sdcard/kalaqiae

### 开启服务

>adb start-server

### 关闭服务

>adb kill-server

### 查看连接设备列表

>adb devices

### 多设备时调试

* 先 adb devices 查看设备得到 serial number，结果如 40019ae07d34    device
* adb -s serial number cmd 例如 adb -s 40019ae07d34 install path_to_apk

### 清数据

>adb shell pm clear packagename  

### 重启

>adb reboot

### 查看应用包名

>adb shell pm list packages

* packages 后可加参数，不加则查看全部应用
* 查看包名包含某字符串的应用，如 adb shell pm list packages tencent
* -s，系统应用
* -3，第三方应用

### 操作数据库

先找到数据库路径，再 sqlite3 数据库名，然后执行相关语句
>adb shell  
su  
cd /data/data/com.test.core/databases //数据库路径  
sqlite3 DbName.db //数据库名  
sqlite> .tables  
OPTION_INFO  
sqlite> select * from OPTION_INFO; //要加分号  
select option_value from OPTION_INFO where option_name="ShowSex";  
insert into OPTION_INFO(Option_Name,Option_Value) values('ShowAge','1');  
update OPTION_INFO set option_value='0' WHERE option_name="ShowSex";  

### 更改读写权限

1. adb shell 进去手机端
2. $ 代表是普通用户权限
3. su 进去 root 权限  $ 变成 #
4. chmod -R 777 /data/local
5. exit exit 退出来 ctrl D==exit 退到上一级
6. adb push xxx /data/local

### 删除文件

例子
>adb shell  
\#su  
\#cd system/sd/data //进入系统内指定文件夹  
\#ls //列表显示当前文件夹内容  
\#rm -r xxx //删除名字为xxx的文件夹及其里面的所有文件  
\#rm xxx //删除文件xxx  
\#rmdir xxx //删除xxx的文件夹

cd .. 返回
cat 查看文件内容

### adb shell dumpsys

可以查看一些系统信息，如内存，通知，网络，输入等  
adb shell dumpsys > D:\log\alllogcat.txt
adb shell dumpsys notification > D:\log\alllogcat.txt

### debug 异常

Warning: debug info can be unavailable.Please close other application using ADB: Monitor, DDMS, Eclipse

adb usb

### 启动停止应用

>adb shell monkey -p com.example.app -c android.intent.category.LAUNCHER 1
adb shell am force-stop com.example.app

### 启动 Activity

启动 activity 需要 android:exported="true"

adb shell am start -n com.example.app/.MainActivity --es "params" "hello, world"

-n 指定带有软件包名称前缀的组件名称，以创建显式 intent  
es extra_key extra_string_value 以键值对的形式添加字符串数据，还有 ei el ef ez 等  

### 启动 Service

adb shell am startservice -n com.example.app/.ExampleService

停止服务  

adb shell am stopservice -n com.example.app/.ExampleService

### 发送广播

adb shell am broadcast -a android.net.wifi.STATE_CHANGE  

-a 表示 action  

测试时发现要权限，报 Permission Denial: not allowed to send broadcast  

### 模拟按键/输入/滑动/点击

>adb shell
input keyevent 3
input text Hello
input swipe 300 1000 300 500
input tap 500 500

keyevent 3 是点击 home 键，更多可以看 [keyevent](https://developer.android.com/reference/android/view/KeyEvent)

input text 获取到输入框焦点时可以输入文本，adb 默认不支持 Unicode 编码，所以无法 input 中文，可以下载安装 [ADBKeyBoard](https://github.com/senzhk/ADBKeyBoard)

input swipe 滑动(300,1000) 到 (300,500)

### 设置

>adb shell
settings list global
settings list system
settings list secure
settings put system screen_off_timeout 600000

system 系统设置， global 全局系统设置， secure 安全系统设置，只读不能写

安卓 5 及以前 设置的值用 database 保存，从 6 开始保存在 settings_global.xml ， settings_secure.xml ， settings_system.xml ，路径在 /data/system/users/0

```java
//获取 miui 优化开关状态
Settings.Secure.getInt(context.getContentResolver(), "miui_optimization", 0);
```

### 截屏录屏

截屏  
adb exec-out screencap -p > test.png  
或  
adb shell screencap /sdcard/test.png  
adb pull /sdcard/test.png ./  
录屏  
adb shell screenrecord  --time-limit 10 /sdcard/test.mp4  
adb pull /sdcard/demo.mp4  
截屏保存到电脑还有这个方法，试了半天图片格式还是有问题，暂时记录一下  
adb shell screencap -p | sed 's/\r$//' > screen.png

### 查看分辨率和密度

修改分辨率需要 root 权限

>adb shell wm size  
adb shell wm density
adb shell wm size 1080x1920

### 获取撤销权限

要求6.0以上，可能会报错 SecurityException ，需要在开发者选项里开启禁止权限监控

>adb shell pm grant com.example.app android.permission.READ_PHONE_STATE  
adb shell pm revoke com.example.app android.permission.READ_PHONE_STATE

### 退出 adb shell

输入 exit 或者 ctrl + D

### adb shell dumpsys activity top

查出顶部 activity 后，可以搜索查看 activity 的布局,比如搜 DecorView

### 隐藏和显示状态栏

需要 root

>adb shell settings put global policy_control immersive.status=*  
adb shell settings put global policy_control null
