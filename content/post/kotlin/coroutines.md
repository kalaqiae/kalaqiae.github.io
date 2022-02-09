---
title: "Kotlin 协程"
date: 2021-04-09T23:14:11+08:00
draft: false
tags: ["Kotlin","coroutines"]
categories: ["Kotlin"]
---

### 启动协程

<!-- | 方式               | 说明                                                                             |
| :------------------|:--------------------------------------------------------------------------------|
| GlobalScope.launch | 启动一个新的线程，在新线程上创建运行协程，不堵塞当前线程                             |
| runBlocking        | 创建新的协程，运行在当前线程上，所以会堵塞当前线程，直到协程体结束                    |
| GlobalScope.asyn   | 启动一个新的线程，在新线程上创建运行协程，并且不堵塞当前线程，支持 通过await获取返回值 | -->

#### launch

启动一个新的线程，在新线程上创建运行协程，不堵塞当前线程，返回一个Job类型的对象

```kotlin
launch {
    //do sth.
}
```
<!--more-->

#### runBlocking

创建新的协程，运行在当前线程上，所以会堵塞当前线程，直到协程体结束。它旨在将常规的阻塞代码桥接到以挂起方式编写的库中，以供在main函数和测试中使用，不推荐使用

```kotlin
runBlocking {
    //do sth.
}
```

#### async

类似launch {}，不同的是返回一个 Deferred&lt;T> 实例，并可以在协程体中自定义返回值，通过.await() 获得最终结果  
Deferred也是一个Job

```kotlin
fun asyncTest() {
    runBlocking {
        println("current thread = ${Thread.currentThread().name}")
        val deferred = async {
        println("async thread = ${Thread.currentThread().name}")
        delay(1000)
        println("async end")
        //需要通过标签的方式返回
        return@async "123"
    }
        println("current thread end")
        val result = deferred.await()
        println("result = $result")
        //当前线程休眠以便调度线程有机会执行
        Thread.sleep(3000)
    }
}
```

<!-- #### 用法

少用GlobalScope，用MainScope，使用kotlin委托写个基类

### 协程上下文(CoroutineContext )

协程总是运行在一些以 CoroutineContext 类型为代表的上下文中 -->

### 协程启动模式

| 模式         | 功能                                           |
| :------------|:----------------------------------------------|
| DEFAULT      | 立即执行协程体                                 |
| ATOMIC       | 立即执行协程体，但在开始运行之前无法取消          |
| UNDISPATCHED | 立即在当前线程执行协程体，直到第一个 suspend 调用 |
| LAZY         | 只有在需要的情况下运行                          |

```kotlin
runBlocking {
    val job = GlobalScope.launch(start = CoroutineStart.LAZY) {
        println("1: " + Thread.currentThread().name)
    }
    // LAZY模式要通过start或者join调用
    job.start()

}
```

### 协程调度器(CoroutineDispatcher)  

确定了相关的协程在哪个线程或哪些线程上执行

* Dispatchers.Default  
未指定时都是默认使用Dispatchers.Default，运行在父协程的上下文中
* Dispatchers.Main  
主线程
* Dispatchers.Unconfined  
当前在主线程就在主线程执行，如果启动子线程导致切换线程，就在切换的那个线程执行，不被限制在任何特定的线程，一般不使用
* Dispatchers.IO  
基于 Default 调度器背后的线程池，并实现了独立的队列和限制，因此协程调度器从 Default 切换到 IO 并不会触发线程切换
* newSingleThreadContext,newFixedThreadPoolContext  
此API将来会被替换,为协程的运行启动一个新线程。当不再需要的时候，使用 close 函数，或存储在一个顶层变量中使它在整个应用程序中被重用

```kotlin
launch(Dispatchers.Default) { // 将会获取默认调度器
    println("Default: I'm working in thread ${Thread.currentThread().name}")
}
launch(newSingleThreadContext("MyOwnThread")) { // 将使它获得一个新的线程
    println("newSingleThreadContext: I'm working in thread ${Thread.currentThread().name}")
}
```

### 协程作用域(CoroutineScope)

定义协程作用范围  

* GlobalScope  
顶层协程，生命周期只受整个应用程序的生命周期限制，与启动的作用域无关且独立运作。不建议在GlobalScope使用异步或启动

* coroutineScope  
设计用于并行分解工作。当此作用域中的任何子协程异常，该作用域将异常，并且所有其他子协程都将被取消。父协程子协程相互影响。

* supervisorScope  
通过SupervisorJob创建的CoroutineScope  
当此作用域中的子协程异常，该作用域及其他子协程不受影响。作用域异常则作用域中的子协程都失效。父协程影响子协程。

* MainScope  
等于SupervisorJob() + Dispatchers.Main的效果  

>public fun MainScope(): CoroutineScope = ContextScope(SupervisorJob() + Dispatchers.Main)

#### SupervisorJob

子协程的异常或取消不会导致父协程异常，也不会影响其他子协程，因此，父协程可以实施自定义策略来处理其子协程的异常：

