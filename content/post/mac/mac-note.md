---
title: "Mac Note"
date: 2024-09-26T22:06:06+08:00
draft: true
tags: ["Mac","note"]
categories: ["Mac"]
---

## 触控板

- **单指重按**：查单词 / 预览 (光标需在文本上)
- 双指点击：右键菜单
- 双指滑动：滚动页面
- 四指捏合/张开：启动台 / 显示桌面 (取决于设置，有时是五指)

<!--more-->

> **三指拖移设置路径**：辅助功能 -> 指针控制 -> 触控板选项 -> 启用拖移 (三指拖移)

- **三指轻触移动（启用三指拖移后，类似部分代替了原来要点击重按的效果）**：选中文字 / 拖拽窗口(先点击窗口)
- 三指上滑：调度中心
- 四指上滑：调度中心 (若开启了三指拖移)

选择文字时，选中后可以再放一指去滑动选择

---

## 常用快捷键

### 系统通用

> **Command + Space**：聚焦搜索 (Spotlight)  
> Command + ,：打开当前应用偏好设置  
> **Command + Q**：彻底退出程序  
> **Command + H**：隐藏当前窗口  
> **Command + M**：最小化窗口  
> **Command+tab+上箭头**：显示该应用当前所有打开的窗口（包括最小化、隐藏的窗口）
> **Command + Option + Esc**：强制退出应用 (类似任务管理器)  
> **Fn + F11**：显示桌面  
> **Control + Command + Q**：锁屏  
> **Fn + Delete**：向后删除 (Windows 的 Del)
> **Command/Fn + 上/下箭头**：滚动至顶部/底部 翻页
> **fn+f**：应用全屏
> **Command + `**：同应用不同窗口快速切换
> **Control + ↓**：查看应用所有窗口并选择
> **Command + Option + Esc** 打开强制退出窗口

### 截图与录屏

> **Command + Shift + 3**：截取全屏  
> **Command + Shift + 4**：截取选定区域,保存在桌面  
> **Command + Shift + 5**：打开截图/录屏工具栏
> **Command + Shift + control + 4**：截取选定区域并保存在剪切板

### 浏览器 (Chrome/Safari)

> **Command + T**：新建标签页  
> **Command + L**：跳转地址栏  
> **Command + R**：刷新页面  
> **Command + Option + R**：强制刷新
> **Command + 左右箭头**：页面前进/后退  
> **Command + Option + 左右箭头**：切换 Tab 标签  
> **Cmd + Shift + T**：恢复刚关闭标签页

---

## 文件管理 (Finder)

### 路径与导航

> **Command + Shift + G**：前往文件夹 (输入路径如 `/usr/local`)  
> **Command + Shift + .**：显示/隐藏 隐形文件  
> **Command + Shift + C**：前往电脑 (磁盘根目录)  
> **Command + I**：查看文件信息 (简介)  
> **Command + [** 或 **]**：后退/前进文件夹  
> **Command + 上/下箭头**：返回上级 / 进入文件夹

### 文件操作

**移动文件 (剪切)**：

> 1. 选中文件 **Command + C** (复制)  
> 2. 目标位置 **Command + Option + V** (移动)

**其他**：
> **彻底删除**：Option + Command + Delete  
> **移动到废纸篓**：Command + Delete  
> **当前位置打开终端**：需在 `键盘 -> 键盘快捷键 -> 服务 -> 文件和文件夹` 中设置，例如设置为 `Control + Option + Command + T` ，设置好后选中文件夹然后按快捷键

---

## 设置

### 键盘导航

键盘导航未开启时，系统弹窗（如“彻底删除”）无法通过 Tab 键选择“删除”按钮

## 工具

### 数码测色计

> **打开方式**：聚焦搜索 数码测色计

- **锁定光圈位置**：水平锁定光圈，Command-X。垂直锁定，Command-Y。同时两个方向锁定，Command-L
- **拷贝颜色值**：将颜色值拷贝为文本，Shift-Command-C。将颜色值拷贝为图像，Option-Command-C

### 解压工具

> The Unarchiver

### 卸载工具

> AppCleaner

### 视频播放

IINA 基于mpv

---

### 输入法

[Mac input method](/post/mac/mac-input-method/)

## 开发环境配置 (Shell & Dev)

### Shell 基础

Mac 默认使用 `zsh`，配置文件为 `~/.zshrc` (旧版为 bash / .bash_profile)。

**常用命令**：
> `chmod 755 file`：修改权限  
> `echo 'hello world!'`：打印输出  
> `python3 -V`：查看 Python 版本  
> `~/`：表示用户主目录

**脚本片段：获取当前目录**：

```bash
CURRENT_DIR=$(cd $(dirname $0); pwd)
echo $CURRENT_DIR
# 可用于输入 y/n 判断等逻辑
```

### java

查看已经安装的 java

/usr/libexec/java_home -V

---

## homebrew

[Mac Brew](/post/mac/mac-brew/) 。

---

## 其他

Raycast（或 Alfred）

Rectangle

## IDE 常用快捷键

### Android Studio

> **Control + E**：跳转到上一个编辑位置  
> **Control + Shift + E**：跳转到下一个编辑位置  
> **Control + Tab**：切换到右边的 Tab 页面  
> **Control + Shift + Tab**：切换到左边的 Tab 页面
> **Control + Option + O**：移除无用的导入  
> **Option + Enter**：快速修复  
> **Command + [**：跳转到代码块开始  
> **Command + ]**：跳转到代码块末尾  
> **Command + R**：运行当前应用  
> **Command + D**：调试当前应用  
> **Command + Option + L**：格式化代码  
> **Command + O**：查找类  
> **Command + Shift + O**：查找文件  
> **Command + N**：生成代码 (构造函数、getter/setter等)  
> **Control + J**：查看文档  
> **Command + /**：注释/取消注释行  
> **Command + Shift + /**：块注释  
> **Option + 上/下箭头**：上下移动行  
> **Command + Shift + U**：大小写转换  
> **Command + Option + T**：包围代码 (if/for/try等)  
> **F2**：跳转到下一个错误  
> **Shift + F2**：跳转到上一个错误  
> **Command + Shift + Delete**：删除行  
> **Control + Shift + Backspace**：跳转到上一个编辑位置  

### VSCode

> **Control + Tab**：跳转到下一个编辑位置  
> **Control + Shift + Tab**：跳转到上一个编辑位置  
> **Command + Shift + [**：切换到左边的 Tab 页面  
> **Command + Shift + ]**：切换到右边的 Tab 页面  
> **Command + .**：快速修复  
> Command + Shift + \：跳转到代码块开始/末尾  
> **Command + Up**：跳转到代码块开始  
> **Command + Down**：跳转到代码块末尾  
> **Command + P**：快速打开文件  
> **Command + Shift + P**：打开命令面板  
> **Command + /**：注释/取消注释行  
> **Option + Shift + F**：格式化文档  
> **Command + D**：选中下一个匹配项  
> **Command + Shift + L**：选中所有匹配项  
> **Option + 上/下箭头**：上下移动行  
> **Command + Shift + K**：删除行  
> **Command + Enter**：在当前行下方插入新行  
> **Command + Shift + Enter**：在当前行上方插入新行  
> **Command + ] 或 [**：缩进/取消缩进  
> **Command + Shift + [ 或 ]**：移动到上一个/下一个编辑组  
> **Control + Tab**：切换打开的文件  
> **Command + K, V**：预览Markdown  
> **Command + K, Z**：进入Zen模式  
> **Command + Shift + -**：跳转到上一个编辑位置
