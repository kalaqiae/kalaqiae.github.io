---
title: "Android 事件分发"
date: 2021-05-06T21:36:48+08:00
draft: false
tags: ["Android","事件分发"]
categories: ["Android"]
---

## 概要

![touch](https://cdn.jsdelivr.net/gh/kalaqiae/picBank/img/touch.png)

 注意看左下角方法所属

当一个点击事件（MotionEvent ）产生后，系统需把这个事件传递给一个具体的 View 去处理

一次完整的 MotionEvent 事件：ACTION_DOWN(1次) -> ACTION_MOVE(N次) -> ACTION_UP(1次)

顺序 Activity -> ViewGroup -> View

<!--more-->

dispatchTouchEvent 和 onTouchEvent 一旦return true,事件就停止传递了（到达终点）

dispatchTouchEvent 和 onTouchEvent return false 的时候事件都回传给父控件的 onTouchEvent 处理

如果没有重写或者更改默认值。按 Activity > ViewGroup > View 顺序调用 dispatchTouchEvent方法一层层往下分发  
进入最底层的View后，开始由最底层的 OnTouchEvent 来处理，如果一直不消费按 View > ViewGroup > Activity 顺序从下往上调用 onTouchEvent ，最后返回到Activity.OnTouchEvent

ViewGroup 的 dispatchTouchEvent 返回 true 则事件被消费，返回 false 则回传给父控件的 onTouchEvent，__只能通过 Interceptor 把事件拦截下来给自己的 onTouchEvent ，所以 ViewGroup dispatchTouchEvent 方法的 super 默认实现就是去调用 onInterceptTouchEvent。__ onInterceptTouchEvent 默认不拦截

| 方法                    | 作用                      | 调用时刻
| :-----------------------|:--------------------------|:------------|
| dispatchTouchEvent()    | 分发（传递）点击事件        | 当点击事件能够传递给当前 View 时                 |
| onInterceptTouchEvent() | 事件拦截，只有 ViewGroup 有 | 在 ViewGroup 的 dispatchTouchEvent() 内部调用  |
| onTouchEvent()          | 处理点击事件               | 在 dispatchTouchEvent() 内部调用               |

## ACTION_MOVE 和 ACTION_UP

在 onTouchEvent 消费事件时：在哪个 View onTouchEvent 返回 true，ACTION_MOVE 和 ACTION_UP 的事件从上往下传到这个 View 后就不再往下传递了，直接传给那个 View 的 onTouchEvent 并结束本次事件传递过程。（包括拦截也是走到 onTouchEvent ）

在 dispatchTouchEvent 消费事件时：和 ACTION_DOWN 一样

## 其他

* onTouch() 优先于 onTouchEvent 执行,若手动复写在 onTouch() 中返回 true（即 将事件消费掉），将不会再执行 onTouchEvent()

* onTouch（）的执行 先于 onClick（）

* 事件不一定会经过Activity  
程序界面的顶层viewGroup，也就是decorView中注册了Activity这个callBack，所以当程序的主界面接收到事件之后会先交给Activity。  
但是，如果是另外的控件树，如dialog、popupWindow等事件流是不会经过Activity的。只有自己界面的事件才会经Activity

* 多指  
ACTION_POINTER_DOWN: 当已经有一个手指按下的情况下，另一个手指按下会产生该事件  
ACTION_POINTER_UP: 多个手指同时按下的情况下，抬起其中一个手指会产生该事件。  
多点触摸，每一个触摸点 Pointer 会有一个 id 和 index。对于多指操作，通过 pointerindex 来获取指定 Pointer 的触屏位置。比如，对于单点操作时获取x坐标通过 getX()，而多点操作获取 x 坐标通过 getX(pointerindex)  
View 默认不支持处理多指，可以先调用 onTouchListener ，再调用 onClickListener 和 onLongClickListener

<!-- https://www.jianshu.com/p/e99b5e8bd67b
https://blog.csdn.net/carson_ho/article/details/54136311
https://segmentfault.com/a/1190000039254459
https://juejin.cn/post/6844903901712351240#heading-0 -->
