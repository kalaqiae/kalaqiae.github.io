---
title: "Android adb命令"
date: 2021-04-04T21:06:02+08:00
draft: false
tags: ["Android","adb"]
categories: ["Android"]
---

AS插件ADB IDEA

## 连接设备

>adb connect ip

<!--more-->

## 断开设备

>adb disconnect  ip

## 安装应用

>adb install path_to_apk  
eg. adb install C:\Users\Administrator\Desktop\debug.apk  
-r 重新安装现有应用，并保留其数据  
-t 允许安装测试 APK

## 卸载应用

>adb uninstall options package  
eg. adb uninstall -k com.example.application  
-k：移除软件包后保留数据和缓存目录

## 从设备复制文件

>adb pull remote local  
eg. adb pull /mnt/sdcard/kalaqiae C:/Users/Administrator/Desktop

## 将文件复制到设备

>adb push local remote  
eg. adb push C:\Users\Administrator\Desktop\temp /sdcard/kalaqiae

## 查看Activity Task栈的情况

>adb shell dumpsys activity | findstr Run

## 开启服务

>adb start-server

## 关闭服务

>adb kill-server

## 查看连接设备列表

>adb devices

## 清数据

>adb shell pm clear packagename

## 重启

>adb reboot
