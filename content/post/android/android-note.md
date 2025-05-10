---
title: "Android Note"
date: 2024-12-24T16:42:02+08:00
draft: false
tags: ["Android"]
categories: ["Android"]
---

## Android 四大组件

* **Activity**
  * 生命周期
  * 启动模式（standard，singleTop，singleTask，singleInstance）
  * 任务栈
  * 启动方式：显式 Intent，隐式 Intent（Intent Filter，URL Scheme，跨应用场景用隐式），ARouter
  * PendingIntent
  * 数据传递
  * startActivityForResult
     启动一个 Activity 并等待结果。注意：`startActivityForResult()` 在 Android 11 及以上版本已被弃用，推荐使用 `ActivityResultContracts` 替代
  * Fragment
    * 生命周期（onAttach，onCreate，onCreateView，onActivityCreated，onStart，onResume，onPause，onStop，onDestroyView，onDestroy，onDetach）
    * 通信
    * DialogFragment()
  * onConfigurationChanged
  * onSaveInstanceState

  <!--more-->

* **Service**
  * 启动服务（startService，bindService）
  * 生命周期（onCreate，onStartCommand，onBind，onUnbind，onDestroy）
  * 通信（Activity，IPC）
  * 服务保活
  * 前台服务（startForeground）
  * IntentService
* **BroadcastReceiver**
  * 类型（普通广播，有序广播，本地广播）
  * 注册方式（静态注册，动态注册。 Android 8.0 及以上版本，需要动态注册）
  * 发送和接收
  * 常见的系统广播
* **ContentProvider**
  * ContentProvider 是 Android 中用于在不同应用之间共享数据的机制。它允许应用访问另一个应用的数据，提供一种统一的接口，通过 URI 来操作不同数据源。常用于数据库、文件、共享的内容（如联系人、图片等）数据的访问
  * URI
  * MIME
  * 主要方法(onCreate，query，insert，update，delete，getType)
  * 在AndroidManifest.xml文件中的 application节点下使用标签注册时android:exported="false"时，不允许其他应用调用
  
## UI 与交互

* **View**
  * 自定义 View（一般继承 View 或已有控件如：TextView）
  * View 的绘制
    * 测量，布局，绘制
  * View 的宽高获取
    * view.getMeasureWidth() view.getMeasuredHeight()
    * ViewTreeObserver
  * 事件分发
    * 事件流
      * 事件分发：dispatchTouchEvent()
      * 事件拦截：onInterceptTouchEvent()
      * 事件处理：onTouchEvent()
    * 事件的传递顺序
      * Activity -> ViewGroup -> View
      * ViewGroup -> 子 View
      * 父控件优先：父控件先接收事件，决定是否继续传递给子控件
    * 拦截与处理
      * dispatchTouchEvent()：分发触摸事件，判断是否继续向下传递
      * onInterceptTouchEvent()：拦截触摸事件，父控件可以选择拦截，决定是否传递给子控件
      * onTouchEvent()：最终的事件处理，子控件接收并处理事件
    * ViewGroup中的事件分发
    * 解决滑动冲突
      * requestDisallowInterceptTouchEvent()：通知父控件不要拦截事件
      * onTouchEvent() 的返回值处理
      * onInterceptTouchEvent() 的实现
* **Widgets**
  * Text Widgets
    * TextView
    * EditText
  * Button Widgets
    * Button
    * CheckBox
    * RadioButton
    * Switch
  * Image
    * ImageView
  * Container Widgets
    * RecyclerView
    * ListView
    * ViewPager
    * CardView
  * Progress Widgets
    * ProgressBar
    * SeekBar
  * Other Widgets
    * Toast
* **Layout**
  * LinearLayout
  * RelativeLayout
  * ConstraintLayout
  * FrameLayout
  * ScrollView
  * HorizontalScrollView
  * GridLayout
* **Animation**
  * View Animation
    * Tween Animation（TranslateAnimation、RotateAnimation、ScaleAnimation、AlphaAnimation）
    * Frame Animation
  * Property Animation
    * ObjectAnimator（对任意属性进行动画）
    * ValueAnimator（基于值变化的动画，支持更多控制和时间插值）
    * AnimatorSet（组合多个动画的执行）
  * Transition Animation
  * 第三方（Lottie，PAG ）
