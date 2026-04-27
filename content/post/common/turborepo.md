---
title: "Turborepo"
date: 2026-03-09T13:47:23+08:00
draft: true
tags: ["Turborepo"]
categories: ["Turborepo"]
---

## 概述

Turborepo 是一套面向 JavaScript/TypeScript Monorepo 的构建系统（build system），核心能力是「任务编排 + 增量构建 + 本地/远程缓存」，用很低的心智成本显著提升开发与 CI 的速度与稳定性。

本文聚焦：

- Monorepo 是什么，适合什么团队/项目
- Turborepo 与常见方案对比（Nx/Lerna/Rush/Bazel 等）
- Turborepo 项目结构与关键配置
- 常用命令、依赖与工程规范
- 常见概念（任务流水线、内部包引用、环境变量管理）
- 常见问题与注意事项

## 什么是 Monorepo

Monorepo 指「多个包/应用共用一个仓库」，常见结构是把应用（apps）与公共库（packages）放在同一个代码库里，通过 workspace（pnpm/yarn/npm）管理依赖与内部包引用。

### 适合的场景

- 多个应用共享组件库、工具库、配置（eslint/tsconfig/prettier）等
- Web、Node、工具脚本、SDK 并存，需要统一版本与发布流程
- 团队希望减少跨仓库协作成本（PR、CI、依赖升级、回滚）
- 需要更快的 CI（只跑受影响的任务、使用远程缓存）

### 不适合的场景

- 项目非常小，只有单一应用且共享代码很少
- 构建/测试本身很轻量，Monorepo 引入的工程复杂度得不偿失
- 组织边界很强：各团队必须完全隔离依赖、权限与发布节奏（可用多仓库 + 包管理策略更合适）

## 常见方案对比

Turborepo 不是包管理器，也不是完整的 Monorepo 框架，而是一个 任务调度与缓存系统。
它通常与 workspace（pnpm/yarn/npm）以及现有工具链组合使用

- **Turborepo**：擅长任务编排与缓存（本地/远程）、增量构建；配置简单，上手快。
- **Nx**：能力更“平台化”，生态更完整（generator、graph、affected、plugins）；学习成本与约束更高。
- **Lerna**：更偏包发布与版本管理（尤其是历史定位）；现代 Monorepo 常把任务编排交给 Turborepo/Nx。
- **Rush**：企业级工程治理、依赖管控更强；复杂度更高。
- **Bazel/Buck2**：更底层、更通用的构建系统，适合超大仓库与多语言；接入与维护成本更高。

选型建议（经验向）：

- 追求简单可落地：workspace + Turborepo
- 需要“全套平台化”与强约束：Nx
- 需要非常强的依赖治理/规模化：Rush 或 Bazel（视团队成熟度）

## Turborepo 的核心概念

### 任务（Task）与流水线（Pipeline）

在 Turborepo 里，你运行的通常不是「某个包的某个命令」，而是「跨多个包的同名任务」：

- 例如每个 package 都有 `build` 脚本，执行 `turbo run build` 会并行/按依赖顺序跑完所有相关包的 `build`
- 你通过配置声明任务间的依赖关系（例如应用 build 依赖内部库 build）

### 缓存（Cache）

Turborepo 会根据输入（源代码、锁文件、环境变量、依赖任务的输出等）计算哈希：

- 命中缓存：跳过执行，直接复用输出文件
- 未命中：执行任务并写入缓存

缓存分两类：

- **本地缓存**：开发机提速
- **远程缓存**：CI/多开发者共享提速（最常见的收益点）

关键点是：要正确声明每个任务的 `outputs`，否则会出现“看起来命中缓存但产物没恢复”或“总是 miss”。

### 依赖图（Dependency Graph）

依赖图来自两部分：

- workspace 的包依赖关系（`dependencies` 里引用内部包）
- turbo.json 的任务依赖关系（`dependsOn`）

一个常用模式：

- 库：`build` 产出 `dist/`
- 应用：`build` 依赖所有内部库的 `build`，然后再构建应用

## 典型项目结构

通常的默认示例：

