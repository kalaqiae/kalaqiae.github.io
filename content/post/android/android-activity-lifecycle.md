---
title: "Activity 的生命周期"
date: 2021-03-31T22:34:15+08:00
draft: false
tags: ["Android","Activity","Lifecycle"]
categories: ["Android"]
---

### 生命周期简介

先上图

![Lifecycle](https://developer.android.google.cn/guide/components/images/activity_lifecycle.png)

<!--more-->

(1)onCreate:表示 Activity 正在被创建，一般这时加载布局，初始化操作，恢复异常结束时 Activity 数据等

(2)onStart:表示 Activity 正在被启动，这时 Activity 已经出现，但是还没出现在前台。可以理解为已经显示出来，但是还看不到。不要进行耗时操作，会影响到 Activity 的显示

(3)onResume:表示 Activity 已经可见，应用与用户互动的状态

(4)onPause:表示 Activity 正在停止但仍可见，不要进行耗时操作，会影响到 Activity 的显示。onPause() 必须执行完，新的 Activity 的 onResume() 才会执行

(5)onStop:表示 Activity 即将停止，不可见，位于后台，可以做稍微重量级的回收工作，不能太耗时

(6)onDestory:表示 Activity 即将被销毁，做一些回收工作和最终的资源回收

(7)onRestart:表示 Activity 正在重新启动， Activity 从不可见重新变为可见状态时调用。

<!-- ## Activity 状态 -->

<!-- ## 场景

页面跳转，锁屏

## 异常情况下的生命周期

横竖屏切换，内存不足 -->