* **屏幕适配**
  * 使用 dp 和 sp 单位
  * 使用约束布局
  * 使用百分比布局(PercentLayout)
  * 使用自动缩放(AutoSizeText)
  * 使用不同的布局文件
  * 全面屏适配
  * 第三方（AndroidAutoSize等）
* **通知**
  * 通知的组成部分
  * 通知的渠道
  * 通知优先级
  * 通知类型
  * 通知的操作
  * 通知的权限
* **WebView**
  * 基本使用
  * 与 JavaScript 交互
    * Android 调用 JavaScript
    * JavaScript 调用 Android
  * 优化
  * 第三方库
    * 腾讯 X5

## 性能优化

* **启动（冷启动，热启动）优化**
  * 启动流程
  * 启动方式（使用singleTask、singleTop避免重复启动Activity）
  * 统计启动时间
  * 优化splash页
  * 优化Activity
* **布局优化**
  * 减少嵌套
  * ViewStub include merge
* **内存优化**
  * 内存泄漏检测（LeakCanary，Android Studio Profiler）
  * 内存泄漏常见类型
    * Bitmap 未调用 recycle或内存溢出（Bitmap解码格式也可以优化，内存泄漏会导致内存溢出，内存溢出不一定是内存泄漏）
    * Context 引用不当
    * Handler 引用泄漏
    * 静态变量持有引用
    * 未关闭资源（如 Cursor、File、Network 等）
  * GC
    * 减少对象创建频率，避免频繁 GC
    * 内存管理（如 WeakReference）
* **卡顿优化（布局，内存，线程等优化都和卡顿优化有关）**
  * 检测工具（Android Studio Profiler）
  * ANR
* **apk瘦身**
  * ProGuard，精简资源（如图片格式WebP，无用资源），移除不必要的依赖
* **网络优化**
  * 减少请求次数，使用缓存
  * 请求速度等监测（Android Studio ProfilerFiddler）
* **电量优化**
  * 后台任务优化（使用 JobScheduler、WorkManager 等智能调度后台任务）
  * 避免频繁的 GPS 定位与传感器操作（使用适当的定位精度与更新频率）
  * 高效使用广播与定时任务（使用合适的广播接收器（如 LocalBroadcast））
* **数据存储优化**
  * 使用合适的数据库结构（如 Room）
  * 减少存储操作频率，合并多次操作
* **多线程与异步优化**
  * 避免频繁创建线程
  * ...

## 线程

* **主线程（UI线程）**
* **子线程（处理耗时操作）**
  * 常见创建方式
    * Thread
    * AsyncTask（已过时）
    * HandlerThread
    * 线程池 (ExecutorService)
    * Kotlin 协程
* **线程池（ExecutorService）**
  * 常见线程池
    * FixedThreadPool（固定大小线程池）
    * CachedThreadPool（根据需要创建新线程，空闲线程会被回收）
    * SingleThreadExecutor（只有一个线程的线程池）
    * ScheduledThreadPoolExecutor（支持定时任务的线程池）
  * 核心参数
    * corePoolSize (核心线程数)
    * maximumPoolSize (最大线程数)
    * keepAliveTime (线程空闲存活时间)
    * BlockingQueue (阻塞队列)
* **线程间通信**
  * Handler 机制：允许在不同线程之间传递消息和 Runnable 对象
    * Looper：每个线程都有一个 Looper 对象，负责消息循环。主线程默认有 Looper
    * MessageQueue：存储消息队列
    * Handler.post(Runnable)：将 Runnable 投递到 Handler 所在的线程执行
    * Handler.sendMessage(Message)：发送消息
  * runOnUiThread()：在 Activity 或 View 中提供的方法，允许在主线程上执行 Runnable。本质是 Handler 机制的封装
  * View.post(Runnable)：类似 runOnUiThread()
  * Kotlin 协程：通过 withContext(Dispatchers.Main) 切换到主线程
  * EventBus
* **线程同步与锁**
  * synchronized 关键字
  * Lock 接口及其实现类（ReentrantLock、ReadWriteLock 等）
  * volatile 关键字（强调其只能保证可见性，不能保证原子性）
  * 原子类（AtomicInteger、AtomicBoolean 等）
  * 死锁：产生原因、避免方法
* **后台线程**
  * IntentService（Android 11弃用，用 JobIntentService ， WorkManager 代替）
  * WorkManager
* **线程状态**
  * New
  * Runnable
  * Blocked
  * Waiting
  * Timed Waiting
  * Terminated

