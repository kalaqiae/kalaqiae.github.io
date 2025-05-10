---
title: "Interview 随记"
date: 2021-05-17T23:01:09+08:00
draft: true
tags: ["Interview"]
categories: ["Interview"]
---

### HashMap 的原理

HashMap 的内部可以看做数组+链表的复合结构。数组被分为一个个的桶(bucket)。哈希值决定了键值对在数组中的寻址。具有相同哈希值的键值对会组成链表。需要注意的是当链表长度超过阈值(默认是8)的时候会触发树化，链表会变成树形结构。

<!--more-->

* hash方法  

   将 key 的 hashCode 值的高位数据移位到低位进行异或运算。这么做的原因是有些 key 的 hashCode 值的差异集中在高位，而哈希寻址是忽略容量以上高位的，这种做法可以有效避免哈希冲突。

* put 方法  

   通过 hash 方法获取 hash 值，根据 hash 值寻址。  
如果未发生碰撞，直接放到桶中。  
如果发生碰撞，则以链表形式放在桶后。  
当链表长度大于阈值后会触发树化，将链表转换为红黑树。  
如果数组长度达到阈值，会调用 resize 方法扩展容量。  

* get方法

   通过 hash 方法获取 hash 值，根据 hash 值寻址。  
如果与寻址到桶的 key 相等，直接返回对应的 value。  
如果发生冲突，分两种情况。如果是树，则调用 getTreeNode 获取  value；如果是链表则通过循环遍历查找对应的 value。  

* resize 方法

   将原数组扩展为原来的 2 倍  
重新计算 index 索引值，将原节点重新放到新的数组中。这一步可以将原先冲突的节点分散到新的桶中。

### sleep 和 wait 的区别

sleep 方法是 Thread 类中的静态方法，wait 是 Object 类中的方法  
sleep 并不会释放同步锁，而 wait 会释放同步锁  
sleep 可以在任何地方使用，而 wait 只能在同步方法或者同步代码块中使用  
sleep 中必须传入时间，而 wait 可以传，也可以不传，不传时间的话只有 notify 或者 notifyAll 才能唤醒，传时间的话在时间之后会自动唤醒

### join 的用法

join 方法通常是保证线程间顺序调度的一个方法，它是 Thread 类中的方法。比方说在线程 A 中执行线程 B.join()，这时线程 A 会进入等待状态，直到线程 B 执行完毕之后才会唤醒，继续执行A线程中的后续方法。

### Java中引用类型的区别

* 强引用：强引用指的是通过 new 对象创建的引用，垃圾回收器即使是内存不足也不会回收强引用指向的对象。  
* 软引用：软引用是通过 SoftRefrence 实现的，它的生命周期比强引用短，在内存不足，抛出 OOM 之前，垃圾回收器会回收软引用引用的对象。软引用常见的使用场景是存储一些内存敏感的缓存，当内存不足时会被回收。  
* 弱引用： 弱引用是通过 WeakRefrence 实现的，它的生命周期比软引用还短，GC 只要扫描到弱引用的对象就会回收。弱引用常见的使用场景也是存储一些内存敏感的缓存。  
* 虚引用： 虚引用是通过 FanttomRefrence 实现的，它的生命周期最短，随时可能被回收。如果一个对象只被虚引用引用，我们无法通过虚引用来访问这个对象的任何属性和方法。它的作用仅仅是保证对象在 finalize 后，做某些事情。虚引用常见的使用场景是跟踪对象被垃圾回收的活动，当一个虚引用关联的对象被垃圾回收器回收之前会收到一条系统通知。  

### 服务

### 广播

现在要求最好都是动态注册

### 动画

帧动画，补间动画，属性动画。还可以考虑用 surfaceview 绘制，在 gpu 里运行比较不卡？

### 内存泄漏

单例模式导致的内存泄漏，比如不要使用 Activity 类型的 Context，使用 Application 类型的 Context 可以避免内存泄漏

静态变量导致的内存泄漏，比如静态变量的生命周期几乎和整个应用程序的生命周期一致，它一直持有 Activity 的引用，从而导致了内存泄漏

使用资源未及时关闭导致的内存泄漏。常见的例子有：操作各种数据流未及时关闭，操作 Bitmap 未及时 recycle 等等。

使用第三方库未能及时解绑

属性动画导致的内存泄漏，要在 onDestroy 中调用动画的 cancel 方法取消属性动画

WebView 导致的内存泄漏，WebView 比较特殊，即使是调用了它的 destroy 方法，依然会导致内存泄漏。让 WebView 所在的 Activity 处于另一个进程中，当这个 Activity 结束时杀死当前 WebView 所处的进程即可

集合中对象没清理造成的内存泄漏

### View的绘制流程