mall
├ apps # 最终产物应用（会部署/运行）
│  ├  web
|  └ docs
│
├ packages # 可复用的库（组件、工具、配置、SDK）
│  ├ ui
│  ├ eslint-config # 共享 eslint 配置
│  └ typescript-config # 共享 tsconfig 配置
│
├ node_modules # 每个包的依赖（每个包都有自己的 node_modules）
│
├ package.json # Turborepo 根配置
├ pnpm-lock.yaml # Turborepo 根锁文件（包含所有包的依赖）
├ pnpm-workspace.yaml # 定义 workspace（包含所有包）
├ turbo.json # Turborepo 任务配置
└ README.md

约定：

- `apps/*`：最终产物应用（会部署/运行）
- `packages/*`：可复用的库（组件、工具、配置、SDK）

## 使用流程

这一节按“创建仓库 → 跑起来 → 接入 CI → Docker/发布优化”的顺序，把常见落地流程串起来。

### 1）创建项目

方式 A：使用脚手架直接生成（推荐用于快速开始）

如果你的 Monorepo 计划使用 pnpm，优先用 `pnpm dlx`：
node_modules
```bash
pnpm dlx create-turbo@latest
```

也可以使用 `npx`（在没有 pnpm 的环境更通用）：

```bash
npx create-turbo@latest
```

对比建议：

- `pnpm dlx`：更贴近 pnpm 工作流，继承 pnpm 的 registry/代理配置与 store 行为，适合团队统一 pnpm 的仓库
- `npx`：更“默认可用”，适合临时试用或机器上还没装 pnpm 的场景

方式 B：手动把现有仓库改造成 Turborepo

以 pnpm 为例：

```bash
pnpm init
pnpm add -D turbo
```

方式 C：社区已有 Turborepo 项目

### 2）规划目录与 workspace

在根目录定义 workspace（示例为 pnpm）：

```yaml
packages:
  - "apps/*"
  - "packages/*"
```

推荐约束：

- `apps` 放可部署/可运行的应用
- `packages` 放可复用库（UI、utils、配置包、SDK）

### 3）定义每个包的脚本边界

在每个 app/package 的 `package.json` 中尽量统一脚本名（示例）：

- `build`：产出可缓存的构建产物（例如 `dist/`、`.next/`）
- `dev`：开发态，通常是长驻进程
- `lint/test/typecheck`：质量任务

### 4）写 turbo.json（任务依赖 + 缓存策略）

核心目标：

- 让任务依赖关系反映真实构建顺序（例如 app build 依赖内部库 build）
- 让缓存命中可信（`outputs` 覆盖真实产物；全局配置变化能正确触发缓存失效）

### 5）本地开发与联调

常见工作流：

```bash
turbo run dev
turbo run dev --filter=web
```

### 6）接入 CI（只跑变更相关任务 + 远程缓存）

落地要点：

- CI 里优先用“按变更过滤”的方式跑任务（见下文 CI 示例）
- 配置远程缓存，让不同 runner 与不同开发者共享构建产物
- 确保 `outputs` 与 `globalDependencies` 配置到位，避免“缓存命中但结果不对”

### 7）Docker 构建优化（turbo prune）

如果你用 Docker 构建镜像，通常会配合 `turbo prune` 生成最小子仓库来提升 Docker cache 命中率（见下文 turbo prune 章节）。

## 关键配置文件

### turbo.json（任务编排与缓存策略）

一个覆盖大多数场景的示例（按需调整）：

```json
{
  "$schema": "https://turbo.build/schema.json",
  "ui": "tui",
  "globalDependencies": [
    "tsconfig.base.json",
    ".eslintrc.*",
    "babel.config.*",
    "postcss.config.*"
  ],
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "build/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "outputs": []
    },
    "test": {
      "outputs": ["coverage/**"]
    },
    "typecheck": {
      "outputs": []
    }
  }
}
```

说明：

- Turborepo 2.x 推荐使用 `tasks`；`pipeline` 属于 legacy 写法
- `dependsOn: ["^build"]` 表示“先跑依赖包的 build”
- `dev` 一般不缓存，并且是长驻进程（`persistent: true`）
- `lint/typecheck` 通常不需要输出缓存文件（`outputs: []`）
- `outputs` 需要根据你的工具链填写：例如 Next.js 用 `.next/**`，Vite 常见 `dist/**`

