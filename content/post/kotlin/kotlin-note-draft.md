---
title: "Kotlin Note Draft"
date: 2026-02-09T10:00:00+08:00
draft: true
tags: ["Kotlin"]
categories: ["Kotlin"]
---

## 导航

* 学习路线：入门 → 常用 → 进阶 → 工程化
* 使用方式：先补齐每节的“概念 / 用法 / 易错点 / 链接”

<!--more-->

## Kotlin vs Java（快速对照）

* **对象与匿名内部类**
  * object 表达式
  * SAM 接口与 lambda
* **static 的替代方案**
  * 顶层函数/属性
  * object 单例
  * companion object 与 @JvmStatic
* **类型与装箱拆箱**
  * 基本类型与包装类型
  * 原生数组 vs 泛型数组（IntArray vs Array<Int>）

## 基础语法与控制流

* **变量与类型推断**
  * val/var
  * 类型标注与可读性
* **控制流（表达式化）**
  * if/when 作为表达式
  * for/while
  * ranges：until/downTo/step
* **字符串与异常**
  * 字符串模板
  * try/catch/finally

## 类型系统（Null 与类型转换）

* **Null Safety**
  * 可空类型（T?）
  * 安全调用（?.）与 Elvis（?:）
  * 非空断言（!!）的使用边界
* **类型判断与转换**
  * is 与 smart cast
  * as / as?
* **初始化相关**
  * lateinit 与 isInitialized
  * lazy
  * 初始化顺序（property / init / constructor）

## 函数（从常用到进阶）

* **函数定义**
  * 默认参数/命名参数/可变参数
  * Unit 返回与表达式体
* **扩展**
  * 扩展函数
  * 扩展属性
* **内联与泛型**
  * inline / noinline / crossinline
  * reified 泛型
* **函数引用**
  * ::function / ::property

## 面向对象与语言结构

* **类与构造**
  * 主构造/次构造
  * init
* **数据与结构化能力**
  * data class：copy/componentN/equals/hashCode
  * 解构声明（destructuring）
* **单例与伴生**
  * object
  * companion object
* **层级与约束**
  * open/final/abstract
  * sealed class / sealed interface
  * enum class

## 委托（Delegation）

* **属性委托**
  * lazy
  * observable / vetoable
  * 自定义委托
* **接口委托**
  * class A(b: B) : I by b

## 泛型

* **泛型基础**
  * 约束（where / T : X）
  * 类型擦除（JVM）
* **型变**
  * out / in
  * 星投影（*）

## 集合、序列与标准库

* **集合模型**
  * 只读与可变（List vs MutableList）
  * List/Set/Map 选择建议
* **常用操作**
  * map/filter/flatMap
  * take/drop/slice
  * groupBy/associate
* **Sequence**
  * 惰性计算与适用场景
  * 性能与可读性权衡

## Lambda / 高阶函数 / 作用域函数 / DSL

* **Lambda 与高阶函数**
  * 函数类型
  * 闭包捕获与注意点
* **SAM 与函数式接口**
  * 何时可用 lambda 替代 object : Interface
* **作用域函数**
  * let/run/with/apply/also：语义与选型
* **DSL（选写）**
  * receiver（带接收者的函数类型）

## 协程与并发（Kotlin Coroutines）

* **协程基础**
  * suspend
  * CoroutineScope 与结构化并发
  * Dispatchers 与线程切换
* **取消与异常**
  * 取消传播
  * supervisor 与异常处理
* **Flow（选写）**
  * 冷流/热流
  * StateFlow/SharedFlow
* 关联笔记：[coroutines.md](file:///Users/kalaqiae/blog/kalaqiae.github.io/content/post/kotlin/coroutines.md)

## JVM / Android 互操作

* **注解与可见性**
  * @JvmStatic / @JvmField / @JvmOverloads / @JvmName
  * @Throws
* **Nullability 互操作**
  * 平台类型（platform types）
  * @Nullable/@NotNull 与调用约束
* **反射基础**
  * KClass 与 Class
  * ::class / javaClass

## 工程化与最佳实践

* **可读性约定**
  * 不可变优先（val）
  * 表达式优先（when/if）
* **模块边界与放置位置**
  * 扩展函数放哪里
  * domain/model/ui 的分层建议
* **质量与规范（选写）**
  * 格式化与静态检查（ktlint/detekt）

## 常见坑与速查

* **初始化与生命周期**
  * init 与属性初始化顺序
  * lateinit 的边界
* **集合与可变性**
  * 只读集合不是不可变集合
  * 可变引用逃逸
* **性能相关**
  * 装箱拆箱
  * inline 与高阶函数开销
  * sequence 链式操作的代价

## 参考

* Kotlin 官方文档：https://kotlinlang.org/docs/home.html
* Kotlin 中文站：https://book.kotlincn.net/text/home.html