视图绘制的起点在 ViewRootImpl 类的 performTraversals()方法，在这个方法内其实是按照顺序依次调用了 mView.measure()、mView.layout()、mView.draw()

View的绘制流程分为3步：测量、布局、绘制，分别对应3个方法 measure、layout、draw。

* 测量阶段。 measure 方法会被父 View 调用，在measure 方法中做一些优化和准备工作后会调用 onMeasure 方法进行实际的自我测量。onMeasure方法在View和ViewGroup做的事情是不一样的：
  * View。 View 中的 onMeasure 方法会计算自己的尺寸并通过 setMeasureDimension 保存。
  * ViewGroup。 ViewGroup 中的 onMeasure 方法会调用所有子 View 的 measure 方法进行自我测量并保存。然后通过子View的尺寸和位置计算出自己的尺寸并保存。

* 布局阶段。 layout 方法会被父View调用，layout 方法会保存父 View 传进来的尺寸和位置，并调用 onLayout 进行实际的内部布局。onLayout 在 View 和 ViewGroup 中做的事情也是不一样的：

  * View。 因为 View 是没有子 View 的，所以View的onLayout里面什么都不做。
  * ViewGroup。 ViewGroup 中的 onLayout 方法会调用所有子 View 的 layout 方法，把尺寸和位置传给他们，让他们完成自我的内部布局。

* 绘制阶段。 draw 方法会做一些调度工作，然后会调用 onDraw 方法进行  View 的自我绘制。draw 方法的调度流程大致是这样的：

  * 绘制背景。对应 drawBackground(Canvas)方法。
  * 绘制主体。对应 onDraw(Canvas)方法。
  * 绘制子View。 对应 dispatchDraw(Canvas)方法。
  * 绘制滑动相关和前景。 对应 onDrawForeground(Canvas)。

### Bitmap OOM 问题

等比缩小长宽。Options 中有一个属性 inSampleSize。通过修改 inSampleSize 可以缩小图片的长宽。inSampleSize 大小需要是 2 的幂次方，如果小于 1，代码会强制让 inSampleSize 为1。

减少像素所占内存。Options 中有一个属性 inPreferredConfig，默认是 ARGB_8888，代表每个像素所占尺寸。我们可以通过将之修改为 RGB_565 或者 ARGB_4444 来减少一半内存

>ALPHA_8   每个像素占用1byte内存
ARGB_4444 每个像素占用2byte内存
ARGB_8888 每个像素占用4byte内存（默认）
RGB_565 每个像素占用2byte内存

### launch mode

standard，创建一个新的Activity。

singleTop，栈顶不是该类型的Activity，创建一个新的Activity。否则，onNewIntent。

singleTask，回退栈中没有该类型的Activity，创建Activity，否则，onNewIntent+ClearTop。

注意:

设置了"singleTask"启动模式的Activity，它在启动的时候，会先在系统中查找属性值affinity等于它的属性值taskAffinity的Task存在； 如果存在这样的Task，它就会在这个Task中启动，否则就会在新的任务栈中启动。因此， 如果我们想要设置了"singleTask"启动模式的Activity在新的任务中启动，就要为它设置一个独立的taskAffinity属性值。 如果设置了"singleTask"启动模式的Activity不是在新的任务中启动时，它会在已有的任务中查看是否已经存在相应的Activity实例， 如果存在，就会把位于这个Activity实例上面的Activity全部结束掉，即最终这个Activity 实例会位于任务的Stack顶端中。 在一个任务栈中只有一个”singleTask”启动模式的Activity存在。他的上面可以有其他的Activity。这点与singleInstance是有区别的。 singleInstance，回退栈中，只有这一个Activity，没有其他Activity。

singleTop适合接收通知启动的内容显示页面。

例如，某个新闻客户端的新闻内容页面，如果收到10个新闻推送，每次都打开一个新闻内容页面是很烦人的。

singleTask适合作为程序入口点。

例如浏览器的主界面。不管从多少个应用启动浏览器，只会启动主界面一次，其余情况都会走onNewIntent，并且会清空主界面上面的其他页面。

singleInstance应用场景：

闹铃的响铃界面。 你以前设置了一个闹铃：上午6点。在上午5点58分，你启动了闹铃设置界面，并按 Home 键回桌面；在上午5点59分时，你在微信和朋友聊天；在6点时，闹铃响了，并且弹出了一个对话框形式的 Activity(名为 AlarmAlertActivity) 提示你到6点了(这个 Activity 就是以 SingleInstance 加载模式打开的)，你按返回键，回到的是微信的聊天界面，这是因为 AlarmAlertActivity 所在的 Task 的栈只有他一个元素， 因此退出之后这个 Task 的栈空了。如果是以 SingleTask 打开 AlarmAlertActivity，那么当闹铃响了的时候，按返回键应该进入闹铃设置界面。

