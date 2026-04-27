---
title: "Mac Input Method"
date: 2026-03-08T23:52:07+08:00
draft: true
tags: ["Mac"]
categories: ["Mac"]
---

## 输入法

- **[Rime (中州韵输入法引擎)](https://rime.im/)**：开源、快速、跨平台的输入法框架。其在不同平台有不同的名称：
  - **macOS**: **Squirrel (鼠须管)**
  - **Windows**: **Weasel (小狼毫)**
  - **Linux**: IBus-Rime 或 Fcitx5-Rime
  - **Android/iOS**: 同文 (Trime) / 仓鼠 (Hamster)
- **[雾凇拼音 (Rime-ice)](https://github.com/iDvel/rime-ice)**：Rime 社区目前最火、口碑最好的词库与配置方案。它不仅提供了高质量的词库，还优化了默认配置，解决了 Rime 原生“难配置”的痛点，且全平台通用。

### 安装与配置步骤

1. **安装 Squirrel (鼠须管)**：
   - 从 Rime 官网下载并安装 Squirrel
   - 在系统偏好设置的键盘中配置好输入法

2. **清理 Rime 配置目录**：
   - 删除 `~/Library/Rime/` 下的所有文件（包括隐藏文件）

3. **安装雾凇拼音**：

   ```bash
   # 进入 Rime 配置目录
   cd ~/Library/Rime/
   
   # 克隆雾凇拼音配置（使用 --depth 1 加快克隆速度）
   git clone https://github.com/iDvel/rime-ice.git . --depth 1
   ```

4. **后续更新**：

   ```bash
   cd ~/Library/Rime/
   git pull
   ```

5. **修改配置**

配置文件在 ~/Library/Rime

因为更新后会覆盖所以不要修改原有文件，新增 squirrel.custom.yaml，rime_ice.custom.yaml，配置可以参考原来的，写法有一点不一样

```yaml
patch:
  # 横排显示
  style/candidate_list_layout: linear
```

```yaml
patch:
  # 默认关闭emoji输入
  switches/@3/reset: 0
  # 【候选词优化】
  "menu/page_size": 8
```

> **提示**：在 Mac 上安装 Squirrel 后，通过部署雾凇拼音方案，可以实现无广告、极速且联想准确的输入体验

### 其他

开启模糊拼音

用户词库学习

自动中英文空格

中英文混输

程序员终端自动英文

程序员词库

候选词优化

UI优化

备份词库git init
git add .
git commit -m "rime config"

隐藏好功能 /快速符号

Ctrl + `   切换输入方案

Rime-Deployer：如果你觉得手动改配置文件太麻烦，可以尝试在 GitHub 上找一些自动化的部署工具。

Squirrel-Designer：在线的皮肤编辑器，所见即所得。