## 数据存储

* **内部存储**
  * 文件存储
    * 其他应用无法访问，无需权限
    * Context.getFilesDir()：获取应用私有文件目录。用于存储应用运行时生成或需要持久保存的文件，例如配置文件、日志文件、游戏存档等
    * Context.getCacheDir()：获取应用私有缓存目录。用于存储临时文件，例如网络请求的缓存数据、图片缓存等。系统可能会在存储空间不足时自动删除此目录下的文件
  * SharedPreferences
  * MMKV（支持跨进程）
* **外部存储**
  * 应用专属的外部存储
    * 应用专属目录下的数据卸载应用时会被清除
    * 不需要权限
    * 使用 Context.getExternalFilesDir() 方法访问
  * 公共存储 (Shared Storage) (Android 10+)
    * MediaStore API
      * 用于访问音频、视频、图片等媒体文件
    * 存储访问框架 (SAF)
      * 允许应用通过系统文件选择器访问特定文件或文件夹
  * 权限
    * 在 Android 10 之前，访问外部存储通常需要申请 READ_EXTERNAL_STORAGE 和 WRITE_EXTERNAL_STORAGE 权限
    * Android 10 引入了分区存储规则 (Scoped Storage)
    * 如果应用需要访问所有文件，需要申请 MANAGE_EXTERNAL_STORAGE 权限（Android 11 及以上）
* **数据库存储**
  * SQLite
    * 数据库创建和管理（SQLiteOpenHelper）
  * Room Database
* **网络存储**
  * 网络缓存
  * 数据同步与备份

## 网络与通信

* **网络请求**
  * HTTP协议
  * 主流框架
    * Retrofit
    * OkHttp
* **长连接与实时通信**
  * Socket（基于 TCP/UDP）
    * TCP (Transmission Control Protocol)：面向连接的可靠传输协议，提供有序、无差错的数据传输。适用于对数据完整性要求高的场景，如文件传输
    * UDP (User Datagram Protocol)：无连接的不可靠传输协议，传输速度快，但可能丢包。适用于对实时性要求高的场景，如视频通话、游戏
  * WebSocket (基于 HTTP/TCP，双向通信)
    * 在建立连接后，数据可以以帧的形式双向传输，开销比 HTTP 小，更适合实时性要求高的应用，例如在线聊天、实时游戏等
* 其他实时通信技术
  * Server-Sent Events (SSE)：服务器单向向客户端推送数据。
  * MQTT：轻量级的消息队列协议，适用于物联网等场景
* **IPC（进程间通信）**
  * Binder
    * 基于 C/S 架构，具有高性能、高安全性的特点
    * AIDL、ContentProvider 等都基于 Binder 实现
    * 适用于系统服务开发、性能敏感、灵活性需求高的场景，支持同一应用内简单通信，不涉及复杂多线程时性能优秀
  * AIDL
    * 适合需要复杂、多线程支持的进程间通信场景
  * ContentProvider
    * 主要用在跨进程的数据访问，如读取联系人、访问系统设置等
  * Messenger
    * 基于 Handler 和 Message 实现的轻量级 IPC 机制
    * 使用简单，但只能进行单向通信，且效率不如 Binder
  * Broadcast
    * 适合一对多通信场景
  * 文件
    * 适合低频的数据交换场景
  * Socket
    * 适合跨设备或跨网络的进程间通信

## 设备与传感器

* **蓝牙**
* **wifi**
* **定位**
* **NFC**
* **陀螺仪**
* **加速度**
* ...

## 权限与安全

* **权限**
  * 权限分类
    * 普通权限：无需用户手动授权，如：ACCESS_NETWORK_STATE (访问网络状态)
    * 危险权限：涉及用户隐私或设备安全，需要用户在运行时手动授权。如：CAMERA (使用相机)、READ_CONTACTS (读取联系人)
    * 特殊权限：需用户明确授予，通常需要用户在系统设置中手动开启。如：SYSTEM_ALERT_WINDOW (在其他应用上显示窗口)、WRITE_SETTINGS (修改系统设置)
  * 权限申请
    * 静态声明（AndroidManifest.xml）
    * 动态请求（运行时权限）
  * 权限撤销
    * 用户手动撤销
    * 系统自动撤销
