---
title: "Go 的 HelloWorld"
date: 2021-03-14T15:50:03+08:00
draft: false
tags: ["hello world"]
categories: ["go"]
---

### 下载 Go

下载地址： <https://golang.google.cn/dl/>

<!--more-->

### 安装

安装完成后会自动配置环境 GOPATH，在 cmd 中输入 go version 测试，显示版本号则安装成功

### HelloWorld Demo

新建 hello.go 文件，复制保存以下代码到文件中，使用 go run 运行

```go
package main

import "fmt"

func main() {
   fmt.Println("Hello, World!")
}
```

例如在 F:\go 文件夹下新建 hello.go，写好代码保存后，在 cmd 中输入 go run F:\go\hello.go

运行起来速度可能会比较慢，等个几秒