#### globalDependencies（很多团队的缓存踩坑点）

`globalDependencies` 用于声明“影响全仓任务缓存”的全局文件。它变化时会让相关任务缓存失效，避免出现：

- 修改了 `tsconfig.base.json` / eslint 配置，但 `build` 仍然命中旧缓存

典型应该放进去的文件：

- `tsconfig.base.json`
- eslint 配置
- `babel.config.*`
- `postcss.config.*`

### package.json（根目录脚本）

根目录脚本负责把日常命令统一起来：

```json
{
  "scripts": {
    "build": "turbo run build",
    "dev": "turbo run dev",
    "lint": "turbo run lint",
    "test": "turbo run test",
    "typecheck": "turbo run typecheck"
  }
}
```

## 常用命令速查

### 运行任务

```bash
# 跑所有 workspace 中定义了 build 的包
turbo run build

# 只跑某个包（或某个范围）的任务
turbo run build --filter=web
turbo run build --filter=apps/web
turbo run build --filter=@repo/ui

# 只跑受影响的任务（常用于 CI）
turbo run build --since=origin/main
```

### CI 常见写法（更贴近真实落地）

在 CI 里，很多团队会把“变更过滤 + 固定 cache 目录”一起用：

```bash
turbo run build \
  --filter=[origin/main] \
  --cache-dir=.turbo
```

补充说明：

- `--filter=[origin/main]` 这类写法通常用于“只跑与基准分支差异相关的包/任务”，实践里比单纯 `--since` 更常见
- `--cache-dir=.turbo` 可以让缓存目录位置更稳定（便于 CI 缓存策略或排障）
- 一些 CI 插件/封装层会提供 `affected/changed` 模式（例如封装成 `turbo run build --affected`），本质也是“按变更过滤 + 跑任务”

### 调试与可视化

```bash
# 输出更详细的日志，定位缓存命中/依赖顺序
turbo run build --verbosity=2

# 不实际执行，只展示计划（适合检查 dependsOn/filter）
turbo run build --dry-run
```

### 缓存控制

```bash
# 强制重跑（忽略缓存）
turbo run build --force

# 关闭缓存（一般只在临时排障用）
turbo run build --no-cache
```

## turbo prune（Docker / CI 构建优化必备）

很多团队用 Turborepo 的 `prune` 来优化 Docker build：只把某个应用真实需要的那部分仓库复制进镜像构建上下文。

常用命令：

```bash
turbo prune web
turbo prune web --docker
```

生成的目录通常类似：

```text
out/
  ├── apps/web
  ├── packages/ui
  ├── package.json
  └── pnpm-lock.yaml
```

好处：

- Docker cache 命中率更高（变更影响更小）
- 镜像构建速度更快（构建上下文更小、依赖安装更聚焦）

## 依赖与前置条件

### 必需依赖

- Node.js（建议在仓库内统一版本策略：例如 `.nvmrc`、`.node-version`、或 package manager 的约束）
- 一个 workspace 包管理器：pnpm / yarn / npm
- Turborepo（作为 devDependency 安装在根目录）

### 远程缓存（可选但强烈建议）

远程缓存能显著减少 CI 时间，尤其是多应用、多包仓库。常见做法：

- 使用官方/托管服务（例如与 Vercel 生态集成）
- 自建缓存存储（视团队合规与成本）

无论哪种方式，都要注意：

- CI 中要正确配置 token/环境变量
- `outputs` 与环境变量哈希规则要清晰，否则缓存命中不可信

## 内部包引用（Workspace 包之间怎么互相用）

推荐用 workspace 协议（以 pnpm 为例）声明内部依赖：

```json
{
  "name": "@repo/web",
  "dependencies": {
    "@repo/ui": "workspace:*",
    "@repo/utils": "workspace:*"
  }
}
```

工程建议：

- 内部库尽量有稳定的构建输出（如 `dist/`），并在 `package.json` 正确声明 `main/module/types/exports`
- 应用依赖内部库时，尽量依赖“构建产物”而不是跨包引用源码路径，避免构建链混乱
- 统一 TypeScript 配置（`tsconfig.base.json`）与路径策略，减少重复配置

