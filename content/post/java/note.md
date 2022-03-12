---
title: "Note"
date: 2021-07-10T22:07:28+08:00
draft: falase
tags: ["Java","note"]
categories: ["Java"]
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
