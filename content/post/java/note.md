---
title: "Note"
date: 2021-07-10T22:07:28+08:00
draft: falase
tags: ["Java","Android","note"]
categories: ["Undefined"]
---

### json解析

#### jsonObject.getString() vs jsonObject.optString()

optString会在得不到你想要的值时候返回空字符串“ ”或指定的默认值，而getString会抛出异常。  
推荐使用optString，可避免接口字段的缺失、value的数据类型转换等异常

<!--more-->

### Java 线程池

#### Callable + Future 获取执行结果

简单使用

```java

    public boolean getTaskFlag() {
        //使用线程池执行
        Future<Boolean> future = ThreadUtils.getInstance().submit(new MyTask());
        try {
            //get 方法会阻塞线程
            return future.get(5, TimeUnit.SECONDS);
        } catch (ExecutionException e) {
            e.printStackTrace();
            return true;
        } catch (InterruptedException e) {
            e.printStackTrace();
            return true;
        } catch (TimeoutException e) {
            e.printStackTrace();
            return true;
        }
    }

    public class MyTask implements Callable<Boolean> {
        boolean taskFlag = false;

        @Override
        public Boolean call() throws Exception {
            try {
                System.out.println("执行耗时操作");
                Thread.sleep(3000);
                taskFlag = true;
                System.out.println("得到结果");
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            return taskFlag;
        }
    }
```

Future 包含方法 cancel(boolean mayInterruptRunning)，isCancelled()，isDone()，get()，get(long timeout, TimeUnit unit)

### Future 和 FutureTask

Future 是一个接口，代表可以取消的任务，并可以获得任务的执行结果

FutureTask 实现了 RunnableFuture ， RunnableFuture 继承了 Runnable, Future  
实现 Runnable 接口，说明可以把 FutureTask 实例传入到 Thread 中，在一个新的线程中执行。  
实现 Future 接口，说明可以从 FutureTask 中通过 get 取到任务的返回结果，也可以取消任务执行（通过 interreput 中断）

FutureTask 可用于异步获取执行结果或取消执行任务的场景。通过传入 Runnable 或者 Callable 的任务给 FutureTask，直接调用其 run 方法或者放入线程池执行，之后可以在外部通过 FutureTask 的 get 方法异步获取执行结果，因此，FutureTask 非常适合用于耗时的计算，主线程可以在完成自己的任务后，再去获取结果。另外，FutureTask 还可以确保即使调用了多次 run 方法，它都只会执行一次 Runnable 或者 Callable 任务，或者通过 cancel 取消 FutureTask 的执行等

### onInterceptTouchEvent 不被触发，收不到事件问题

某些控件要添加 android:clickable="true" 或者 onTouch 方法里返回 true（Button 默认是可点击的，所以能正常收到事件）

### 单例
<!-- https://zhuanlan.zhihu.com/p/386830431 -->
<!-- https://segmentfault.com/a/1190000040020116 -->
<!-- https://juejin.cn/post/6844903858276139021 -->

一般可以用静态内部类模式，性能和安全都比较兼顾  
kotlin 一般简单的用 object 对象声明，伴生对象的写法更灵活，比如需要传参数，继承，接口等时候用

双重检查模式

```java
public class Singleton {
    private volatile static Singleton singleton;

    private Singleton() {
    }

    public static Singleton getSingleton() {
        if (singleton == null) {
            synchronized (Singleton.class) {
                if (singleton == null) {
                    singleton = new Singleton();
                }
            }
        }
        return singleton;
    }
}
```

```kotlin
class Singleton private constructor() {
    companion object {
        val instance: Singleton by lazy {
        Singleton() }
    }
}
```

静态内部类模式

```java
public class Singleton {
    private Singleton() {
    }

    public static Singleton getSingleton() {
        return Inner.instance;
    }

    private static class Inner {
        private static final Singleton instance = new Singleton();
    }
}
```

```kotlin
class Singleton private constructor() {
    companion object {
        val instance = SingletonHolder.holder
    }

    private object SingletonHolder {
        val holder= Singleton()
    }
}
```

枚举

```java
public enum Singleton {
    INSTANCE;
    public void doSth() {
    }
}
```

<!-- ### map 遍历

### list 去重

### 反射 -->

### android ndk

