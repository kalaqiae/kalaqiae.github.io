---
title: "Android Handler"
date: 2021-05-06T21:34:42+08:00
draft: false
tags: ["Android","handler"]
categories: ["Android"]
---

### Handler 概要

[官方文档](https://developer.android.google.cn/reference/android/os/Handler)

Handler 可以发送、处理 Message 和与线程关联的 Runnable 对象 MessageQueue ，每个 Handler 实例都与一个线程和该线程的消息队列关联。创建新的 Handler 时会绑定到 Looper。它将消息和线程传递到该 Looper 的消息队列，并在该 Looper 的线程上执行它们

Handler 两个主要用途：在将来某个时刻执行消息和线程。在不同线程（切换线程）按顺序执行操作

发送方法有 post(Runnable) , postDelayed(Runnable, long), sendMessage(Message) 等
默认通过 handleMessage(Message) 处理接收 Message

### Handler、Message、MessageQueue以及Looper  

* Handler 负责发送和处理消息（Handler发送消息给 MessageQueue 和接收 Looper 返回的消息并且处理消息）
* Message 用来携带需要的数据
* MessageQueue 消息队列（实际用链表实现的），负责存放 Handler 发送过来 Message
* Looper 负责不停的从 MessageQueue 中取 Message 交给 Handler 处理
  
Handler 通过 sendMessage 发送 Message 到 MessageQueue 队列，Looper 通过 loop() 从 MessageQueue 取出 Message，再经过 msg.target.dispatchMessage 交给 Handler 的 handleMessage() 进行处理

<!--more-->

![handler](https://cdn.jsdelivr.net/gh/kalaqiae/picBank/img/handler.webp)

### 简单示例

```kotlin

class MainActivity : AppCompatActivity() {

    // 在主线程中创建 Handler，绑定主线程的 Looper,不写Looper.getMainLooper()，只写Handler()就是绑定到当前线程，这里不写也是绑定到主线程，为了代码更清晰推荐要写，显式指定 Looper
    private val mainHandler = Handler(Looper.getMainLooper()) { message ->
        // 在主线程中处理消息
        when (message.what) {
            1 -> {
                Log.d("MainHandler", "Received message in main thread")
                // 可以在这里更新 UI
                // textView.text = "Message received!"
            }
        }
        true
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // 在子线程中执行任务并切换到主线程
        startBackgroundTask()
    }

    private fun startBackgroundTask() {
        // 启动一个子线程
        Thread {
            // 发送消息到主线程
            val message = mainHandler.obtainMessage(1)
            mainHandler.sendMessage(message)

            // 或者直接 post 一个 Runnable 到主线程
            mainHandler.post {
                Log.d("MainHandler", "Running in main thread")
                // 可以在这里更新 UI
                // textView.text = "Task completed!"
            }
        }.start()
    }
}
```

### 发送消息

发送消息最后都是调用到 sendMessageAtTime ，sendMessageAtTime 最后返回 enqueueMessage 方法

enqueueMessage(queue, msg, uptimeMillis) 中将调用发送消息的 Handler 与 Message 进行绑定

MessageQueue 中的 enqueueMessage 将 Message 放入 MessageQueue

成功放入消息队列返回 true 。处理消息队列正在退出则失败，返回 false

Handler中部分发送消息代码如下

```java
    public final boolean post(@NonNull Runnable r) {
       return  sendMessageDelayed(getPostMessage(r), 0);
    }

    public final boolean postDelayed(@NonNull Runnable r, long delayMillis) {
        return sendMessageDelayed(getPostMessage(r), delayMillis);
    }

    public final boolean sendMessage(@NonNull Message msg) {
        return sendMessageDelayed(msg, 0);
    }

    public final boolean sendMessageDelayed(@NonNull Message msg, long delayMillis) {
        if (delayMillis < 0) {
            delayMillis = 0;
        }
        return sendMessageAtTime(msg, SystemClock.uptimeMillis() + delayMillis);
    }

    public boolean sendMessageAtTime(@NonNull Message msg, long uptimeMillis) {
        MessageQueue queue = mQueue;
        if (queue == null) {
            RuntimeException e = new RuntimeException(
                    this + " sendMessageAtTime() called with no mQueue");
            Log.w("Looper", e.getMessage(), e);
            return false;
        }
        return enqueueMessage(queue, msg, uptimeMillis);
    }

    private boolean enqueueMessage(@NonNull MessageQueue queue, @NonNull Message msg,
            long uptimeMillis) {
        //将调用发送消息的Handler与Message进行绑定
        msg.target = this;
        msg.workSourceUid = ThreadLocalWorkSource.getUid();

        if (mAsynchronous) {
            msg.setAsynchronous(true);
        }
        return queue.enqueueMessage(msg, uptimeMillis);
    }   
```

MessageQueue 中的 enqueueMessage

```java
boolean enqueueMessage(Message msg, long when) {
        if (msg.target == null) {
            throw new IllegalArgumentException("Message must have a target.");
        }
        if (msg.isInUse()) {
            throw new IllegalStateException(msg + " This message is already in use.");
        }

        synchronized (this) {
            if (mQuitting) {
                IllegalStateException e = new IllegalStateException(
                        msg.target + " sending message to a Handler on a dead thread");
                Log.w(TAG, e.getMessage(), e);
                msg.recycle();
                return false;
            }

            msg.markInUse();
            msg.when = when;
            Message p = mMessages;
            boolean needWake;
            if (p == null || when == 0 || when < p.when) {
                // New head, wake up the event queue if blocked.
                msg.next = p;
                mMessages = msg;
                needWake = mBlocked;
            } else {
                // Inserted within the middle of the queue.  Usually we don't have to wake
                // up the event queue unless there is a barrier at the head of the queue
                // and the message is the earliest asynchronous message in the queue.
                needWake = mBlocked && p.target == null && msg.isAsynchronous();
                Message prev;
                for (;;) {
                    prev = p;
                    p = p.next;
                    if (p == null || when < p.when) {
                        break;
                    }
                    if (needWake && p.isAsynchronous()) {
                        needWake = false;
                    }
                }
                msg.next = p; // invariant: p == prev.next
                prev.next = msg;
            }

            // We can assume mPtr != 0 because mQuitting is false.
            if (needWake) {
                nativeWake(mPtr);
            }
        }
        return true;
    }
```

### 处理消息

Looper.loop() 方法中通过死循环调用 queue.next() 取出消息使用 dispatchMessage(msg) 处理将要执行的消息

优先级 Message 的 callback > Handler 的 mCallback > Handler 的 handleMessage

使用 Handler 的 sendMessage 方法，最后在 handleMessage(Message msg) 方法中来处理消息。

使用 Handler 的 post 方法，最后在 Runnable 的 run 方法中来处理，

Looper.loop()部分代码：

```java
    public static void loop() {
        //通过myLooper方法拿到与线程绑定（执行了Looper.prepare方法的线程）的Looper
        final Looper me = myLooper();
        if (me == null) {
            throw new RuntimeException("No Looper; Looper.prepare() wasn't called on this thread.");
        }
        //从Looper中得到MessageQueue
        final MessageQueue queue = me.mQueue;
        ...
        //死循环
        for (;;) {
            //从消息队列中不断取出消息
            Message msg = queue.next(); // might block
            if (msg == null) {
                // No message indicates that the message queue is quitting.
                return;
            }
            ...
            try {
                //处理消息
                msg.target.dispatchMessage(msg);
                if (observer != null) {
                    observer.messageDispatched(token, msg);
                }
                dispatchEnd = needEndTime ? SystemClock.uptimeMillis() : 0;
            } catch (Exception exception) {
                if (observer != null) {
                    observer.dispatchingThrewException(token, msg, exception);
                }
                throw exception;
            } finally {
                ThreadLocalWorkSource.restore(origWorkSource);
                if (traceTag != 0) {
                    Trace.traceEnd(traceTag);
                }
            }
            ...
            msg.recycleUnchecked();
        }
    }
```

Handler中的dispatchMessage方法

```java
public void dispatchMessage(@NonNull Message msg) {
    //msg.callback 就是 Runnable 对象
    if (msg.callback != null) {
        handleCallback(msg);
    } else {
        //向 Hanlder 的构造函数传入一个 Handler.Callback 对象，并实现 Handler.Callback 的 handleMessage 方法
        if (mCallback != null) {
            if (mCallback.handleMessage(msg)) {
                return;
            }
        }
        //无需向 Hanlder 的构造函数传入 Handler.Callback 对象，但是需要重写 Handler 本身的 handleMessage 方法
        handleMessage(msg);
    }
}
```

### ThreadLocal

线程内部的数据存储类，通过它存储的数据只有在它自己的线程才能获取到，其他线程是获取不到的

Handler 主要利用了 ThreadLocal 在每个线程单独存储副本的特性

### 其他  

* Looper 相关

    Looper.prepare 方法的作用就是将实例化的Looper与当前的线程进行绑定  

    在子线程中使用 Handler 要调用Looper.prepare() , Looper.loop() ，主线程不用写，是因为 framework 层的 Android 的主线程 ActivityThread  类调用了 Looper.prepareMainLooer()

    创建 Handler 的代码需要放在 Looper.prepare(); & Looper.loop();中间执行，这是因为创建 Handler 对象时需要聚合 Looper 对象（默认使用的是当前线程的 Looper），而只有执行 Looper.prepare();之后，才会创建该线程私有的 Looper 对象，否则创建 Handler 会抛异常

    每个线程只允许调用一次 Looper.prepare()

    **线程切换**：由于多个线程之间共享内存空间，所以 Handler 可以在线程A把消息存放到 MessageQueue，Looper 可以在线程B把消息取出来，一存一取之间就实现了线程的切换

* ANR

    ANR 是 Android 中的一种机制，它是在应用没有按时完成 AMS 指定的任务才触发的。组件在创建时会向 AMS 申请开始计时，当完成创建后会通知 AMS 取消计时

    涉及到 Linux pipe/epoll 机制，简单说就是在主线程的 MessageQueue 没有消息时，便阻塞（epoll.wait）在 loop 的 queue .next() 中的 nativePollOnce() 方法里，此时主线程会释放 CPU 资源进入休眠状态，直到下个消息到达或者有事务发生，通过往 pipe 管道写端写入数据来唤醒主线程工作

* 一直死循环不会造成 cpu 浪费么

    在没有消息的时候,会阻塞在 nativePollOnce 方法上，让出 cpu 资源，进入休眠状态，当有新的任务进入时会重新唤醒 cpu

* 同步屏障

    同步屏障（SyncBarrier）是 Handler 用来筛选高低优先级消息的机制，即：当开启同步屏障时，高优先级的异步消息优先处理。

    平时要发送同步屏障postSyncBarrier需要反射才能使用

    在 android 中 为了更快响应 UI 刷新 choreographer 使用到了

<!-- ## 使用
## 内存泄漏 -->
<!-- https://juejin.cn/post/6844903574246440967#heading-8
https://segmentfault.com/a/1190000022221446
https://www.jianshu.com/p/70d5785ee4c3 -->