* **安全机制**
  * 应用签名
  * 沙箱机制 (Sandbox Mechanism)
  * Google Play 保护机制
  * SELinux (Security-Enhanced Linux)：SELinux 是 Android 系统中使用的强制访问控制 (MAC) 安全机制，它进一步限制了应用和系统进程的权限，提高了系统的安全性
  * 应用隔离
* **数据加密**
  * SharedPreferences 加密（EncryptedSharedPreferences ）
  * 数据库加密（SQLCipher）
  * 文件加密（EncryptedFile）
  * 全盘加密
  * 密钥管理 (Key Management) (如：KeyStore)
  * 数据传输加密 (HTTPS)
* **逆向与防护**
  * Apk反编译
    * 工具：apktool, dex2jar, jd-gui
  * 代码混淆
    * 工具：ProGuard, R8
  * 加固
  * 反调试
  * 防篡改
  * 完整性校验
  * 第三方库的安全性
* **用户隐私保护**
  * 隐私政策
  * 数据收集和权限最小化
  * 数据透明度

## 资源管理与国际化

* **资源类型**
  * 布局
    * layout-swxxdp: 针对不同屏幕宽度 (smallest width) 的布局，例如 layout-sw600dp/ (平板)
    * layout-land：横屏布局
    * layout-xx：特定语言环境的布局文件
  * 字符串
    * values-xx/strings.xml(如 values-en)
    * values-xx-rYY/strings.xml (区域化语言环境，如 values-en-rUS)
  * 图片
    * drawable-xx：针对不同分辨率的图像资源，例如 drawable-hdpi/, drawable-xhdpi/
    * 矢量图，.9，WebP
  * 启动图标
    * mipmap
  * 颜色
    * values-night/colors.xml：夜间模式下的颜色配置
  * 样式
    * values-night/styles.xml: 夜间模式下的样式
  * 尺寸
  * XML 资源
    * 网络安全配置（network-security-config.xml）
    * 首选项 (Preferences): preferences.xml
  * 动画
    * anim: 存放动画资源
  * 原始资源
    * raw: 存放原始文件，如音频、视频等
* **资源限定符**
  * 屏幕密度 (Screen Density): ldpi, mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi, anydpi, nodpi
  * 语言和地区 (Locale): 语言代码、语言代码-r地区代码
  * 系统版本：vXX
  * ...
* **国际化 (i18n)与本地化 (l10n)**
  * 字符串国际化
    * 使用 `String.format()` 方法进行复杂的字符串格式化
    * 复数形式 (Plurals)：使用 `<plurals>` 标签处理不同数量的复数形式
  * 图标和图像
  * 时间日期,数字和货币(DateFormat,NumberFormat,Currency)
  * RTL布局（支持阿拉伯语、希伯来语等 RTL 语言）
    * 使用 `android:supportsRtl="true"` 在 `AndroidManifest.xml` 中启用 RTL 支持
    * 使用 Viewpager2
    * 使用Android studio自带的工具适配(可以批量修改marginLeft为marginStart等)
    * ...

## 应用架构

* **架构模式**
  * MVC
    * 优点： 简单易懂，易于上手
    * 缺点： View层承担了过多的职责，导致难以维护和测试；Controller层也容易变得臃肿。在Android中，Activity承担了Controller的角色，使得Activity过于庞大
  * MVP
    * 优点： View层只负责UI展示，Presenter层处理业务逻辑，解耦更加彻底，易于测试
    * 缺点： Presenter层会变得比较重，接口定义较多
  * MVVM
    * 优点： 通过Data Binding或类似机制，进一步减少了View层的代码，提高了开发效率。ViewModel负责处理UI逻辑和数据转换，更专注于View的状态管理
    * 缺点： 对于简单的UI，使用MVVM可能会显得过于复杂
  * MVI
    * 优点： 强调单向数据流，状态管理更加清晰可控，易于调试和测试，适合复杂的状态管理场景
    * 缺点： 学习曲线相对较高，需要引入额外的概念和组件
* **架构原则（SOLID + 其他）**
  * 单一职责原则（SRP，每个类应该有且只有一个职责，避免多重职责带来的复杂性）
  * 开放封闭原则（OCP，类应该对扩展开放，对修改封闭，支持功能扩展而不修改原有代码）
  * 里氏替换原则（LSP，子类应该可以替换父类，并且父类的功能不应该被破坏）
  * 接口隔离原则（ISP，不要强迫客户端依赖它们不使用的接口，接口应该小而专注）
  * 依赖倒置原则（DIP，高层模块不应该依赖低层模块，二者都应该依赖抽象；抽象不应该依赖细节，细节应该依赖抽象）
  * DRY（Don't Repeat Yourself）
  * KISS（Keep It Simple, Stupid）
  * YAGNI（You Ain't Gonna Need It）
