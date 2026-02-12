---
title: "Mac Brew"
date: 2026-02-09T15:36:46+08:00
draft: true
tags: ["Mac","brew"]
categories: ["Mac"]
---

相关：[Mac Note](/post/mac/mac-note/)

## 概述

Homebrew 更适合用来装“系统级、全局通用、基本只需要最新版”的基础工具；但它不是万能软件下载器，也不是所有开发环境的最佳安装方式。

最主要收益：可脚本化（Brewfile），换新 Mac 时更容易一键还原；同时减少手动处理依赖的成本。

使用前先想清楚这些常见坑点：

- 依赖容易越装越多
- 自动升级带来不确定性（尤其是 CI/团队协作时）
- 可能和 Python/Node 等其他工具链冲突（PATH、动态库、头文件）
- 版本可控能力有限（通常偏向最新版；Cask 基本无法锁版本）
- 卸载不一定干净（残留文件/配置）

## 基本原则

- 永远不要对 brew 命令使用 sudo
- 先看清楚再装：`brew info <name>`，重点关注 caveats（PATH、keg-only、服务）
- 不要盲目 `brew upgrade` 全局升级：优先 `brew outdated`，再按需 `brew upgrade <name>`
- 用 Brewfile 管理安装清单，避免“手工散装”导致难以迁移与回滚
- 别把 brew 当“万能软件下载器”或“语言版本管理器”

## 适用场景

- 推荐用 brew：通用 CLI 工具、系统级小工具、不在意固定版本的 GUI 应用
- 谨慎用 brew：会强影响 PATH/动态库的工具链（Python/Node/Java）、数据库/缓存服务、对 ABI 敏感的依赖
- 不建议用 brew：项目强依赖特定版本且需要长期锁定、团队需要严格可复现（优先用版本管理器、容器或项目自带安装方式）

## 开发语言版本（版本管理器优先）

Python/Node/Java 这类语言版本建议交给版本管理器；brew 更适合只负责安装这些管理器本身，减少与项目工具链冲突。

- Python：pyenv（可用 brew 安装 pyenv，再用 pyenv 安装/切换 Python）
- Node.js：fnm 或 nvm（项目需要切版本时）
- Java：sdkman

## 安装

安装 Command Line Tools（如果已安装会提示无需重复安装）：

```bash
xcode-select --install
```

安装 Homebrew：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

安装后把 Homebrew 写入 PATH（zsh，推荐写到 `~/.zprofile`）：

```bash
# Apple Silicon 
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

```
Apple Silicon 默认前缀是 `/opt/homebrew`，Intel 默认前缀是 `/usr/local`。通常写到 `~/.zprofile`（登录 shell）即可，避免在 `~/.zshrc` 里每次启动都重复执行。

安装完成后验证：

```bash
brew --version
command -v brew
brew --prefix
brew doctor
```
`brew --prefix` 会输出 Homebrew 的安装前缀目录；`brew doctor` 有提示时按建议处理即可。

### 替换镜像

如果你在国内网络环境下拉取很慢，可以用镜像加速瓶装包（bottles）和 API 元数据。

临时替换（仅当前终端）：

```bash
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
```

永久替换（写入 zsh 配置）：

```bash
echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"' >> ~/.zprofile
echo 'export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"' >> ~/.zprofile
```

说明：

- `HOMEBREW_BOTTLE_DOMAIN`：只影响 bottle（二进制预编译包）下载地址
- `HOMEBREW_API_DOMAIN`：只影响公式/仓库元数据拉取（如 `brew search/info/outdated`）

更多镜像与说明：

- USTC：<https://mirrors.ustc.edu.cn/help/homebrew-bottles.html>
- TUNA：<https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/>

## 相关概念

### Formula / Cask / Tap

- Formula：命令行工具与库（大多数 `brew install xxx`）
- Cask：GUI 应用（`brew install --cask xxx`）
- Tap：额外的软件源（相当于“增加仓库”）

例子：

- Formula：git、curl、openssl、tree、jq、wget、ripgrep
- Cask：google-chrome、iterm2、visual-studio-code、docker、raycast

```bash
brew install git tree jq
brew install --cask iterm2 visual-studio-code
brew tap homebrew/cask-fonts
```

### link / unlink / keg-only

“keg-only” 常见含义：安装了，但默认不把可执行文件/库链接进 PATH。

```bash
brew info openssl@3
brew link openssl@3
brew unlink openssl@3
```

## 常用命令（速查）

搜索与确认：

```bash
brew search <name>
brew info <name>
```

安装与检查：

```bash
brew install <formula>
brew install --cask <cask>
brew list
brew list --cask
```

卸载：

```bash
brew uninstall <formula>
brew uninstall --cask <cask>
```

可选：同时删除应用配置/缓存（谨慎使用）：

```bash
brew uninstall --cask --zap <cask>
```
`--zap` 可能会删除用户配置/缓存，执行前先看 `brew info --cask <cask>` 的提示内容。

清理：

```bash
brew autoremove
brew cleanup -n
brew cleanup
```
Homebrew 默认会保留旧版本与下载缓存，建议定期运行 `brew cleanup`。其中 `-n` 表示先预演（只打印将要删除的内容）。

复现与脚本化（装机/迁移）：

```bash
brew bundle dump --describe --force
brew bundle
```

其中 `brew bundle dump` 会生成 `Brewfile`；`brew bundle` 会按 `Brewfile` 一键安装。需要指定路径时：

```bash
brew bundle dump --file ~/.Brewfile --describe --force
brew bundle --file ~/.Brewfile
```

排错与环境信息：

```bash
brew doctor
brew config
```

## 更新策略

最常见的更新套路：

```bash
brew update
brew outdated
brew upgrade <formula>
brew upgrade --cask <cask>
```

- `brew update`：更新 Homebrew 的公式/仓库元数据（让 brew 知道“有哪些新版本”）
- `brew outdated`：列出当前可升级的条目
- `brew upgrade`：升级已安装的 formula/cask

关于 `brew update`：常见建议是“安装前先 update”，但 `brew install` 通常也会触发必要的更新；是否每次手动执行取决于你的使用习惯与网络环境。

关掉自动升级（按需使用）：

```bash
export HOMEBREW_NO_AUTO_UPDATE=1
```

锁版本（Formula 可用）：

```bash
brew pin git
brew list --pinned
brew unpin git
```

关于 Cask：

- Cask 没有“pin”的等价能力，升级更多靠你控制 `brew upgrade --cask ...` 的时机
- 某些 Cask 默认不提示升级，可用 `--greedy` 覆盖（只在你明确要强制检查时用）

```bash
brew outdated --cask --greedy
brew upgrade --cask --greedy
```

## 依赖与排错

依赖树（看“为什么会装这么多”）：

```bash
brew deps --tree <formula>
brew uses --installed <formula>
```

常见概念：

- 孤儿依赖（Orphaned dependencies）：当初为了 A 装的依赖，现在 A 已经没了，但依赖还在
- 未链接 keg（Unlinked keg）：包安装了，但没有链接进 PATH（常见于 keg-only）

查看“我主动装了哪些”（叶子包）：

```bash
brew leaves
```

清理相关命令见上面的“清理”。

## 推荐清单（按需）

基础工具（Formula）：

- git、curl、openssl、tree、jq、wget、ripgrep

常用应用（Cask）：

- iterm2、visual-studio-code、google-chrome、docker、raycast
