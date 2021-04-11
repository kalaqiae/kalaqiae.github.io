---
title: "Activity的生命周期"
date: 2021-03-31T22:34:15+08:00
draft: false
tags: ["Android","Activity","Lifecycle"]
categories: ["Android"]
---

## 生命周期简介

先上图

![Lifecycle](https://developer.android.google.cn/guide/components/images/activity_lifecycle.png)

<!--more-->

(1)onCreate:表示Activity正在被创建

(2)onStart:表示Activity正在被启动

(3)onResume:表示Activity已经可见

(4)onPause:表示Activity正在停止

(5)onStop:表示Activity即将停止

(6)onDestory:表示Activity即将被销毁

(7)onRestart:表示Activity正在重新启动

<!-- ## 场景

页面跳转，锁屏

## 异常情况下的生命周期

横竖屏切换，内存不足 -->