* **架构方法**
  * 组件化
  * 模块化/插件化
  * Clean Architecture
* **架构组件和技术**
  * ViewModel
  * LiveData
  * Room
  * WorkManager
  * Dagger/Hilt/Koin
  * ...

## 设计模式

* 创建型模式 (Creational Patterns)：关注对象创建的机制，提供多种创建对象的方式，提高代码的灵活性和复用性
  * 单例模式 (Singleton)
    * 保证一个类只有一个实例，并提供全局访问点
    * 目的：控制实例数量，节约资源，避免资源冲突
    * 应用场景：全局配置对象、数据库连接池、日志管理器
  * 工厂模式 (Factory)
    * 定义一个创建对象的接口，但由子类决定实例化哪一个类
    * 目的：解耦对象的创建和使用
    * 应用场景：多个类共享同一个接口，具体类型通过工厂来决定
    * 分类: 简单工厂（非严格的设计模式）、工厂方法、抽象工厂
  * 抽象工厂模式 (Abstract Factory)
    * 提供创建一系列相关或相互依赖对象的接口，而无需指定具体类
    * 应用场景：需要创建多个产品族的对象（与工厂方法区别：工厂方法针对单一产品等级结构，抽象工厂针对多个产品等级结构。）
  * 建造者模式 (Builder)
    * 通过一步步构建复杂对象，避免构造函数过多参数
    * 应用场景：需要构建复杂对象的场景，如多步骤的 UI 界面初始化
  * 原型模式 (Prototype)：通过复制现有实例来创建新的对象，避免重复的初始化工作
    * 通过复制现有实例来创建新的对象
    * 应用场景：创建重复对象时，性能需求较高

* 结构型模式 (Structural Patterns)：关注类和对象的组合方式，通过组合形成更大的结构
  * 适配器模式 (Adapter)
    * 使得两个不兼容的接口能够协同工作
    * 应用场景：需要使用第三方库或遗留代码，但接口不兼容，例如将第三方支付接口适配到现有系统
  * 装饰器模式 (Decorator)
    * 动态地给一个对象添加额外的职责
    * 应用场景：功能扩展需要时，不修改原有代码
  * 代理模式 (Proxy)
    * 通过代理对象控制对原对象的访问
    * 应用场景：延迟加载、权限控制、远程访问等
  * 外观模式 (Facade)
    * 提供一个统一的接口，简化子系统的使用
    * 应用场景：简化系统接口，让外部代码与系统交互更简单
  * 组合模式 (Composite)
    * 允许将对象组合成树形结构来表示部分和整体的层次关系
    * 应用场景：树形结构的对象处理，如文件系统
  * 享元模式 (Flyweight)
    * 用共享对象来支持大量细粒度的对象
    * 应用场景：高效管理大量对象，节约内存资源（如图形对象的缓存）

* 行为型模式 (Behavioral Patterns)：关注对象之间的责任分配和算法
  * 观察者模式 (Observer)
    * 当一个对象的状态发生变化时，所有依赖它的对象都会被通知并更新
    * 应用场景：事件监听、数据变化通知
  * 策略模式 (Strategy)
    * 定义一系列算法，将每个算法封装起来，并使它们可以互换
    * 应用场景：多种行为选择的情况，如排序算法选择
  * 模板方法模式 (Template Method)
    * 定义一个操作中的算法骨架，将一些步骤的实现延迟到子类
    * 应用场景：处理具有固定步骤的流程，但允许子类实现某些步骤
  * 责任链模式 (Chain of Responsibility)
    * 使多个对象有机会处理请求，从而避免请求的发送者与接收者之间的耦合关系
    * 应用场景：日志处理、权限检查等链式处理需求
  * 命令模式 (Command)
    * 将请求封装为一个对象，从而使用户可以通过不同的请求来参数化客户端
    * 应用场景：操作历史、撤销操作、事务管理
  * 状态模式 (State)
    * 允许一个对象在其内部状态改变时改变它的行为
    * 应用场景：对象在不同状态下有不同的表现，如游戏角色的不同状态（攻击、休息、移动
  * 迭代器模式 (Iterator)
    * 提供一种方法顺序访问一个集合对象中的各个元素，而又不暴露该对象的内部结构
    * 应用场景：遍历集合对象
  * 中介者模式 (Mediator)
    * 用一个中介对象来封装一系列的对象交互，使得对象之间不直接相互引用
    * 应用场景：多个组件协作的场景，减少组件之间的耦合
  * 备忘录模式 (Memento)
    * 在不暴露对象实现细节的情况下，捕获一个对象的内部状态，并在以后将对象恢复到原先的状态
    * 应用场景：游戏存档、撤销功能
  * 访问者模式 (Visitor)
    * 允许在不修改元素类的前提下定义作用于这些元素的新操作
    * 应用场景：跨越多种对象的操作，如集合中多种对象的处理
  * 解释器模式 (Interpreter)
    * 设计一个解释器，用于解释特定语言的语法规则
    * 应用场景：编译器、查询解析等场景