* 通过CoroutineExceptionHandler处理使用launch创建的子协程异常。
* 使用async创建的子协程异常可以通过Deferred.await处理所得的值。

如果作用域指定了父协程，那么其父协程异常或取消时，该父协程的所有子协程也被取消。

#### 在安卓中使用

* ViewModelScope  
为应用中的每个 ViewModel 定义了 ViewModelScope。如果 ViewModel 已清除，则在此范围内启动的协程都会自动取消
* LifecycleScope  
为每个 Lifecycle 对象定义了 LifecycleScope。在此范围内启动的协程会在 Lifecycle 被销毁时取消

### 取消

所有kotlinx.coroutines中的挂起函数都是可被取消的。它们检查协程的取消，并在取消时抛出 CancellationException。

```kotlin
val startTime = System.currentTimeMillis()
val job = launch(Dispatchers.Default) {
    var nextPrintTime = startTime
    var i = 0
    while (i < 5 && isActive) { // 可以被取消的计算循环
        // 每秒打印消息两次
        if (System.currentTimeMillis() >= nextPrintTime) {
            println("job: I'm sleeping ${i++} ...")
            nextPrintTime += 500L
        }
    }
}
delay(1300L) // 等待一段时间
println("main: I'm tired of waiting!")
job.cancelAndJoin() // 取消该作业并等待它结束
println("main: Now I can quit.")
```

如果不加isActive条件输出结果如下，加了之后可以直接取消，不用等循环结束，就不会有sleeping 3，4
>job: I'm sleeping 0 ...  
job: I'm sleeping 1 ...  
job: I'm sleeping 2 ...  
main: I'm tired of waiting!  
job: I'm sleeping 3 ...  
job: I'm sleeping 4 ...  
main: Now I can quit.  

### 异常

#### 异常传播  

当协程出现异常时，会根据当前作用域触发异常传递，查看上文的[协程作用域](#协程作用域coroutinescope)（主要关注coroutineScope，supervisorScope的传播）

#### 异常处理  

* launch内部出现未捕获的异常时尝试触发对父协程的取消，能否取消要看作用域的定义，如果取消成功，那么异常传递给父协程，否则传递给启动时上下文中配置的CoroutineExceptionHandler中，如果没有配置，会查找全局（JVM上）的CoroutineExceptionHandler进行处理，如果仍然没有，那么就将异常交给当前线程的UncaughtExceptionHandler处理  
* async在未捕获的异常出现时同样会尝试取消父协程，但不管是否能够取消成功都不会后其他后续的异常处理，直到用户主动调用await时将异常抛出

#### join和await  

join只关心协程是否执行完，await则关心运行的结果。

异常但是有输出结果Hello,

```kotlin  
runBlocking {
    val job = launch {
        val two = async { 1 / 0 } //故意异常
    }
    println("Hello,")
    job.join()
}
```

异常并且one.await()的值也得不到

```kotlin
runBlocking {
    val one = async { 1 + 1 }
    val two = async { 1 / 0 } //故意异常
    println("one: " + one.await() + " two: " + two.await() + " answer: ${one.await() + two.await()}")
}
```

### 其他

* delay() 是一个特殊的 挂起函数 ，它不会造成线程阻塞，但是会 挂起 协程，并且只能在协程中使用  
* cancelAndJoin 它合并了对 cancel 以及 join 的调用  
* 超时使用withTimeout或withTimeoutOrNull，区别是withTimeout会抛异常，withTimeoutOrNull返回null

```kotlin  
runBlocking {
    val result = withTimeoutOrNull(1300L) {
        repeat(1000) { i ->
            println("I'm sleeping $i ...")
            delay(500L)
        }
        "Done" // will get cancelled before it produces this result
    }
    println("Result is $result")
}
```

如果注释掉repeat，得到结果Result is Done

* delay(),await(),withContext被修饰为suspend，要放在 runBlocking {}，launch {} 或者 async {} 中执行
* isActive 是一个可以被使用在 CoroutineScope 中的扩展属性。用来判断是否完成和取消
* withContext 使用指定的上下文挂起一个协程，直到完成返回结果。可以使用withContext(NonCancellable)运行不能取消的代码块

```kotlin
val job = launch {
    try {
        repeat(1000) { i ->
            println("job: I'm sleeping $i ...")
            delay(500L)
        }
    } finally {
        withContext(NonCancellable) {
            println("job: I'm running finally")
            delay(1000L)
            println("job: And I've just delayed for 1 sec because I'm non-cancellable")
        }
    }
}
delay(1300L) // 延迟一段时间
println("main: I'm tired of waiting!")
job.cancelAndJoin() // 取消该作业并等待它结束
println("main: Now I can quit.")
```

英文官方文档  
<https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines/index.html>  
<https://kotlinlang.org/docs/composing-suspending-functions.html>

<!-- 参考  
https://juejin.cn/post/6844903937749975054
https://www.kotlincn.net/docs/reference/coroutines/coroutines-guide.html
https://juejin.cn/user/2365804754513085/posts -->
