---
title: "Android Jetpack Compose"
date: 2022-05-13T16:16:21+08:00
draft: true
tags: ["Jetpack","Compose"]
categories: ["Jetpack"]
---

### 其他

 在 Android studio 中， Ctrl+H  查看继承关系， Alt+7（Ctrl + F12 或点击左侧边栏的 Structure 按钮） 查看结构信息，可以看到 ComposeView 继承 AbstractComposeView 继承 ViewGroup

[原理](https://juejin.cn/post/6966241418046078983#heading-0)

没有 margin ，可以设置两次 padding ，顺序在前是 margin

Row 行 Column 列 Box 类似 FrameLayout , ConstraintLayout 要另外导入依赖, Surface 类似一个容器, @Composable 类似 协程里的 suspend

最低要求 Android 5

[将 Compose 与现有界面集成](https://developer.android.com/jetpack/compose/interop/compose-in-existing-ui#shared-ui)

compose multiplatform 跨平台

[Compose 与 Kotlin 的兼容性对应关系](https://developer.android.com/jetpack/androidx/releases/compose-kotlin)