## 打包与发布

* **应用打包**
  * 打包格式
    * APK
    * AAB (Android App Bundle)：Google 推荐的发布格式，用于动态交付
  * 多渠道打包
    * 使用 Gradle Product Flavors
    * 第三方工具（或自己写Python脚本）
  * 应用签名
* **版本适配**
  * 目标 SDK 版本与兼容性处理
  * 各版本特性差异
    * Android 6.0
      * 危险权限需要在运行时动态请求用户授权
    * Android 7.0
      * 禁止使用 file:// URI 共享文件，必须使用 content:// URI 和 FileProvider
    * Android 8.0
      * 对后台服务和广播接收器施加了限制
      * 安装未知应用权限：安装未知来源应用的权限变更，需要单独授权
    * Android 9.0
      * 使用 HTTPS 进行网络请求
      * 使用 DisplayCutout API 来避免内容被刘海遮挡
    * Android 10
      * 引入分区存储，应用只能访问自身的文件和用户授权的目录
      * Activity 后台启动限制,限制应用在后台启动 Activity
    * Android 11
      * 限制应用查看其他已安装应用的能力，在 AndroidManifest.xml 文件中声明应用需要访问的软件包
    * Android 12
      * 引入新的启动画面，可以使用SplashScreen API实现新的启动画面效果
    * Android 13
      * 应用需要请求发送通知的权限
      * 提供了新的照片选择器
    * Android 14
      * 适配新的媒体权限申请流程： 处理用户只授予部分访问权限的情况
* **发布与更新**
  * Google Play等应用商店的发布
  * 更新策略与版本管理
    * 版本号，版本名称
    * 强制更新
    * 静默更新
    * 增量更新
    * 应用内更新
    * 热更新
  * 应用分发平台（蒲公英，fir.im等）

## 开源库与工具

* **UI 库**
  * Glide
  * Jetpack Compose
  * MPAndroidChart
  * Material Components for Android
* **网络库**
  * Retrofit
  * OkHttp
* **数据库和存储库**
  * Room
  * MMKV
  * DataStore
* **测试**
  * JUnit
  * Espresso(UI自动化测试)
  * Mockito (Java Mock 框架)
  * MockK (Kotlin Mock 框架，更适合 Kotlin 项目)
* **依赖注入**
  * Dagger/Hilt
  * Koin
* **响应式编程与异步处理**
  * Rxjava
  * Kotlin Coroutines
* **其他**
  * EventBus（事件总线）
  * Tinker
  * LeakCanary

## Android 系统启动过程

* **开机引导 (Boot Process)**
  * **硬件初始化 (Bootloader)**
    * 开机时，首先加载 Bootloader。
    * Bootloader 负责硬件初始化(例如内存、时钟、外设等)、检查系统分区、加载内核
    * 启动模式：
      * 正常启动 (Normal Boot)：加载并启动内核
      * Fastboot (用于刷机、解锁等操作等)
      * Recovery Mode (用于系统恢复、更新等操作)
  * **加载并启动内核 (Linux Kernel)**
    * Bootloader 将内核映像(kernel image)加载到内存中并启动
    * 内核初始化系统资源，如 CPU、内存、驱动程序、硬件等
    * 启动 init 进程，是 Android 系统中的第一个用户空间进程，它负责启动其他进程