### ANR

Application NotResponding ， Activity 是5秒， BroadCastReceiver 是10秒， Service 是20秒（均为前台）
耗时线操作放子线程

### 各版本特性

Android6.0新特性 动态权限管理

Android7.0新特性 多窗口支持 V2签名

Android8.0（O）新特性 优化通知 画中画模式 后台限制

Android9.0（P）新特性 室内WIFI定位 “刘海”屏幕支持

Android10.0（Q）

### ActivityA跳转ActivityB然后B按back返回A，各自的生命周期顺序，A与B均不透明

* ActivityA跳转到ActivityB

>Activity A：onPause
Activity B：onCreate
Activity B：onStart
Activity B：onResume
Activity A：onStop

* ActivityB返回ActivityA

>Activity B：onPause
Activity A：onRestart
Activity A：onStart
Activity A：onResume
Activity B：onStop
Activity B：onDestroy

### 各布局绘制效率

### Merge、ViewStub

Merge: 减少视图层级，可以删除多余的层级

ViewStub: 按需加载，减少内存使用量、加快渲染速度、不支持 merge 标签。

### Asset目录与res目录的区别

assets：不会在 R 文件中生成相应标记，存放到这里的资源在打包时会打包到程序安装包中。（通过 AssetManager 类访问这些文件）
res：会在 R 文件中生成 id 标记，资源在打包时如果使用到则打包到安装包中，未用到不会打入安装包中。
res/anim：存放动画资源。
res/raw：和 asset 下文件一样，打包时直接打入程序安装包中（会映射到 R 文件中）。

### 类的初始化顺序

（静态变量、静态代码块）>（变量、代码块）> 构造方法

### Android进程间通信的方式

AIDL 、广播、文件、socket、管道

### Android与 js 交互

* Android调js

  * WebView.loadUrl("javascript:js中的方法名")，没有返回值

  * WebView.evaluateJavaScript("javascript:js中的方法名",ValueCallback)，可以通过 ValueCallback 这个回调拿到 js方法的返回值，Android4.4 才有

* js 调 Android

  * WebView.addJavascriptInterface()，需要注意的是要在供 js 调用的 Android 方法上加上 @JavascriptInterface 注解，以避免安全漏洞

  * 重写 WebViewClient的shouldOverrideUrlLoading()方法来拦截url，无法直接拿到调用 Android 方法的返回值，只能通过 Android 调用 js 方法来获取返回值

  * 重写 WebChromClient 的 onJsPrompt() 方法，同前一个方式一样，拿到 url 之后先进行解析，如果符合双方规定，即可调用Android方法。如果需要返回值，通过 result.confirm("Android方法返回值") 即可将 Android 的返回值返回给 js

### ContentProvider 的创建时机

* 应用启动时
在 AndroidManifest.xml 中设置了 android:initOrder（数值越大，优先级越高）或 设置了 android:multiprocess="false"（默认值）会自动创建，未设置不会自动创建
* 第一次访问 ContentProvider 时
当系统或其他组件（如 Activity、Service 或其他应用）通过以下方式访问 ContentProvider 中的数据时，ContentProvider 就会被实例化和创建：
  * 通过 ContentResolver 调用：
    query()
    insert()
    update()
    delete()
  * 通过 getType() 方法查询 MIME 类型

### 在 Android 的 Intent 中，FLAG_ACTIVITY_CLEAR_TOP 的作用

如果要启动的 Activity 已经在返回栈中存在，则会清除它之上的所有 Activity，并将其置于栈顶，如果要启动的 Activity 已存在于返回栈中，不会被重新创建，但会回调其 onNewIntent() 方法

* 场景 1：返回主界面并清除其他 Activity
* 场景 2：避免启动相同的 Activity 实例

### java, new String() 在 JVM 中会创建几个字符串对象

* 如果是 new String("abc")，总对象数 = 2（1 个在字符串常量池，1 个在堆中）。常量池对象在类加载时创建（如果首次出现），堆对象在运行时创建
* 如果是 `new String(char[])，总对象数 = 1（仅在堆中创建，不涉及常量池）

```java
// 不推荐（可能创建2个对象）
String s1 = new String("abc"); 

// 推荐（复用常量池，仅1个对象）
String s2 = "abc"; 

// 推荐（动态字符串处理后复用常量池，需权衡性能，常量池是全局的，可能引发竞争）
//new String("abc").intern() 会创建几个对象，如果 "abc" 不在常量池 2，如果 "abc" 已在常量池 1
String s3 = new String(charArray).intern();
```

<!-- ### aidl使用，anr oom排查解决 -->
