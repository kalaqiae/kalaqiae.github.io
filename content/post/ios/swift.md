---
title: "Swift"
date: 2023-04-08T10:50:05+08:00
draft: false
tags: ["iOS"]
categories: ["iOS"]
---

### 基础

[英文教程](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/)

[中文教程](https://swift.bootcss.com/)

<!--more-->

简单记录一下

```swift
//变量 类型用冒号声明，加?表示可选类型（可空(nil)），加!表示隐式解析可选类型(不可空)，或者不写类型，会自动推断，使用时加!强制解析(forced unwrapping)
var myVariable: String? = "An optional string."
var assumedString: String! = "An implicitly unwrapped optional string."
var forcedString: String = myVariable!
var forcedString: String = assumedString

//常量
let myConstant = 11

//数组
let emptyArray = Int[]()

var numList = [1, 2, 3]
for item in numList {
    if item = 1 {
        print(item)
    }
}

//字典
let emptyDictionary = Dictionary<String, Int>()

let numberOfLegs = ["spider": 8, "ant": 6, "cat": 4]
for (animalName, legCount) in numberOfLegs {
    print("\(animalName)s have \(legCount) legs")
}

//构造函数
init(){}

var text: String
init(text: String) {
    self.text = text
}

//析构
//实例释放之前被自动调用  
//子类继承了父类的析构器，并且在子类析构器实现的最后，父类的析构器会被自动调用。即使子类没有提供自己的析构器，父类的析构器也同样会被调用  
//通常你不需要使用deinit,当你的实例化对象不在使用时，系统会自动帮你管理内存，但一些自定义的情况会涉及自己手动deinit  
deinit {}

//接口 关键字 protocol

//区间
let num = 1...3 //1,2,3
let num = 1..<3 //1,2
numList[...2]//从开头到索引2 或 2... 从索引2到结尾

//int 有无符号类型 UInt8 范围是 0到255，2的8次方，还有 UInt32 UInt64 ，UInt 在32位平台上和 UInt32 长度相同，在64位平台上和 UInt64 长度相同
let minValue = UInt8.min  // minValue 为 0，是 UInt8 类型
let maxValue = UInt8.max  // maxValue 为 255，是 UInt8 类型

//Double 表示64位浮点数 Float 表示32位浮点数
//Double 精确度很高，至少有 15 位小数，而 Float 只有 6 位小数

//Bool 布尔值

//类型转换
let three = 3
let pointOneFourOneFiveNine = 0.14159
let pi = Double(three) + pointOneFourOneFiveNine
let integerPi = Int(pi)

//元组(tuples) 把多个值组合成一个复合值
//类型和元素命名依情况可省略，简单的写是这样 let http404Error = (404, "Not Found")
let http404Error: (Int, String) = (code: 404,msg: "Not Found") 
let (statusCode, statusMessage) = http404Error
//如果只想要一个 另一个可以用下划线代替
let (justTheStatusCode, _) = http404Error
//直接访问
let code = http404Error.0
let msg = http404Error.1
//有命名时
let code = http404Error.code
print("The status code is \(statusCode)") //输出 The status code is 404 没有 \() 则 The status code is (404),\() 类似 kotli n里的 $

//可选类型 optionals 以下两种声明是相等的
var optionalInteger: Int?
var optionalInteger: Optional<Int>

//nil 表示没有值 在 Objective-C 中，nil 是一个指向不存在对象的指针。在 Swift 中，nil 不是指针——它是一个确定的值，用来表示值缺失

//空合运算符
a ?? b 等于 a != nil ? a! : b
//结构体(struct)是值类型 类是引用类型

//self 表示当前对象或实例,类似 java 的 this

//方法用 func 声明

```

<!-- 错误处理 -->