反例与正确写法（强烈建议在团队规范里写清楚）：

❌ 不推荐：跨包直接引用源码

```ts
import "../../packages/ui/src/button";
```

常见问题：

- 打破 build pipeline：app 不再明确依赖 `@repo/ui` 的构建任务
- TS path alias 变得混乱：同一份代码可能出现“源码路径”和“包名路径”两套引用方式
- cache 容易失效或变得不可信：任务边界被绕过，输入/输出不再可控

✅ 推荐：通过包名引用

```ts
import { Button } from "@repo/ui";
```

## 环境变量管理

### 为什么环境变量会影响缓存

如果某个任务的输出会受环境变量影响（例如 `NEXT_PUBLIC_API_BASE`、`SENTRY_DSN`），那么：

- 不把它纳入哈希：可能出现“缓存命中但产物不对”
- 全量纳入：可能导致“频繁 miss”

常见策略：

- 只把真正影响构建产物的变量纳入
- 开发态（dev）任务禁用缓存
- 用不同环境（dev/staging/prod）分别构建，避免混用缓存

### turbo.json 与环境变量

在 Turborepo 中可以声明哪些环境变量会影响任务（以官方能力为准，建议以项目实际版本文档校验字段名），核心目标是：让缓存哈希与真实产物一致。

工程落地建议：

- 在每个 app 的 `.env.*` 管理环境（例如 `.env.development`、`.env.production`）
- CI 中通过环境注入，避免把敏感信息提交到仓库
- 构建产物会固化变量的框架（如 Next.js）要格外注意“缓存复用”与“环境切换”

## 使用规范与实践建议

### 任务设计

- 任务命名尽量统一：`build/lint/test/typecheck/dev`
- `build` 必须是可缓存、可复现的（同输入同输出）
- `dev` 任务不要缓存，且标记为长驻进程

### outputs 与可复现性

- 明确声明产物目录（例如 `dist/**`、`.next/**`、`coverage/**`）
- 避免把时间戳、随机数、机器路径写进产物（会导致缓存不稳定）
- 不要在任务中写出 `outputs` 之外的文件（会造成缓存恢复不完整）

### 变更仓库结构时的注意点

- 移动包目录后，更新 `--filter`、CI 路径规则、部署脚本
- 内部包 `name` 变更需要同步更新依赖引用
- 若有发布流程（npm publish），同步调整版本与 tag 策略

## 常见问题与注意事项

### 1）为什么总是缓存未命中（cache miss）？

常见原因：

- `outputs` 配置不正确或遗漏
- 任务依赖了未声明的输入（例如读取了根目录某个配置文件）
- 环境变量影响产物，但未纳入哈希（或纳入过多导致频繁 miss）
- 任务本身不稳定（输出含时间戳等）

排查建议：

- 用 `--dry-run` 和更高 verbosity 看依赖与哈希相关信息
- 先把任务简化为稳定输出，再逐步加回真实逻辑

### 2）命中缓存但运行结果不对？

常见原因：

- `outputs` 没覆盖实际产物目录，导致“恢复不完整”
- 构建产物与运行环境耦合（例如打包时注入环境变量）
- 产物被后续脚本二次修改但未纳入任务边界

### 3）dev 任务为什么不建议缓存？

开发服务器是长驻进程，输出目录通常并不稳定，而且更多依赖实时文件系统变化。缓存它往往收益不大，反而容易引入“热更新异常/进程状态不一致”等问题。

### 4）CI 怎么跑得更快？

常见组合：

- `turbo run build --filter=[origin/main] --cache-dir=.turbo` 按变更过滤 + 固定缓存目录
- 备选：`turbo run build --since=origin/main` 只跑变更相关任务
- 打开远程缓存，确保不同 runner 之间共享产物
- 把 `lint/typecheck/test` 也接入 tasks，并正确声明 `outputs`

### 5）依赖安装很慢、node_modules 体积很大？

这通常是包管理器与依赖策略问题，不是 Turborepo 本身：

- 优先使用 pnpm（硬链接+内容寻址存储，体积与速度更好）
- 避免在 apps 中重复引入重依赖，能下沉到 packages 就下沉
- 定期治理依赖（重复包、过期版本、未使用依赖）
