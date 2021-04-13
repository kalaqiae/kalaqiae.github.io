---
title: "Android strings.xml使用"
date: 2021-04-01T10:30:04+08:00
draft: false
tags: ["Android","xml"]
categories: ["Android"]
---

## 设置字符串格式

```xml
<string name="welcome_messages">Hi, %1$s! You have %2$d new messages.</string>  
```

```kotlin
var text = getString(R.string.welcome_messages, "kalaqiae", 10)  
```

输出：Hi, kalaqiae! You have 10 new messages.  

%d （表示整数）  
%f （表示浮点数）  
%s （表示字符串）

<!--more-->

## 字符串数组

```xml
<string-array name="planets_array">  
    <item>Mercury></item>  
    <item>Venus></item>  
    <item>Earth></item>  
    <item>Mars></item>  
</string-array>
```

```kotlin
val array: Array = resources.getStringArray(R.array.planets_array)
```

## 复数

支持以下完整集合：zero、one、two、few、many 和 other

```xml
<plurals name="numberOfSongsAvailable">
    <item quantity="one">%d song available.</item>
    <item quantity="other">%d songs available.</item>
</plurals>
```

```kotlin
val count = getNumberOfSongsAvailable()
val songsFound = resources.getQuantityString(R.plurals.numberOfSongsAvailable, count, count)
```

<!-- 参考：  
<https://developer.android.com/guide/topics/resources/string-resource>  
<https://www.jianshu.com/p/ea5f8713c9a3> -->