* **init 进程启动(PID=1）**
  * **启动 init.rc 脚本**
    * 读取并解析 `/init.rc` 脚本（以及 `/system/etc/init` 目录下的其他 init 脚本）
    * 执行脚本中的命令 (actions) 和启动服务 (services)
    * 脚本中定义了各种 actions 和 services，包括：
      * 设置系统属性 (setprop)
      * 挂载文件系统 (mount)
      * 启动守护进程 (service)
    * 启动 Zygote 进程
    * 启动 System Server 进程
* **Zygote 进程 (所有应用进程的父进程)**
  * 创建 Dalvik/ART 虚拟机实例，为后续的应用程序提供运行环境
  * 注册 JNI 方法
  * 预加载类和资源
  * 监听 AMS (Activity Manager Service) 的请求
  * fork 出新的应用进程
* **SystemServer 进程 (系统服务进程)**
  * 启动各种系统服务
    * AMS (Activity Manager Service):管理 Activity 的生命周期、进程调度等
    * PMS (Package Manager Service):管理应用程序的安装、卸载、更新等
    * WMS (Window Manager Service)：管理窗口的显示、布局等
    * 其他重要服务：InputManagerService、WindowManagerService、PowerManagerService 等
* **Launcher 启动**
  * Launcher 作为一个普通的应用程序启动
  * 加载并显示已安装的应用程序图标列表
* **应用启动**
  * 用户点击应用图标
  * Launcher 向 AMS 发送启动 Activity 的请求
  * AMS 检查应用进程是否存在
    * 如果不存在，则请求 Zygote fork 出新的进程
    * 如果存在，则直接启动 Activity
* **关键进程关系**
  * **init** 是所有用户空间进程的祖先进程
  * **Zygote** 是所有 Android 应用进程的父进程
  * **SystemServer** 进程包含许多重要的系统服务
  
## NDK

* **NDK (Native Development Kit)作用**
  * 性能密集型任务 (游戏, 音视频处理, 图像处理)
  * 访问硬件 (设备驱动程序开发。底层硬件控制：传感器、摄像头、蓝牙、Wi-Fi 等)
  * 代码复用 (移植现有 C/C++ 库)
  * 代码保护 (将核心逻辑放在 Native 层)
* **NDK 开发环境搭建**
  * Android Studio 配置
    * 安装 NDK 和 CMake
    * 配置 `local.properties` 文件 (ndk.dir, cmake.dir)
* **构建系统**
  * CMake (推荐)
    * `CMakeLists.txt` 文件 (指定源文件, 库, 编译选项)
    * `build.gradle` 文件配置 (指定 CMakeLists.txt 路径)
  * ndk-build (旧版本，逐渐弃用)
* **NDK 开发流程**
  * 创建 Native 方法 (JNI)
  * C/C++ 层实现 Native 方法 (JNI)
    * JNI 函数命名规则
    * JNI 数据类型与 Java 数据类型的映射
    * JNI 方法签名
    * JNIEnv 接口
  * 编译生成 Native 库(.so 文件)
  * 加载 Native 库：使用 System.loadLibrary() 或 System.load() 加载 .so 文件
  * 使用LLDB调试器
* **JNI (Java Native Interface)**
  * JNI 数据类型
  * JNI 方法
  * JNI 字符串处理
  * JNI 数组处理
  * JNI 对象引用
* **其他**
  * 常用库（FFmpeg，OpenCV，OpenGL 等）
  * 减少 JNI 调用次数：避免频繁的 Java 和 Native 代码之间的切换，以提高性能
  * 合理使用 JNI 引用：避免内存泄漏
  * 线程安全
  * 异常处理：在 Native 代码中处理异常并传递回 Java 层
  * ABI 管理：支持不同的 CPU 架构（armeabi-v7a, arm64-v8a, x86, x86_64 等

## 音视频

* **音频播放与录制**
  * MediaPlayer（播放音频/视频）
  * AudioRecord（录音）
  * ExoPlayer（高效的多媒体播放器）
* **视频播放与录制**
  * Camera2 API（视频录制与拍照）
  * VideoView
  * SurfaceView
* **音视频编码与解码**
  * FFmpeg（音视频转码与流媒体处理）
  * H.264、AAC编码与解码
* **实时音视频**
  * WebRTC（实时音视频通信）
  * RTSP流媒体协议
* **音频特效与处理**
  * OpenSL ES（音频处理）
  * AudioTrack（音频播放）
* **流媒体与直播**
  * RTMP
  * HLS
  * 直播架构

## Jetpack Compose

* 基础概念
  * Composable 函数
    * @Composable 注解
    * 重组 (Recomposition)
      * 重组的触发条件
      * 避免不必要的重组 (性能优化)
    * 副作用 (Side Effects)
      * `LaunchedEffect`
      * `rememberCoroutineScope`
      * `DisposableEffect`
      * `SideEffect`
      * `produceState`
    * 组合本地 (CompositionLocal)
  * 状态 (State)
    * 不可变性 (Immutability)
    * 状态提升 (State Hoisting)
    * remember
    * rememberSaveable
    * mutableStateOf
    * State<T\>
    * SnapshotStateList/Map
  * 修饰符 (Modifiers)
    * 布局修饰符 (Size、Padding、Offset、fillMaxWidth/Height、weight 等)
    * 绘制修饰符 (Background、Border、Clip、graphicsLayer 等)
    * 输入修饰符 (Clickable、PointerInput、focusable 等)
    * 约束修饰符 (constrainAs、linkTo 等，用于 ConstraintLayout)
    * 自定义修饰符
  * 生命周期 (Lifecycle)
    * Activity/Fragment 生命周期与 Compose 的关系
    * rememberSaveable 的工作原理
  * 布局 (Layout)
    * 常用布局组件 (Column、Row、Box、LazyColumn、LazyRow、LazyVerticalGrid、LazyHorizontalGrid)
    * ConstraintLayout
    * 自定义布局
    * 测量 (Measure) 和 布局 (Layout) 过程
* 组件 (Components)
  * 基础组件 (Text、Button、Image、Icon、TextField、OutlinedTextField、Checkbox、RadioButton、Switch、Slider、Divider 等)
  * 列表和网格 (LazyColumn、LazyRow、LazyVerticalGrid、LazyHorizontalGrid)
  * 导航 (Navigation)
    * Navigation Component
    * 导航图 (Navigation Graph)
    * 路由 (Routes)
    * 传递参数
    * 深层链接 (Deep Links)
  * 对话框 (Dialog) 和 底部表单 (BottomSheet)
  * 脚手架 (Scaffold) 和 顶部应用栏 (TopAppBar)
  * 动画 (Animation)
    * 状态动画 (State-based Animations): `animate*AsState`
    * 可见性动画 (Visibility Animations): `AnimatedVisibility`
    * 过渡动画 (Transition Animations): `updateTransition`
    * 无限动画 (Infinite Animations): `rememberInfiniteTransition`
    * 动画规范 (AnimationSpec): `tween`, `spring`, `keyframes`
    * 手势动画 (Gesture Animations)
* 状态管理 (State Management)
  * ViewModel
  * StateFlow、LiveData、Flow
  * UI 状态 (UI State) 的定义和管理
* 主题与样式 (Theme and Styling)
  * MaterialTheme
  * Color、Typography、Shapes
  * 自定义主题
  * 系统 UI 控制 (System UI Controller) (例如：状态栏颜色)
  * 暗黑模式 (Dark Mode) 支持
* 性能优化 (Performance Optimization)
  * 避免不必要的重组
  * 使用 key 稳定列表项
  * 延迟组合 (Lazy Composition) 的优化
  * 减少对象分配
  * 使用 remember 和 derivedStateOf
    性能分析工具 (Profiler)
* 与 View 系统的互操作 (Interoperability with View System)
  * AndroidView
  * ComposeView

## Jetpack

## Kotlin

## Flutter

## 常见问题

* 遇到的难题
* 源码
* Handler
* 事件分发
* 优化
* 热门技术
* 内存泄漏
* Activity相关

## 提问

* 技术栈
* 未来的技术方向和规划是什么
* 岗位是扩招还是人员流失
* 公司的核心产品或项目目前面临的最大技术挑战
* 项目开发周期是多长？团队对交付速度和质量的平衡是如何处理的
* 公司在行业中的竞争优势主要体现在哪些方面
* 工作具体需要做什么

[在 Android Developer 的 reference 路径下查看 Android 的 Activity](https://developer.android.com/reference/android/app/Activity)  
这里以 Activity 为例子，还可以直接通过 Package 或者 Class 来检索 Android 相关的类

[在 Android Developer 的 guide](https://developer.android.com/guide)  
可以了解 AndroidManifest ，权限，资源等
