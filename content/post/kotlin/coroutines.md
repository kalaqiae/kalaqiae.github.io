---
title: "Kotlin 协程"
date: 2021-04-09T23:14:11+08:00
draft: false
tags: ["Kotlin","coroutines"]
categories: ["Kotlin"]
---

## 协程启动

```kotlin
GlobalScope.launch {
    delay(1000L)
    println("Hi,coroutines!")
}
```

<!--more-->

| 模式         | 功能                                           |
| :------------|:----------------------------------------------|
| DEFAULT      | 立即执行协程体                                 |
| ATOMIC       | 立即执行协程体，但在开始运行之前无法取消          |
| UNDISPATCHED | 立即在当前线程执行协程体，直到第一个 suspend 调用 |
| LAZY         | 只有在需要的情况下运行 |

## 协程调度器

确定了相关的协程在哪个线程或哪些线程上执行

* Dispatchers.Default  
未指定时都是默认使用Dispatchers.Default，运行在父协程的上下文中
* Dispatchers.Main  
主线程
* Dispatchers.Unconfined  
直接执行（eg. 当前在主线程就在主线程执行，如果启动子线程导致切换线程，就在切换的那个线程执行），不被限制在任何特定的线程，一般不使用
* Dispatchers.IO  
基于 Default 调度器背后的线程池，并实现了独立的队列和限制，因此协程调度器从 Default 切换到 IO 并不会触发线程切换
