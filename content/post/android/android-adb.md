---
title: "Android adb命令"
date: 2021-04-04T21:06:02+08:00
draft: false
tags: ["Android","adb"]
categories: ["Android"]
---

AS插件ADB IDEA

### 查看Activity Task栈的情况

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

### 查看 Activity Task 栈的情况

>adb shell dumpsys activity

当前显示的 activity ，加条件

>adb shell dumpsys activity | findstr "mFocusedActivity"  
效果等同  
adb shell "dumpsys activity | grep mFocusedActivity"  
8.0以上用  
adb shell dumpsys activity | findstr "mResumedActivity"

当前允许的 activity
adb shell dumpsys activity | findstr Run

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
pm 是 packagemanager 缩写

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

adb shell dumpsys > D:\log\alllogcat.txt
adb shell dumpsys notification > D:\log\alllogcat.txt

[awesome-adb](https://github.com/mzlogin/awesome-adb)
[developer adb](https://developer.android.com/studio/command-line/adb)

### debug 异常
Warning: debug info can be unavailable.Please close other application using ADB: Monitor, DDMS, Eclipse

adb usb
