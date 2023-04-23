---
title: "Kotlin Note"
date: 2023-03-17T09:59:30+08:00
draft: false
tags: ["Kotlin"]
categories: ["Kotlin"]
---

[中文教程](https://book.kotlincn.net/text/home.html)

[英文教程](https://kotlinlang.org/docs/home.html)

[kotlin 文档](https://www.kotlincn.net/docs/reference/)

<!--more-->

### kotlin 对比 java

kotlin 没有 new ,所以匿名内部类 用 object: ，类似代码如下

```java
setOnClickListener(new View.OnClickListener() {})
```

```kotlin
setOnClickListener( object : View.OnClickListener{})
```

kotlin 没有 static 有三种方式来写  
顶层函数，直接新建 File  
用单例 object 修饰的类  
伴生对象 在类中写 companion object

java 中 Float 是包装类，属于对象， kotlin 的 Float 是基本类型，和 java 对应的应该是 Float?

intArrayOf(1,2) 和 arrayOf(1,2) 区别在于 intArrayOf 声明了数组的类型，就少了拆箱装箱的步骤

### 构造函数

```kotlin
    //构造函数 this 和 super 写法与 java 对比
    constructor(context: Context) : this(context, null) {}

    constructor(context: Context, text:String?) : super(context, text) {}
```

```java
    public TestClass(Context context) {
        this(context, "");
    }

    public TestClass(Context context, String text) {
        super(context, text);
    }
```

### 集合

List 类似数组，是一个有序集合 ，Set 无重复元素，这两个都继承自 Collection。map 键值对  

List

```kotlin
    //在 Kotlin 中，MutableList 的默认实现是 ArrayList， 可以将其视为可调整大小的数组
    //需要操作如添加删除则写成 mutableListOf 
    val intArray = intArrayOf(1, 2, 3, 4, 5)

    //for (i in 0 until intArray.size) for (i in 0.until(intArray.size))
    for (i in intArray.indices) {
        println(intArray[i])
    }

    for (item in intArray) {
        println(item)
    }

    intArray.forEach { println(it) }

    for ((index, value) in intArray.withIndex()) {
        println("the element at $index is $value")
    }

    //取能被2整除的
    val filterArray = intArray.filter { it % 2 == 0 }
    //filterIndexed 带数组下标，以下是过滤掉第一个元素, index 是下标， any 是值
    val filterArray = intArray.filterIndexed { index, any -> index == 0 }
    //取前两个的 takeLast 取后边的
    val takeArray = intArray.take(2)
    //取丢弃前两个的 dropLast 丢弃后边的
    val dropArray = intArray.drop(2)
    //结果 (1,2,3)
    val sliceArray = intArray.slice(0..2)
    //结果 (1,3,5)
    val sliceStepArray = intArray.slice(0..4 step 2)
    //随机取一个
    intArray.random()
```

Set

```kotlin
    val numbers = setOf(1, 2, 3, 4)
    val numbersBackwards = setOf(4, 3, 2, 1)
    println("The sets are equal: ${numbers == numbersBackwards}")//The sets are equal: true
    //mutableSetOf 对应 LinkedHashSet 保留元素插入的顺序。hashSetOf 对应 HashSet 不声明元素的顺序
```

Map

```kotlin
    val numbersMap = mapOf("key1" to 1, "key2" to 2, "key3" to 3, "key4" to 1)    
    val anotherMap = mapOf("key2" to 2, "key1" to 1, "key4" to 1, "key3" to 3)
    println("The maps are equal: ${numbersMap == anotherMap}")//The maps are equal: true
    1 in numbersMap.values//是否包含值为1
    numbersMap.containsValue(1)//同上

    //操作 map
    val numbersMap = mutableMapOf("one" to 1, "two" to 2)
    numbersMap.put("three", 3)
    numbersMap["one"] = 11
    //mutableMapOf 有序 hashMapOf 无序
```

### companion object

```kotlin
//在 kotlin 中调用直接 TestClass.mContext ，在 Java 中 GameMySaveListActivity.Companion.getMContext();
//加了 @JvmStatic 后可以写成 TestClass.getMContext();
//再加 @get:JvmName("mContext") 就可以和  kotlin 一样 TestClass.mContext;
class TestClass {
    companion object {
        @JvmStatic
        @get:JvmName("mContext")
        lateinit var mContext: Context
    }
}
```

### other

```kotlin
    //这种情况会找不到 isInit 所以 init 方法一般可以放最后
    init {
        isInit = false
    }

    var isInit = true
```

```kotlin
    //?: 使用
    val text: String? = ""
    //如果 text?.length 空则是 0 < 4 ,不空则 text?.length < 4
    if (text?.length ?: 0 < 4) {

    }
    //相当于
    if (text?.length == null || text.length < 4) {

    }
```

```kotlin
    //默认会生成一些方法，如果想重写 get set 方法 直接跟在下一行
    lateinit var mContext: Context
        private set
```

```kotlin
//:: 创建一个成员引用或者一个类引用
val c = MyClass::class
lateinit var lateString: String
//isInitialized 用来判断 lateinit var 是否初始化
::lateString.isInitialized
```

as? 用于安全类型转换。

Kotlin 一切都是对象，所有类都有一个共同的超类 Any，对于没有超类型声明的类它是默认超类，kotlin 的类默认是 final ，加 open 后才可继承

kotlin 可以嵌套函数，可以方便子函数可以直接调用父函数的对象，可能对性能有影响

toCollection 是一个扩展函数，用于将一个可迭代对象转换为指定类型的集合。

### inline 内联函数

效果相当是复制到调用的地方  
一般推荐在入参是函数时使用，可以减少调用栈

<!-- ### 扩展函数 -->

### 密封类

优点
密封类拥有抽象类的灵活，子类可以是任意的类，数据类，对象，普通类，甚至密封类  
密封类拥有枚举的限制  
子类涵盖所有情况时，使用 when 表达式，不必添加 else 分支  

相对 java 有点像可以带参数的枚举, 使用如下

```kotlin
sealed class UIEvent {
    object ShowLoading: UIEvent()
    object HideLoading: UIEvent()
    class ShowData(val message: String): UIEvent()
}


interface ISplashBaseView : IView {
    fun sendEvent(event: UIEvent)
}
```

```kotlin
class MainActivity() : BaseActivity(), ISplashBaseView {
    override fun sendEvent(event: UIEvent) {
        when (event) {
            is UIEvent.ShowLoading -> showLoading()
            is UIEvent.HideLoading -> hideLoading()
            is UIEvent.ShowData -> showData(event.message)
        }
    }

    private fun showLoading() {

    }

    private fun hideLoading() {

    }

    private fun showData(message: String) {

    }

    override fun getLayoutResId(): Int {
        return R.layout.activity_main
    }
}

```

<!-- ### 委托 -->

### 解构声明

```kotlin
//一个解构声明同时创建多个变量 和 swift 元组类似
val (name, age) = person
```
<!-- ### 序列 -->

<!-- ### 作用域函数

let run with apply also -->

### 为什么有些匿名内部类写法 object : 可以用 lambda省略

如果一个接口只有一个抽象方法(即这个接口是函数式接口或单方法接口)，那么可以使用 lambda 表达式或方法引用来代替该接口的实现。  
如果一个接口有多个抽象方法，那么必须实例化该接口并重写其中的所有方法，直接使用 lambda 表达式或方法引用是不允许的。  
如果一个类是抽象类，那么你必须实现其中的所有抽象方法，否则你的类仍然需要声明为一个抽象类。  
如果一个类实现了一个接口，那么该类必须实现该接口中的每一个方法，使用 lambda 表达式或方法引用是不允许的。  
如果一个类实现了一个接口但只想使用该接口的某些方法，则可以使用 default 方法、抽象类(包含默认实现)或者抽象的委托类(只委托某些方法)，转发该接口的所有方法到这些类，从而避免重复的编码实现。

匿名内部类 比如 new Thread(new Runnable() { ... }) 这种写法就是匿名内部类

### 无符号整形

UByte: 无符号 8 位整数，范围是 0 到 2^8 - 1  
还有 UShort UInt ULong