[官方文档](https://developer.android.com/ndk/guides)

在 Android studio 中直接新建 Native C++ 的项目，IDE 会自动安装需要的工具，如 CMake 。新版 Android studio 不用另外再安装 LLDB ,所以在 SDK Manger 中看不到。

```kotlin
package com.kalaqiae.test

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import com.kalaqiae.test.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

  private lateinit var binding: ActivityMainBinding

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    binding = ActivityMainBinding.inflate(layoutInflater)
    setContentView(binding.root)

    // Example of a call to a native method
    binding.sampleText.text = stringFromJNI()
  }

  /**
   * A native method that is implemented by the 'test' native library,
   * which is packaged with this application.
   */
  external fun stringFromJNI(): String

  companion object {
    // Used to load the 'test' library on application startup.
    init {
      //加载的 so 文件为 libtest.so
      System.loadLibrary("test")
    }
  }
}
```

```c++
#include <jni.h>
#include <string>

extern "C" JNIEXPORT jstring JNICALL
//静态注册 native 方法规则 Java+类的路径+类名+方法名
Java_com_kalaqiae_test_MainActivity_stringFromJNI(
        JNIEnv* env,
        jobject /* this */) {
    std::string hello = "Hello from C++";
    return env->NewStringUTF(hello.c_str());
}
```

```txt
# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.18.1)

# Declares and names the project.

project("test")

# Creates and names a library, sets it as either STATIC
# or SHARED, and provides the relative paths to its source code.
# You can define multiple libraries, and CMake builds them for you.
# Gradle automatically packages shared libraries with your APK.

add_library( # Sets the name of the library.
        test

        # Sets the library as a shared library.
        SHARED

        # Provides a relative path to your source file(s).
        native-lib.cpp)

# Searches for a specified prebuilt library and stores the path as a
# variable. Because CMake includes system libraries in the search path by
# default, you only need to specify the name of the public NDK library
# you want to add. CMake verifies that the library exists before
# completing its build.

find_library( # Sets the name of the path variable.
        log-lib

        # Specifies the name of the NDK library that
        # you want CMake to locate.
        log)

# Specifies libraries CMake should link to your target library. You
# can link multiple libraries, such as libraries you define in this
# build script, prebuilt third-party libraries, or system libraries.

target_link_libraries( # Specifies the target library.
        test

            # Links the target library to the log library
        # included in the NDK.
        ${log-lib})
```

生成 so 文件

可以利用 Gradle 生成。在 Android studio 中选择 Build->Make Project ，在项目的 build\intermediates\cmake 中会生成各个 ABI 的 so

将 so 文件 放在 libs 的对应路径下 如 libs\armeabi-v8a

应用场景:1.加密 2.音视频解码,图像操作等等（ffmpeg） 3.安全相关,比如hook注入 4.增量更新 5.游戏开发

[JNI和NDK的区别](https://cloud.tencent.com/developer/article/1392774)
<!-- https://juejin.cn/post/6844903941101060104#heading-7 -->
<!-- https://juejin.cn/post/6844904177924046856 -->

<!-- demo
https://github.com/desfate/JniSocketForAndroid
https://github.com/sjfricke/NDK-Socket-IPC -->

<!-- cmake -->
<!-- http://file.ncnynl.com/ros/CMake%20Practice.pdf -->

.c 和 .h 区别
<!-- https://cloud.tencent.com/developer/news/459726 -->
<!-- https://www.jianshu.com/p/7a5815d92afa -->
本质上没有任何区别。 只不过一般：.h文件是头文件，内含函数声明、宏定义、结构体定义等内容  
.c文件是程序文件，内含函数实现，变量定义等内容。而且是什么后缀也没有关系，只不过编译器会默认对某些后缀的文件采取某些动作。你可以强制编译器把任何后缀的文件都当作c文件来编。  
一般一个 .c 对应一个 .h 方便管理。

.cpp 是 c++(cplusplus)

f将.cpp /.c 转化成 .so 文件的两种方式  
通过 ndk-build 工具，需要编辑 Android.mk 文件。
通过 CMake，需要编辑 CMakeLists.txt 文件

### android proguard

#### 查看混淆后的错误日志（两种方法）

方法一：使用 proguardgui

* 打包后在 build->outputs->mapping 有 mapping.txt 文件
* 找到 proguardgui.bat 并双击 C:\Users\Administrator\AppData\Local\Android\Sdk\tools\proguard\bin
* 打开的 Proguard 程序中点击左边菜单中的 Retrace ，再选择 mapping.txt 并复制错误日志到对应区域，然后点击 Retrace

方法二：直接打开 mapping.txt 文件，在文本中查找对应信息

[参考](https://www.jianshu.com/p/11ade070de83)

### Android 上传库到 Meaven

MavenCentral 和 JitPack 都是 Meaven 仓库
谷歌推荐 MavenCentral 看起来更专业，可以绑定域名 可以用发布脚本 JitPack 更简单用 git
<!-- https://guolin.blog.csdn.net/article/details/119706565 -->
<!-- https://juejin.cn/post/6953598441817636900#heading-0 -->
<!-- https://juejin.cn/post/6932485276124233735 -->

Apache Maven：是一个软件（特别是Java软件）项目管理以及自动构建工具，由Apache软件基金会所提供。是基于项目对象模型（缩写：POM）概念，Maven利用一个中央信息片断能管理一个项目的构建、报告和文档等步骤。

Maven仓库你可以理解为和Apache Maven没有直接的关系，他就是一个存放各种工程jar文件、library文件、插件或者任何工程项目的仓库，用Maven来构建项目的时候可能也会用到Maven仓库里面的依赖库。

Maven仓库有三种类型：本地（local）中央（central），在android开发中最常用 远程（remote）

mavenCentral：中央仓库，这个仓库是由Maven社区管理，由Sonatype公司提供服务，是Apache Maven、SBT和其他构建系统默认的仓库，并且很容易被Apache Ant、Gradle和其他的构建工具使用，需要通过网络访问，通过：http://search.maven.org/#browse 开发者就可以在里面找到自己所需要的代码库。

Gradle支持三种不同的仓库，分别是：Maven和Ivy以及文件夹。

### Hook 框架

[Xposed](https://github.com/rovo89/Xposed) Xposed is a framework for modules that can change the behavior of the system and apps without touching any APKs.

[VirtualApp](https://github.com/asLody/VirtualApp) (简称：VA)是一款运行于Android系统的沙盒产品，可以理解为轻量级的“Android虚拟机”。其产品形态为高可扩展，可定制的集成SDK，您可以基于VA或者使用VA定制开发各种看似不可能完成的项目。VA目前被广泛应用于APP多开、小游戏合集、手游加速器、手游租号、手游手柄免激活、VR程序移植、区块链、移动办公安全、军队政府数据隔离、手机模拟信息、脚本自动化、插件化开发、无感知热更新、云控等技术领域。

[VirtualApp 技术黑产利用研究报告](https://m.qq.com/security_lab/news_detail_435.html)

[VirtualXposed](https://github.com/android-hacker/VirtualXposed) 是基于VirtualApp 和 epic 在非ROOT环境下运行Xposed模块的实现（支持5.0~10.0)

[Magisk](https://github.com/topjohnwu/Magisk) Magisk is a suite of open source software for customizing Android, supporting devices higher than Android 5.0.

[EdXposed](https://github.com/ElderDrivers/EdXposed) A Riru module trying to provide an ART hooking framework (initially for Android Pie) which delivers consistent APIs with the OG Xposed, leveraging YAHFA (or SandHook) hooking framework, supports Android 8.0 ~ 11.

[TaiChi](https://github.com/taichi-framework/TaiChi) 太极能够运行 Xposed 模块的框架，模块能通过它改变系统和应用的行为，是个类 Xposed 框架.。[中文文档](https://taichi.cool/zh/doc/)

### Android Studio Debug

设置调试类型默认是 auto ，可以选择只调试 Java/Kotlin 或者 C/C++ 的代码
Run > Edit Configurations

按住 alt 鼠标点击左侧边栏，可以设置触发一次就取消的断点，还可以设置断点不生效

[debug 这个已经挺详细了](https://juejin.cn/post/6844903811908108295#heading-9)
[debug 这个还包含了 debug smali](https://juejin.cn/post/7194630163924484155)

### view 源码

[view 三万行源码](https://android.googlesource.com/platform/frameworks/base/+/master/core/java/android/view/View.java)

### kotlin 自定义控件报错

Caused by: java.lang.NoSuchMethodException: &lt;init&gt; [class android.content.Context, interface android.util.AttributeSet]

构造函数里的参数需要是 Context

```kotlin
class MyView : LinearLayout {

    constructor(context: Context) : super(context)

    constructor(context: Context, attrs: AttributeSet) : super(context, attrs)

    constructor(context: Context, attrs: AttributeSet, defStyle: Int) : super(context, attrs, defStyle)
}
```

或者

```kotlin
class MyView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = 0
) : LinearLayout(context, attrs, defStyle){
    
}
```

### socket 和 websocket

websocket 在建立连接后就是全双工模式了，适合服务端需要主动推数据给客户端

socket 每次交互都是客户端主动发起

[马甲包](https://blog.yorek.xyz/android/other/android_alias/#25)

### jetpack compose

[官方文档](https://developer.android.com/jetpack/compose/documentation?hl=zh-cn)

[将 Jetpack Compose 添加到应用中](https://developer.android.com/jetpack/compose/interop/adding?hl=zh-cn)

[samples](https://github.com/android/compose-samples)

[demo](https://gitee.com/Rickyal/compose-demo#%E7%8A%B6%E6%80%81%E4%B8%8B%E6%B2%89%E4%BA%8B%E4%BB%B6%E4%B8%8A%E6%B5%AE)

[使用 viewmodel](https://ithelp.ithome.com.tw/articles/10277978)

[一个简单的例子](https://blog.51cto.com/u_15200109/2786144)

### 阴影实现方式 elevation

https://developer.android.com/training/material/shadows-clipping?hl=zh-cn

elevation 是宽度 outlineSpotShadowColor 是颜色

```xml
<TextView
android:layout_width="match_parent"
android:layout_height="wrap_content"
android:elevation="3dp"
android:outlineSpotShadowColor="#57000000"/>
```

### 查看 apk 签名是 v 几

apksigner通常在 sdk/build-tools/版本号

>apksigner verify -v apkName.apk

### MMKV DataStore

MMKV 基于内存映射所以写入很快，即使写入时应用崩溃也能完成写入，系统级奔溃就没办法了，如断电。有数据丢失的风险。  
读取不是在内存上操作相对就没那么快了。  
他是在主线程同步运行，因为快所以没影响，但是如果大量写入，还是会卡的。  
支持跨进程。  
增量式更新。

DataStore 使用 Kotlin 协程和 Flow 以异步、一致的事务方式存储数据。不会丢数据，支持回调，在子线程读写，速度稳定。

SharedPreferences 速度慢 有 ANR 的问题

### Matrix

线上没办法用 profiler ，就可以用 Matrix 记录

### 设置 Dialog 最大高度

在 show 前调用

```java
    View decorView = dialog.getWindow().getDecorView();
    int maxHeight = DisplayUtils.dp2px(mActivity, 456);
    decorView.measure(
        MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED),
        MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED);
    if (decorView.getMeasuredHeight() > maxHeight) {
        dialog.getWindow().setLayout(width, maxHeight);
        }
```

### android studio 搜索

regex 正则表达式搜索  
比如 ^((?!(\*|//)).)+[\u4e00-\u9fa5] 搜索中文

### Java ArrayList LinkedList Vector

<!-- https://cloud.tencent.com/developer/news/700913 -->
* ArrayList 基于数组实现的并且实现了动态扩容。它允许所有元素，包括 null
* LinkedList 基于双向链表实现
* Vector 类似 ArrayList。Vector 是线程安全的。如果线程已经是安全的，直接用 ArrayList 就不用 Vector 了
* ArrayList get/set 比 LinkedList 快。ArrayList 在尾部增加不需要扩容时比 LinkedList 快，中间增加不需要扩容时 LinkedList 要遍历所以 LinkedList可能更慢，在头部增加和时因为要复制数组所以比较慢
* ArrayList 删除时，删除的元素越靠前越慢，LinkedList 删除越靠中间越慢
* for 循环遍历的时候，ArrayList 花费的时间远小于 LinkedList；迭代器遍历的时候，两者性能差不多。所以遍历 LinkedList 的时候，不要使用 for 循环，要使用迭代器

### java 集合

#### Collection 接口

* List（有序，可重复）
  * ArrayList: 基于动态数组实现，随机访问速度快，但在中间插入或删除元素时效率较低，线程不安全
  * LinkedList：基于双向链表实现，插入和删除元素效率高，但随机访问速度较慢，线程不安全
  * Vector：类似 ArrayList，线程安全，效率低，不推荐用

* Set（无序，不可重复）
  * HashSet: 基于 HashMap 实现，不保证元素的顺序，查找速度快
  * LinkedHashSet: 基于 LinkedHashMap 实现，保留了元素的插入顺序，查找速度也较快
  * TreeSet: 基于红黑树实现，会对元素进行排序（可以自然排序或自定义排序），元素需要实现 Comparable 或传 Comparator

* Queue
  * LinkedList: 可以作为队列使用
  * PriorityQueue: 基于堆实现，允许按照优先级处理元素，元素按优先级出队
  * ArrayDeque: 基于动态数组实现的双端队列

#### Map 接口

* HashMap: 基于哈希表实现，提供快速的查找、插入和删除操作，不保证键值对的顺序，键不能重复，值可以重复，线程不安全
* LinkedHashMap: 基于哈希表和双向链表实现，保留了键值对的插入顺序
* TreeMap: 基于红黑树实现，会对键进行排序（可以自然排序或自定义排序）
* Hashtable和 HashMap 类似，但它是线程安全的，因此性能略低，并且不允许 null 键和 null 值，不推荐用
* ConcurrentHashMap: 线程安全的 HashMap 实现，适用于高并发场景

#### 集合选择

* 是否需要键值对：是→Map，否→Collection
* 是否需要排序：是→TreeSet/TreeMap，否→HashSet/HashMap
* 是否需要保持插入顺序：是→LinkedHashSet/LinkedHashMap
* 是否需要线程安全：是→ConcurrentHashMap/Collections.synchronizedXXX
* 频繁插入删除：LinkedList
* 频繁随机访问：ArrayList

### Android 重启

```java
final Intent intent = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            context.startActivity(intent);
            //杀掉以前进程
            android.os.Process.killProcess(android.os.Process.myPid());
```

### Android studio 空判断和循环快捷键

object.nn object.null 空判断快捷方式  
for 循环，快捷方式 list.fori 或 list.forr  

### Android studio 提取 style

提取style：在XML文件中，光标选中需要提取样式的控件，然后右键选择-->Refactor-->Extract-->Style

### final 修饰作用

final 修饰的类不能被继承，修饰的方法不能被重写

### try catch 输出日志

```kotlin
            try {

            } catch (e: Exception) {
                //正式环境不建议用，输出太多会影响性能
                e.printStackTrace()
            }
```

### 在单独的类中接收 activity 结果

[与其他应用交互 在单独的类中接收 activity 结果](https://developer.android.com/training/basics/intents/result?hl=zh-cn#separate)

```kotlin
class MyLifecycleObserver(private val registry : ActivityResultRegistry)
        : DefaultLifecycleObserver {
    lateinit var getContent : ActivityResultLauncher<String>

    override fun onCreate(owner: LifecycleOwner) {
        getContent = registry.register("key", owner, GetContent()) { uri ->
            // Handle the returned Uri
        }
    }

    fun selectImage() {
        getContent.launch("image/*")
    }
}

class MyFragment : Fragment() {
    lateinit var observer : MyLifecycleObserver

    override fun onCreate(savedInstanceState: Bundle?) {
        // ...

        observer = MyLifecycleObserver(requireActivity().activityResultRegistry)
        lifecycle.addObserver(observer)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val selectButton = view.findViewById<Button>(R.id.select_button)

        selectButton.setOnClickListener {
            // Open the activity to select an image
            observer.selectImage()
        }
    }
}
```

### 压缩工具 zip4j

删除路径下的 zip 和解压出来的文件

```java
public static void deleteZipFile(File file, String filePath) throws ZipException {
        ZipFile zFile = new ZipFile(file);
        //zFile.setFileNameCharset("GBK");

        if (!zFile.isValidZipFile()) { // 验证.zip文件是否合法，包括文件是否存在、是否为zip文件、是否被损坏等
            throw new ZipException("压缩文件不合法,可能被损坏.");
        }
        List<FileHeader> zipFiles = zFile.getFileHeaders();
        List<String> tempPath = new ArrayList<>();
        for (int i = 0; i < zipFiles.size(); i++) {
            File tempFile = new File(filePath + "/" + zipFiles.get(i).getFileName());
            if (tempFile.isDirectory()) {
                tempPath.add(filePath + "/" + zipFiles.get(i).getFileName());
            } else if (tempFile.exists()) {
                tempFile.delete();
            }
            if (i == zipFiles.size() - 1) {
                if (tempPath.size() > 0) {
                    for (String path : tempPath) {
                        File tempDirectoryFile = new File(path);
                        String[] tempDirectoryFiles = tempDirectoryFile.list();
                        if (tempDirectoryFiles != null && tempDirectoryFiles.length > 0) {

                        } else if (tempDirectoryFile.exists()) {
                            tempDirectoryFile.delete();
                        }
                    }
                }
            }
        }
        file.delete();
    }
```

解压所有文件

```java
    public static void unZipFileWithProgress(final File zipFile, final String filePath,
                                             CallbackUnzipMonitor callback,
                                             final boolean isDeleteZip, boolean isRunThread) throws ZipException {
        ZipFile zFile = new ZipFile(zipFile);

        if (!zFile.isValidZipFile()) { // 验证.zip文件是否合法，包括文件是否存在、是否为zip文件、是否被损坏等
            throw new ZipException("压缩文件不合法,可能被损坏.");
        }
        zFile.setFileNameCharset("GBK");

        File destDir = new File(filePath); // 解压目录
        if (destDir.isDirectory() && !destDir.exists()) {
            destDir.mkdir();
        }


        if (callback != null) {
            final ProgressMonitor progressMonitor = zFile.getProgressMonitor();
            callback.setMonitor(progressMonitor);
        }
        zFile.setRunInThread(isRunThread);
        zFile.extractAll(filePath); // 解压到此文件夹中
    }
```

解压 zip 中单独某个文件

```java
        public static void unZipFileWithProgressSingle(final File zipFile, final String filePath,
        final String singleFilePath,
        CallbackUnzipMonitor callback,
        final boolean isDeleteZip, boolean isRunThread) throws ZipException {
        ZipFile zFile = new ZipFile(zipFile);

        if (!zFile.isValidZipFile()) { // 验证.zip文件是否合法，包括文件是否存在、是否为zip文件、是否被损坏等
            throw new ZipException("压缩文件不合法,可能被损坏.");
        }
        zFile.setFileNameCharset("GBK");

        File destDir = new File(filePath); // 解压目录
        if (destDir.isDirectory() && !destDir.exists()) {
            destDir.mkdir();
        }

        if (callback != null) {
            final ProgressMonitor progressMonitor = zFile.getProgressMonitor();
            callback.setMonitor(progressMonitor);
        }
        zFile.setRunInThread(isRunThread);
        zFile.extractFile(singleFilePath, filePath); // 解压到此文件夹中
    }
```

### Android Studio Live Templates

布局文件 宽高相关 lh lw lhw lhm

### JS 闭包

js 子对象可以读取到父对象的变量，父对象不能读取到子对象内部的变量  
f2可以读取f1中的局部变量，把f2作为返回值，f1外部就读取它的内部变量，f2函数，就是闭包。  
用于读取函数内部的变量和让这些变量的值始终保持在内存中

```javascript
　　function f1(){

　　　　var n=999;

　　　　function f2(){
　　　　　　alert(n);
　　　　}

　　　　return f2;

　　}

　　var result=f1();

　　result(); // 999
```

### build.gradle 修改 apk 名称

一般自定义打包出来的 apk 名称可以这么写

```groovy
    android.applicationVariants.all { variant ->
        variant.outputs.each { output ->
            if (variant.buildType.name.equals("release")) {
                variant.outputs.all {
                    outputFileName = "kalaqiae_" + variant.buildType.name + "_" + variant.productFlavors[0].name + "_v"+
                            defaultConfig.versionCode + "_" + new Date().format("yyyy.MM.dd-HH.mm") + ".apk"
                }
            } else {
                variant.outputs.all {
                    outputFileName = "kalaqiae_" + variant.buildType.name + "_v" +
                            defaultConfig.versionCode + "_" + new Date().format("yyyy.MM.dd-HH.mm") + "_test" + ".apk"
                }
            }
        }
    }
```

在执行某个命令后重命名这么写

```groovy
//复制后重命名
task renameApk(type: Copy) {
    from 'build/outputs/apk/release/app-release.apk'
    into 'build/outputs/apk/release/'
    rename { fileName ->
        fileName.replace('app-release',
            "kalaqiae" + "_v" + android.defaultConfig.versionCode +
                "_" + new Date().format("yyyy.MM.dd-HH.mm") +
                "_" + (rootProject.ext.IS_TEST ? "test" : "production"))
    }
}
//当执行 installRelease 或 assembleRelease 后执行 finalizedBy
tasks.whenTaskAdded { task ->
    if (task.name == 'installRelease' || task.name == 'assembleRelease') {
        task.finalizedBy(renameApk)
    }

}
```

### 查看 md5

certutil -hashfile example.exe MD5

### 依赖冲突

app->task->dependcies 查看依赖

```groovy
//移除重复依赖例子
implementation 'com.example:library:1.0.0', {
    exclude group: 'org.jetbrains.kotlin', module: 'kotlin-stdlib'
}
```

### 深拷贝和浅拷贝

都要实现 Cloneable 重写 clone 方法，浅拷贝对拷贝后的对象修改可能会影响到原有对象，修改对象不会影响原对象

深拷贝实现方式

* 构造函数深拷贝（new 创建新对象）
* 重写clone()方法并递归调用引用对象的clone()
* 使用序列化/反序列化
* 使用第三方库如Apache Commons Lang的SerializationUtils

如何选择

* 如果对象只包含基本类型或不可变对象(如String)，浅拷贝通常足够
* 如果对象包含可变引用类型且需要完全独立，应使用深拷贝
* 考虑性能开销，深拷贝比浅拷贝更消耗资源

```java
//浅拷贝
class Person implements Cloneable {
    String name;
    Address address;
    
    @Override
    protected Object clone() throws CloneNotSupportedException {
        return super.clone(); // 浅拷贝
    }
}

class Address {
    String city;
}

// 使用
Person p1 = new Person();
Person p2 = (Person)p1.clone();
// p1和p2的address指向同一个对象

//递归深拷贝
class Person implements Cloneable {
    String name;
    Address address;
    
    @Override
    protected Object clone() throws CloneNotSupportedException {
        Person cloned = (Person)super.clone();
        cloned.address = (Address)address.clone(); // 递归clone
        return cloned;
    }
}

class Address implements Cloneable {
    String city;
    
    @Override
    protected Object clone() throws CloneNotSupportedException {
        return super.clone();
    }
}

//序列化深拷贝
import java.io.*;

class DeepCopyUtil {
    public static <T extends Serializable> T deepCopy(T object) {
        try {
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            ObjectOutputStream oos = new ObjectOutputStream(bos);
            oos.writeObject(object);
            
            ByteArrayInputStream bis = new ByteArrayInputStream(bos.toByteArray());
            ObjectInputStream ois = new ObjectInputStream(bis);
            return (T)ois.readObject();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
```

<!-- ### c

typedef

用于自定义类型

Struct 和 Union 区别

Struct 更像是对象，所占空间是所有成员的存储空间之和。 Union 像泛型，同一时间只能存一个成员的值，所占空间是最大成员的存储空间。 -->

<!-- [javacv](https://www.cnblogs.com/eguid/p/13557932.html) -->

<!-- [阮ffmpeg](https://www.ruanyifeng.com/blog/2020/01/ffmpeg.html) -->

<!-- [FFmpeg手撕视频（Android端）](https://juejin.cn/post/6844903961644793869#heading-1) -->

<!-- [阮c](https://wangdoc.com/clang/) -->

<!--jni监听应用卸载 https://cloud.tencent.com/developer/article/1033962 -->
<!--jni监听应用卸载 https://www.helloworld.net/p/8912563749 -->

<!-- https://github.com/suming77/SumTea_Android 基于组件化+模块化+Kotlin+协程+Flow+Retrofit+Jetpack+MVVM+短视频架构实现的WanAndroid客户端 -->

<!-- RecyclerView 位置 http://www.gityunstar.com/post/fa19cc06eee211eb8faf00163e0febfd -->
<!-- 反向代理 https://cloud.tencent.com/developer/beta/article/1418457 -->
<!-- bazingga.xyz -->

<!-- mac 应该是只能支持12之前的 aosp 编译 Android 推荐用 Ubuntu 18.04 (Bionic Beaver)
https://source.android.com/docs/setup/start/requirements?hl=zh-cn -->
