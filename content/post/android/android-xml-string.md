---
title: "Android strings.xml使用"
date: 2021-04-01T10:30:04+08:00
draft: false
tags: ["Android","xml"]
categories: ["Android"]
---

## 设置字符串格式

>&lt;string name="welcome_messages">Hi, %1$s! You have %2$d new messages.&lt;/string>  
var text = getString(R.string.welcome_messages, "kalaqiae", 10)  

输出：Hi, kalaqiae! You have 10 new messages.  

%d （表示整数）  
%f （表示浮点数）  
%s （表示字符串）

<!--more-->

<!-- 参考：  
<https://developer.android.com/guide/topics/resources/string-resource>  
<https://www.jianshu.com/p/ea5f8713c9a3> -->
