---
title: "Android Compose"
date: 2025-11-30T01:24:38+08:00
draft: true
tags: ["Android"]
categories: ["Android"]
---

[Android Compose 官方文档](https://developer.android.com/develop/ui/compose/documentation)

[Material 组件目录](https://developer.android.com/develop/ui/compose/components)

<!-- 

还没优化

状态提升在状态和自定义组件有重复 副作用在状态和副作用有重复 列表性能优化状态应该和其他地方有重复
-->

<!--more-->

## Compose 基础理念

<!-- 三个阶段组合、布局和绘制 -->

### 声明式 UI

Jetpack Compose 采用声明式 UI 范式，以函数描述界面。UI = f(state)。
当 state 发生变化，Compose 会识别需要重组（Recomposition）的部分，只更新变更的 UI。

补充理解：ViewBinding 确实能解决 `findViewById` 的大部分痛点，但 Compose 更核心的变化在于 **不再依赖 XML + 命令式 setter 更新 UI**，而是让 UI 随状态变化通过重组自动刷新，并以 Composable 的组合方式完成组件化复用。

### 可组合函数 (Composable Functions)

可组合函数是构建 Compose UI 的基本单元，通过 `@Composable` 注解定义

- **注解与调用**：  
  带有 `@Composable` 注解的函数称为可组合函数，只能在其他 `@Composable` 函数内部调用。
  
- **参数与返回值**：  
  可接收参数以控制其外观与行为；一般没返回值（`remember` 等特例除外）。

- **幂等性与无副作用**：  
  函数执行可能随时被中断或跳过，因此必须保持**幂等性**和**无副作用**（避免修改参数、全局变量或执行外部操作）。

- **并发执行不确定性**：  
  Compose 可能以任意顺序并行执行可组合函数，因此不应依赖其执行顺序。

- **职责专注**：  
  Composable 函数可能会频繁执行，因此不要在其中进行耗时操作，应轻量、快速，专注于 UI 描述，避免包含复杂业务逻辑。

### 重组 (Recomposition)

- **重组**是 Compose 框架高效更新 UI 的过程。当应用程序的状态（State）发生变化时，Compose 只会重新执行那些依赖于该状态的 Composable 函数，跳过那些未受影响的函数。
- **Diffing 机制:** Compose 不依赖传统虚拟 DOM 的对比算法，而是在编译阶段生成元数据，精准识别需要重组的部分，实现高效更新。

### 重组的触发与优化

| 概念 | 说明 | 优化目标 |
| :--- | :--- | :--- |
| **触发条件** | **状态 (State)** 发生变化是重组的唯一驱动力。 | 确保只有真正发生变化的数据被定义为 State。 |
| **智能重组** | Compose 编译器通过比较 Composable 函数的参数是否发生变化来决定是否跳过重组。如果参数是**稳定的 (Stable)** 且未改变，则该函数调用及其子树可能会被跳过。 | 确保传递给 Composable 的参数尽可能保持稳定，并进行 **状态提升**。 |
| **状态提升 (State Hoisting)** | 将组件内部的状态移动到其父级或调用方。这使得组件无状态（Stateless），更容易重用、测试和跳过重组。 | 是 Compose 中最重要的优化和架构原则之一。 |

### 架构设计原则

- **单一数据源（Single Source of Truth）**  
  通过**状态提升（State Hoisting）**将状态集中管理，共享状态应提升至最近的共同祖先组件，确保数据一致性。

- **单向数据流（Unidirectional Data Flow）**  
  状态只能从父组件向下传递（State Down），事件则从子组件向上传递（Event Up），形成清晰、可预测的数据流。

- **组合优于继承（Composition over Inheritance）**  
  Compose 通过函数组合构建 UI，鼓励将小型、单一职责的可组合函数组合成复杂界面，提高代码复用性和可维护性。

### 理解 `State`

- 使用 `remember { mutableStateOf(...) }` 创建可变状态。
- **重点:** **不要直接读取/写入 `State` 的值**。只有当您通过 `.value` 属性读取或写入时，Compose 运行时才能知道哪个 Composable 依赖于此状态，并在状态变化时触发重组。

```kotlin
// 错误的示例：直接修改变量不会触发重组
var count = 0
Button(onClick = { count++ }) {
    Text("Count: $count") // UI 不会更新
}

// 正确的示例：使用 State 委托
var count by remember { mutableStateOf(0) }
Button(onClick = { count++ }) {
    // 每次 count.value 变化，依赖于 count 的 Composable 都会重组
    Text("Count: $count") 
}
```

## 最佳实践 (Best Practices)

1. **Composable 函数尽量无副作用**: 副作用（如网络请求、数据库操作）应在 `LaunchedEffect` 或 ViewModel 中处理。
2. **命名规范**:
    - 返回 `Unit` 的 Composable 函数使用 **PascalCase** (名词)，如 `FancyButton`。
    - 返回值的 Composable 函数使用 **camelCase** (动词/形容词)，如 `rememberState`。
3. **状态提升 (State Hoisting)**:
    - **UI = f(state)**。
    - 将状态移动到调用者，使组件变得无状态 (Stateless)，易于复用和测试。
4. **Modifier 链**:
    - 避免过长的 Modifier 链，可以将其提取为扩展属性或使用 `composed` (注意性能)。
    - **顺序很重要**: `padding` -> `background` -> `padding` 会产生不同的效果。
5. **Scaffold 使用**:
    - 优先使用 `topBar` / `bottomBar` 参数，而不是在 `content` 中手动放置。
    - 注意 `content` lambda 中的 `PaddingValues`，必须应用到内部布局，否则内容会被遮挡。

## 基础布局组件 (Layout Composables)

| 组件 | 描述 | 对应 View 概念 | 主要用途 |
| :--- | :--- | :--- | :--- |
| **`Column`** | 子项**垂直**排列 | `LinearLayout` (Vertical) | 垂直列表、表单内容 |
| **`Row`** | 子项**水平**排列 | `LinearLayout` (Horizontal) | 导航栏、按钮组 |
| **`Box`** | 子项**堆叠**排列 | `FrameLayout` | 层叠元素（如图片上的文字） |

### 尺寸与对齐 (`Arrangement` & `Alignment`)

- **`Column` (垂直方向):**
  - ***主轴 (垂直):** 使用 `verticalArrangement`（如 `Arrangement.Top`, `Arrangement.SpaceAround`）。
  - **交叉轴 (水平):** 使用 `horizontalAlignment`（如 `Alignment.Start`, `Alignment.CenterHorizontally`）。
- **`Row` (水平方向):**
  - **主轴 (水平):** 使用 `horizontalArrangement`（如 `Arrangement.Start`, `Arrangement.SpaceBetween`）。
  - **交叉轴 (垂直):** 使用 `verticalAlignment`（如 `Alignment.Top`, `Alignment.CenterVertically`）。
- **`Box` (堆叠):**
  - 使用 `contentAlignment` 控制所有子项的默认对齐方式（如 `Alignment.Center`）。
  - 子项可使用 `Modifier.align()` 单独覆盖对齐方式。

```kotlin
Row(
    modifier = Modifier.fillMaxWidth().height(50.dp),
    horizontalArrangement = Arrangement.SpaceBetween, // 水平主轴间距
    verticalAlignment = Alignment.CenterVertically     // 垂直交叉轴对齐
) { 
    Text("左侧")
    Text("右侧")
}
```

### 间距与占位 (`Spacer` & `Arrangement.spacedBy`)

- **`Spacer`** 用于在布局中插入空白区域：既能做固定间距，也能在 `Row`/`Column` 中配合 `Modifier.weight()` 充当“弹性占位”。
- 需要“列表项之间等间距”时，通常优先用 `Arrangement.spacedBy(...)`，比手动插入多个 `Spacer` 更直观。

```kotlin
@Composable
fun SpacerExamples() {
    Column(Modifier.padding(16.dp)) {
        Text("上")
        Spacer(Modifier.height(12.dp)) // 固定垂直间距
        Text("下")
    }

    Row(Modifier.fillMaxWidth().padding(16.dp)) {
        Text("左")
        Spacer(Modifier.width(8.dp)) // 固定水平间距
        Text("右")
    }

    Row(Modifier.fillMaxWidth().padding(16.dp)) {
        Text("标题")
        Spacer(Modifier.weight(1f)) // 占据剩余空间，把右侧内容顶到末端
        Text("操作")
    }

    Row(
        modifier = Modifier.fillMaxWidth().padding(16.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text("A")
        Text("B")
        Text("C")
    }
}
```

### 自动换行布局 (`FlowRow`)

`FlowRow` 适合做“标签/Chip 自动换行”的布局：子项会按行排列，放不下就换到下一行。它目前是实验 API，通常需要 `@OptIn(ExperimentalLayoutApi::class)`。

```kotlin
@OptIn(ExperimentalLayoutApi::class)
@Composable
fun TagFlow(tags: List<String>) {
    FlowRow(
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        tags.forEach { tag ->
            Text(
                text = tag,
                modifier = Modifier
                    .background(MaterialTheme.colorScheme.surfaceVariant, RoundedCornerShape(999.dp))
                    .padding(horizontal = 10.dp, vertical = 6.dp)
            )
        }
    }
}
```

### 分页（Pager）

`HorizontalPager` / `VerticalPager` 按“页”展示内容，左右/上下滑动切页，类似 `ViewPager2`。适合引导页、图片轮播、按页切换的内容区。

```kotlin
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun SimplePager(pages: List<String>) {
    val pagerState = rememberPagerState { pages.size }
    HorizontalPager(state = pagerState) { page ->
        Text(text = pages[page], modifier = Modifier.fillMaxSize())
    }
}
```

### 滑动布局（Scroll）

- `verticalScroll` / `horizontalScroll`：少量内容的简单滚动（会一次性组合全部子项）。
- 长列表滚动：优先用 `LazyColumn` / `LazyRow`（按需组合，见下一节）。
- 自定义“拖动/滑到状态”：用 `draggable` / `swipeable`（后文有示例）。

```kotlin
@Composable
fun SimpleScrollView() {
    val scrollState = rememberScrollState()
    Column(Modifier.fillMaxWidth().verticalScroll(scrollState)) {
        repeat(50) { index ->
            Text("Item $index", Modifier.padding(16.dp))
        }
    }
}
```

### 列表与网格 (Lazy Composables)

Compose 中的列表组件通过“懒惰”加载机制，实现了与 `RecyclerView` 相当的性能。

- **更少的 Adapter 样板代码**：在传统 `RecyclerView` 中，列表通常需要编写 `Adapter`/`ViewHolder`、处理多类型 Item、Diff 更新等。Compose 里列表内容直接用 `LazyColumn` 的 DSL 描述（`item`/`items`），把“如何渲染每一项”写成一个 Composable 即可。  
  但仍建议为每个 item 提供稳定 `key`，并把点击等事件通过参数向上回传。

- **`LazyColumn` & `LazyRow`**
  - **用法:** 仅在需要时才组合和布局可见项目，是实现高性能滚动列表的首选。
  - **DSL (Domain Specific Language):** 使用 `items()`, `item()`, `itemsIndexed()` 来定义列表内容。

```kotlin
LazyColumn {
    // 单个项目
    item { HeaderText("我的列表") } 
    // 动态项目列表
    items(
        dataList, 
        key = { item -> item.id },          // 性能优化：为每个 item 指定唯一键
        contentType = { item -> item.type } // 性能优化：根据内容类型优化重用
    ) { item -> 
        ListItem(item) 
    }
}
```

- **`key` 和 `contentType` 补充**
  - **`key`:** 类似于 `RecyclerView` 的稳定 ID，用于在列表数据变化（增删改）时，帮助 Compose 正确识别和重用 Composable 实例，避免不必要的重组或状态丢失。**强烈推荐使用**。
  - **`contentType`:** 帮助 Compose 在列表滚动时，根据内容类型判断是否可以重用 Composable，进一步提升重组效率。

- **`LazyVerticalGrid` & `LazyHorizontalGrid`**
  - 用于创建网格布局。必须定义 `GridCells` 来确定网格的列数或大小。

```kotlin
// 网格布局示例：固定 3 列
val items = (1..50).toList()
LazyVerticalGrid(
    columns = GridCells.Fixed(3), // 定义固定 3 列
    contentPadding = PaddingValues(8.dp),
    verticalArrangement = Arrangement.spacedBy(8.dp),
    horizontalArrangement = Arrangement.spacedBy(8.dp)
) {
    items(items) { item ->
        Card(modifier = Modifier.aspectRatio(1f)) {
            Text("Item $item", Modifier.wrapContentSize(Alignment.Center))
        }
    }
}
```

## 核心 UI 组件 (Widget Composables)

### 文本 (`Text`)

- **基本用法:** 类似于 `TextView`。
- **样式 (`style`):**
  - 通过 `style` 参数传入 `TextStyle`。通常使用主题提供的样式，如 `MaterialTheme.typography.titleLarge`。
  - 可在 `TextStyle` 中设置 `color`, `fontSize`, `fontWeight`, `textAlign` 等。
- **溢出处理 (`maxLines` & `overflow`):**
  - `maxLines = 2`: 限制最大行数为 2。
  - `overflow = TextOverflow.Ellipsis`: 当内容超出 `maxLines` 时，使用省略号（...）表示。

```kotlin
Text(
    text = "这是一个很长很长的文本，用来测试Compose的溢出处理机制。",
    style = MaterialTheme.typography.bodyLarge.copy(color = Color.Blue),
    maxLines = 2,
    overflow = TextOverflow.Ellipsis
)
```

### 按钮 (`Button`, `IconButton`, `FloatingActionButton`)

Compose 按钮需要一个 `onClick` lambda 和一个内容 Composable。

```kotlin
Button(onClick = { /* 执行操作 */ }) {
    Text("标准按钮")
}
```

- **不同 Button 风格简要说明 (Material 3):**
  - **`Button`:** 默认的填充按钮，强调最高的行动力。
  - **`ElevatedButton`:** 略微抬高的填充按钮，用于与背景有冲突时增加区分度。
  - **`FilledTonalButton`:** 使用辅助色调填充，比标准按钮的强调程度略低。
  - **`OutlinedButton`:** 只有边框的按钮，强调程度中等，用于次要操作。
  - **`TextButton`:** 只有文本的按钮，强调程度最低，用于非关键操作。

### 对话框 (`AlertDialog`)

`AlertDialog` 用于需要用户确认/取消的轻量交互。通常用一个 `Boolean` 状态控制显示/隐藏，并在 `onDismissRequest` 中关闭。

```kotlin
@Composable
fun DeleteConfirmDialog() {
    var open by remember { mutableStateOf(false) }

    Button(onClick = { open = true }) {
        Text("删除")
    }

    if (open) {
        AlertDialog(
            onDismissRequest = { open = false },
            title = { Text("确认删除？") },
            text = { Text("删除后无法恢复") },
            confirmButton = {
                TextButton(onClick = { open = false }) { Text("确定") }
            },
            dismissButton = {
                TextButton(onClick = { open = false }) { Text("取消") }
            }
        )
    }
}
```

### 输入框 (`TextField` & `OutlinedTextField`)

输入框是 **有状态 (Stateful)** 的组件，必须手动管理其输入的文本状态。

- **状态提升原则的应用:** 将输入状态提升到父组件管理。

```kotlin
var name by remember { mutableStateOf("") }
OutlinedTextField(
    value = name,
    onValueChange = { name = it }, // 每次输入都更新状态
    label = { Text("姓名") },
    leadingIcon = { Icon(Icons.Default.Person, contentDescription = "输入姓名") }
)
```

### 图片 (`Image` & 图标 `Icon`)

- **`Image`:** 用于显示位图 (Bitmap)。
  - **重要:** 必须提供 `contentDescription` 来增强无障碍性。

```kotlin
// 加载本地 Drawable 资源
Image(
    painter = painterResource(id = R.drawable.ic_logo),
    contentDescription = "应用Logo",
    modifier = Modifier.size(64.dp),
    contentScale = ContentScale.Fit // 图像缩放模式
)
// 假设使用 Coil/Glide 加载网络图片（伪代码，需要集成库）
/*
AsyncImage(
    model = "https://example.com/image.jpg",
    contentDescription = "网络图片",
    modifier = Modifier.fillMaxWidth()
)
*/
```

- **`Icon`:** 用于显示向量图或 Material 图标。

```kotlin
Icon(
    imageVector = Icons.Filled.Star,
    contentDescription = "收藏星标",
    tint = Color.Yellow
)
```

### 卡片与表面 (`Card` & `Surface`)

- **`Surface` (表面)**
  - **核心作用:** 赋予 Composable 背景色、海拔高度 (Elevation) 和形状，是 Material 组件的基础。
  - **特性:** 可以响应点击（Ripple 效果）和处理形状/裁剪。
- **`Card` (卡片)**
  - **核心作用:** 提供了 Material Design 中的卡片容器，用于组织相关内容。
  - **特性:** 默认有背景色、圆角和阴影（Elevation），是基于 `Surface` 构建的。

```kotlin
// Surface 示例：创建一个圆角的、有点击效果的背景
Surface(
    modifier = Modifier.padding(8.dp).clickable { /* ... */ },
    shape = RoundedCornerShape(12.dp),
    shadowElevation = 4.dp, // 模拟阴影/海拔
    color = MaterialTheme.colorScheme.surfaceVariant
) {
    Text("这是一个 Surface", modifier = Modifier.padding(16.dp))
}

// Card 示例
Card(
    modifier = Modifier.fillMaxWidth().padding(16.dp),
    elevation = CardDefaults.cardElevation(defaultElevation = 6.dp)
) {
    Column(modifier = Modifier.padding(16.dp)) {
        Text("卡片标题")
        Text("卡片内容描述...")
    }
}
```

## 页面结构组件 (Scaffold)

`Scaffold` (脚手架) 是 Material Design 应用界面的高级容器，它简化了标准屏幕结构的搭建。

- **`Scaffold` 的主要插槽 (Slots):**
  - `topBar`: 放置 `TopAppBar` (标题栏)。
  - `bottomBar`: 放置 `NavigationBar` 或 `BottomAppBar` (底部导航)。
  - `snackbarHost`: 用于显示 SnackBar。
  - `floatingActionButton`: 放置 `FloatingActionButton` (FAB)。
  - `content`: 屏幕的主要内容区域。

**好处:** `Scaffold` 负责协调所有这些组件，并自动处理内边距，确保内容不会被顶部或底部栏遮挡。

```kotlin
Scaffold(
    topBar = { TopAppBar(title = { Text("我的应用") }) },
    floatingActionButton = { 
        FloatingActionButton(onClick = { /* ... */ }) { 
            Icon(Icons.Filled.Add, "添加")
        }
    }
) { paddingValues ->
    // content 将使用 paddingValues 来避免被 top/bottom bar 遮挡
    LazyColumn(contentPadding = paddingValues) { 
        // 列表内容
    }
}
```

## Modifier

### 作用与职责

- **Modifier** 是一个**有序的、不可变的**元素列表，用于装饰或添加行为到 Composable 元素上。
- 它的核心职责是：**改变 UI 外观、调整布局、添加交互。**

### 链式调用与顺序原则

- **核心原则:** Modifier 是按顺序从左到右应用的。后面的 Modifier 是在前一个 Modifier 产生的效果（尤其是尺寸和测量）基础上继续应用的。
- **影响结果:** 这意味着 **顺序至关重要**。例如，`.padding()` 和 `.background()` 的顺序将直接决定边距是否包含背景色。

```kotlin
// 顺序影响结果示例：
// 示例 1: 先内边距，后背景
// 效果: 蓝色背景会覆盖整个区域，包括 16dp 的内边距。
Text("Hello", modifier = Modifier
    .padding(16.dp) // 1. 先测量/增加 16dp 空间
    .background(Color.Blue) // 2. 将整个 16dp+Text 区域设置为蓝色
)

// 示例 2: 先背景，后内边距
// 效果: 蓝色背景只覆盖 Text 内容区域，内边距是透明的。
Text("Hello", modifier = Modifier
    .background(Color.Blue) // 1. Text 内容区域设置蓝色背景
    .padding(16.dp) // 2. 在蓝色内容外部增加 16dp 的透明边距
)
```

### 常见 Modifier

常见的 Modifier 涵盖了尺寸、边距、外观、交互和布局调整。

```kotlin
Modifier
    // 尺寸与约束
    .fillMaxWidth()        // 填充父级最大宽度
    .height(50.dp)         // 固定高度
    .size(100.dp)          // 固定尺寸 (宽高)
    .wrapContentHeight()   // 尺寸刚好包裹内容 (wrapContent是默认行为，常用于覆盖 fill 行为)

    // 边距与定位
    .padding(8.dp)         // 设置内边距 (Padding)，位于 Composable 边界内部
    .offset(x = 10.dp, y = 10.dp)     // 微调位置，不影响布局流

    // 外观与背景
    .background(Color.Blue, shape = RoundedCornerShape(4.dp)) // 设置背景，可指定形状
    .border(1.dp, Color.Red, CircleShape) // 添加边框，可指定形状
    .clip(CircleShape)     // 将内容裁剪成圆形

    // 交互与输入
    .clickable { /* 处理单击事件 */ } // 使 Composable 可点击，自动带 Ripple 效果
    .combinedClickable(
        onSingleClick = { /* ... */ }, 
        onDoubleClick = { /* ... */ }
    ) 
    .pointerInput(Unit) { /* ... */ } // **最底层的手势输入 API，用于复杂的自定义手势**

    // 布局与权重 (仅在 Row/Column 中有效)
    .weight(1f)             // 占用 Row/Column 剩余空间的 1 份
    .align(Alignment.CenterVertically) // 覆盖父级对交叉轴的对齐
    .layout { measurable, constraints -> /* ... */ } // **高级用法：完全自定义测量和放置逻辑**
```

### 自定义组合 Modifier

为了提高代码的复用性和可读性，我们可以创建自己的组合 Modifier 函数，将多个常用 Modifier 封装在一起。

### 实现方式

通过编写一个扩展函数，接收 `Modifier` 作为参数并返回一个新的 `Modifier`。

```kotlin
// 定义一个自定义组合 Modifier 扩展函数
fun Modifier.standardCardStyle(isPremium: Boolean = false) = composed {
    // composed {} 块用于创建有状态或需要 CompositionLocal 的 Modifier
    this // 接收调用链中上一个 Modifier
        .fillMaxWidth()
        .padding(vertical = 4.dp, horizontal = 16.dp)
        .border(
            width = if (isPremium) 2.dp else 1.dp,
            color = if (isPremium) Color.Gold else Color.Gray,
            shape = RoundedCornerShape(8.dp)
        )
        .clip(RoundedCornerShape(8.dp))
        .clickable { /* 默认点击逻辑 */ }
}

// 在 Composable 中的使用
Card(
    modifier = Modifier
        .standardCardStyle(isPremium = true) // 仅一行代码应用复杂样式
) {
    Text("高级卡片内容")
}
```

## 预览 (Preview)

- **目的:** 允许开发者在不运行应用程序的情况下，直接在 Android Studio 的设计视图中查看 Composable 的渲染效果。
- **限制:** 被 `@Preview` 注解的 Composable **不能接受任何参数**。

```kotlin
@Preview(showBackground = true, name = "默认按钮预览")
@Composable
fun DefaultButtonPreview() {
    // 必须调用一个无参数的 Composable 或在内部创建 Composable
    MyButton(text = "点击") 
}
```

### 多预览配置 (Multi-Preview)

为了确保 Composable 在不同场景下表现正确，可以使用多个 `@Preview` 注解来模拟不同环境。

```kotlin
@Preview(
    name = "深色模式",
    uiMode = Configuration.UI_MODE_NIGHT_YES // 切换系统 UI 模式
)
@Preview(
    name = "大字体模式",
    fontScale = 1.5f // 模拟用户设置的字体大小缩放
)
@Preview(
    name = "平板",
    // 使用设备规格字符串模拟特定的屏幕配置
    device = "spec:shape=Normal,width=1024,height=768,unit=dp,dpi=480" 
)
@Composable
fun CombinedPreviews() {
    MyApplicationTheme { // 确保在预览中应用主题
        MyComponent()
    }
}
```

### `PreviewParameterProvider`

- **作用:** 允许 `@Preview` 注解的 Composable 接收一个参数列表，从而在设计视图中一次性渲染多种数据状态。
- **实现:** 通过实现 `PreviewParameterProvider<T>` 接口来提供数据序列。

```kotlin
// 1. 定义数据提供者
class NameProvider : PreviewParameterProvider<String> {
    override val values = sequenceOf("Alice", "Bob Smith", "Very Long Name Here")
}

@Preview
@Composable
fun GreetPreview(@PreviewParameter(NameProvider::class) name: String) {
    Text(text = "Hello, $name")
}
```

## Android Studio Compose 工具

### Live Edit, Live Literal

- **Live Literal:** 实时更新代码中的基本类型常量（如字符串、数字、布尔值）在预览和模拟器中的显示，无需重新编译。
- **Live Edit:** 在您编辑 Composable 函数体时，自动将代码更改部署到模拟器或设备上，无需完整重新运行应用。

> **如何使用:**  
1.确保 Android Studio 设置中开启了 Live Edit (通常在 Settings -> Editor -> Live Edit)。  
2.在模拟器上运行应用。修改 Composable 函数体内的代码，例如将 `Text("Hello")` 改为 `Text("World")`，更改会立即同步到运行中的应用。

### Interactive Preview (交互式预览)

- **作用:** 允许在 Android Studio 的 Design 视图中，像在真实设备上一样与 Composable 进行交互，用于测试状态变化和交互逻辑。

> **如何使用:**  
1.在 Design 视图中找到 `@Preview` 预览窗口。  
2.点击预览窗口右上角的 **"Start Interactive Mode"** 按钮（通常是一个播放图标）。  
3.此时可以直接点击预览中的按钮、输入文本、滚动列表，观察 UI 状态变化。

### Layout Inspector 调试 Compose UI

- **作用:** 用于在运行时检查 Compose UI 树的层级结构、Modifier 链的顺序和属性，以及 Composable 的重组次数。

> **如何使用:**  
1.运行应用到设备或模拟器上。  
2.在 Android Studio 顶部菜单栏点击 **View -> Tool Windows -> Layout Inspector**。  
3.选择您的应用进程。在 Inspector 视图中，您可以点击任何 UI 元素，查看其使用的 Composable 名称、参数值和完整的 Modifier 链。

## 资源管理与字符串处理

### 字符串资源

- **基本字符串与格式化：** 使用 `stringResource`。

```kotlin
// 获取普通字符串
Text(text = stringResource(R.string.app_name))

// 获取带参数的字符串
// 假设 strings.xml 中定义 <string name="welcome">Welcome, %1$s!</string>
val userName = "Gemini"
Text(text = stringResource(R.string.welcome, userName))
```

- **复数形式 (Plurals)：** 用于根据数量自动选择正确的复数形式。

```xml
<plurals name="messages_count">
    <item quantity="one">You have 1 new message.</item>
    <item quantity="other">You have %d new messages.</item>
</plurals>
```

```kotlin
val messageCount = 5
Text(
    // 第一个参数是资源ID，第二个参数是数量 (Int)，第三个是格式化参数 (通常是数量本身)
    text = pluralStringResource(
        id = R.plurals.messages_count, 
        count = messageCount, 
        formatArgs = arrayOf(messageCount)
    )
)
```

- **HTML 格式文本：**

```kotlin
Text(
    text = buildAnnotatedString {
        withStyle(style = SpanStyle(color = Color.Blue)) {append("蓝色文本")}
        append("普通文本")
        withStyle(style = SpanStyle(fontWeight = FontWeight.Bold)) {append("粗体文本")}
    }
)
```

### 颜色、尺寸、图片与字体资源访问

通过专门的 `*Resource` 函数访问对应的资源类型。

```kotlin
// 访问颜色 (res/color)
val primaryColor = colorResource(R.color.colorPrimary)
Surface(color = primaryColor) {
    /* ... */
}

// 访问尺寸 (res/dimen)
val iconPx = dimensionResource(R.dimen.icon_size) // ⚠️ 返回 Float (像素值)
Icon(
    imageVector = Icons.Default.Star,
    contentDescription = null,
    modifier = Modifier.size(iconPx.dp) // 需要手动转换为 Dp
)

// 访问图片 (res/drawable 或 res/mipmap) 返回 `Painter`
Image(
    painter = painterResource(R.drawable.ic_image),
    contentDescription = "图标描述"
)

// 访问字体 (res/font)
val customFontFamily = FontFamily(
    Font(R.font.robot_bold, FontWeight.Bold)
)
Text(
    text = "使用自定义字体",
    style = LocalTextStyle.current.copy(fontFamily = customFontFamily)
)
```

> **注意 `dp` 转换:** `dimensionResource` 返回的是像素值 (Float)，通常需要手动使用 `.dp` 扩展属性转换为 Compose 的 `Dp` 类型。

### 主题颜色访问 (推荐方式)

对于 Material Design 元素，**强烈推荐**使用 `MaterialTheme.colorScheme` 访问主题定义的颜色和 `MaterialTheme.typography` 访问主题排版，以确保 UI 风格一致性。

```kotlin
// 推荐使用主题颜色
Text(
    text = "主题颜色示例",
    color = MaterialTheme.colorScheme.primary // 访问主题主色
)

// 推荐使用主题排版
Text(
    text = "大标题",
    style = MaterialTheme.typography.headlineLarge
)
```

### 动态颜色 (Dynamic Color)

Material 3 支持从壁纸提取颜色。

```kotlin
val colorScheme = when {
    dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
        val context = LocalContext.current
        if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
    }
    darkTheme -> DarkColorScheme
    else -> LightColorScheme
}
```

```kotlin
@Composable
fun ResourceExample() {
    val context = LocalContext.current
    Column {
        Text(text = stringResource(R.string.greeting))
        Image(
            painter = painterResource(R.drawable.header_image),
            contentDescription = stringResource(R.string.header_desc)
        )
        val padding = dimensionResource(R.dimen.padding_medium)
    }
}
```

## 自定义组件

### 设计原则：状态提升 (State Hoisting)

- **概念:** 将组件的内部状态移动到组件的调用方（父级）。
- **好处:**
  - **无状态 (Stateless) 组件:** 组件不持有状态，只接受状态和事件作为参数，易于重用和测试。
  - **单一事实来源 (Single Source of Truth, SSOT):** 状态集中管理，避免数据不一致。

```kotlin
// 1. 无状态组件：只接收值和事件
@Composable
fun StatelessCounter(count: Int, onIncrement: () -> Unit) {
    Button(onClick = onIncrement, enabled = count < 10) {
        Text("Count: $count")
    }
}

// 2. 有状态组件（状态被提升）：管理状态
@Composable
fun CounterScreen() {
    // 状态被提升到这里
    var count by remember { mutableStateOf(0) }
    StatelessCounter(
        count = count,
        onIncrement = { count++ } // 事件处理
    )
}
```

### Slot API

- **作用:** 允许父组件向子组件注入不同的内容（Composable），实现高度灵活和可定制的组件结构，类似于 View 系统的 `include` 或自定义容器。
- **实现:** 通过在 Composable 函数参数中定义类型为 `@Composable () -> Unit` 的 lambda。

```kotlin
// 自定义 Card，包含 Title Slot 和 Content Slot
@Composable
fun CustomCard(
    title: @Composable () -> Unit,
    content: @Composable () -> Unit
) {
    Card(modifier = Modifier.padding(16.dp)) {
        Column(modifier = Modifier.padding(8.dp)) {
            // 渲染 Title Slot
            title() 
            Spacer(Modifier.height(8.dp))
            // 渲染 Content Slot
            content() 
        }
    }
}

// 使用 Slot API
@Composable
fun ProfileScreen() {
    CustomCard(
        title = { Text("用户资料", style = MaterialTheme.typography.titleLarge) },
        content = { Text("这是详细信息...") }
    )
}
```

## Material Design 3 (M3) 主题

### 核心三要素

- **颜色 (`ColorScheme`):** 定义 UI 的颜色集（Primary, Secondary, Surface, Background 等）。
- **排版 (`Typography`):** 定义文本样式集（Headline, Title, Body 等）。
- **形状 (`Shape`):** 定义组件的默认形状和圆角（如 Small, Medium, Large）。

### 应用主题

- **`MaterialTheme`:** 是 Compose 应用的入口点，它为整个 Composable 树提供了颜色、排版和形状的默认值。所有 Material 组件都会自动查找当前 `MaterialTheme` 的值。

```kotlin
@Composable
fun MyApplicationTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colors = if (darkTheme) DarkColorScheme else LightColorScheme
    MaterialTheme(
        colorScheme = colors,
        typography = AppTypography, // 自定义排版
        shapes = AppShapes,         // 自定义形状
        content = content
    )
}
```

### 局部主题覆盖 (`CompositionLocalProvider`)

- **作用:** 允许在 Composable 树的特定子部分覆盖或提供上下文数据，包括主题元素。
- **实现:** 使用 `CompositionLocalProvider` 配合 `LocalColorScheme`, `LocalTypography` 或其他自定义的 `CompositionLocal` 实例。

```kotlin
@Composable
fun NestedThemeExample() {
    // 父级使用 LightTheme
    MaterialTheme(colorScheme = LightColorScheme) {
        Column {
            Text("Light Theme Text")
            // 局部覆盖：在这个子树中切换为 Dark Theme 的颜色
            CompositionLocalProvider(LocalColorScheme provides DarkColorScheme) {
                Text("Dark Theme Text") // 这里的文本会使用 DarkColorScheme 的默认颜色
            }
        }
    }
}
```

## 状态管理 (State Management)

### 基础状态 API

- **`mutableStateOf()`:** 创建一个可变的 `State` 对象。只有当 `.value` 属性发生变化时，Compose 才会触发重组。
- **`remember`:** 将对象存储在 Composition 内存中。当 Composable 重组时，它会记住并返回这个对象，防止状态丢失。用于 UI 本地状态，如展开/折叠标志。
- **`rememberSaveable`:** 作用类似于 `remember`，但它允许状态在配置更改（如屏幕旋转）或进程被系统杀死后，通过 Android 的 `SavedStateHandle` 机制进行序列化和恢复。

### Snapshot（快照）系统与状态观察

- Compose 的状态可观察性由 Snapshot（快照）系统支撑：它会追踪 Composable “读了哪些 State”。
- 当这些 State 被写入且值发生变化时，Compose 会让依赖它们的那部分 UI 失效并触发重组，而不是整棵树刷新。
- 因此，会影响 UI 的数据应放进 `State` 并通过委托 `by` / `.value` 读写，才能建立正确依赖关系。
- 需要把 Compose State 的变化接入 Flow 时，用 `snapshotFlow { ... }`（后文有示例）。

```kotlin
// 1. 基本使用与委托
var text by remember { mutableStateOf("") }

// 2. 跨配置更改保持
var screenText by rememberSaveable { mutableStateOf("Hello") }

// 3. 复杂对象状态（需确保数据变化可观察）
data class User(val name: String, val age: Int)
var user by remember { mutableStateOf(User("Alice", 25)) }

// 4. 列表/Map 状态
val items = remember { mutableStateListOf<String>() }
val settings = remember { mutableStateMapOf<String, String>() }

// 5. 自定义 Saver (处理非默认可序列化类型)
// 作用：当需要将无法直接通过 Bundle 序列化的复杂数据类型 (如自定义类)
// 存储到 rememberSaveable 中时，需提供自定义的 Saver 接口。
val userSaver = run {
    val idKey = "id"
    val nameKey = "name"
    
    mapSaver<User>(
        save = { mapOf(idKey to it.id, nameKey to it.name) },
        restore = { User(it[idKey] as Int, it[nameKey] as String) }
    )
}
var user by rememberSaveable(stateSaver = userSaver) {
    mutableStateOf(User(1, "Alice"))
}
```

### 单向数据流 (OWDF)和状态提升(State Hoisting)

- **状态提升原则:** 将状态移动到可组合函数的调用者，使组件变为**无状态（Stateless）**，从而便于测试和复用。

Compose 鼓励采用 OWDF 模型，特别是在结合 ViewModel 时：

- **状态 (State):** 从上向下流动（**ViewModel** / 父级 -> **Composable** / 子级）。
- **事件 (Events):** 从下向上流动（**Composable** / 子级 -> **ViewModel** / 父级）。

```kotlin
// 遵循 OWDF 的组件设计
@Composable
fun StatelessCounter(
    count: Int, // 状态向下流动 (State)
    onIncrement: () -> Unit, // 事件向上流动 (Event)
    modifier: Modifier = Modifier
) {
    // ... UI 描述
    Button(onClick = onIncrement) { Text("Increment") }
}

@Composable
fun StatefulParent() {
    // 状态提升到这里管理
    var count by remember { mutableStateOf(0) }
    
    StatelessCounter(
        count = count,
        onIncrement = { count++ },
    )
}
```

### ViewModel 中的状态管理

- **用途:** 存储屏幕级/业务逻辑状态，使其在配置更改后幸存。它是实现复杂状态的 **单一事实来源 (SSOT)** 的理想场所。
- **状态收集与观察:** 为了让 Compose 响应 `ViewModel` 中的异步数据流，必须将其转换为 Compose `State` (`collectAsState()` 或 `observeAsState()`)。

```kotlin
class MyViewModel : ViewModel() {
    private val _uiState = MutableStateFlow(0)
    val uiState: StateFlow<Int> = _uiState.asStateFlow() // 暴露为 StateFlow

    fun incrementCount() {
        viewModelScope.launch { 
            _uiState.update { it + 1 } 
        }
    }
}

@Composable
fun CounterScreen(viewModel: MyViewModel = viewModel()) {
    // 收集 StateFlow 数据，转换为 Compose State
    val count by viewModel.uiState.collectAsState()

    Column {
        Text("当前计数: $count")
        Button(onClick = viewModel::incrementCount) { // 事件向上
            Text("增加")
        }
    }
}
```

### 依赖注入：Hilt 集成

- **Hilt 与 ViewModel 的结合:** Hilt 提供了 `hiltViewModel()` Composable 函数，用于获取由 Hilt 注入的 `ViewModel` 实例。

```kotlin
// 1. ViewModel 的 Hilt 注解
@HiltViewModel
class MyHiltViewModel @Inject constructor(
    private val repository: DataRepository
) : ViewModel() { /* ... */ }

// 2. 在 Composable 中使用 Hilt 提供的 ViewModel
@Composable
fun HiltScreen(viewModel: MyHiltViewModel = hiltViewModel()) {
    // ... UI 逻辑
}
```

### 派生状态 (`derivedStateOf`)

- **作用:** 仅当计算依赖的 Compose 状态实际发生变化时，才重新计算结果。用于避免不必要的重组或昂贵的计算。

```kotlin
@Composable
fun TodoList(items: List<TodoItem>) {
    // 只有当 items 列表的内容发生变化时，completedCount 才会重新计算
    val completedCount by remember(items) {
        derivedStateOf {
            items.count { it.isCompleted }
        }
    }
    Text("Completed: $completedCount")
}
```

### 稳定类型 (`Stable Types`)

- **作用:** 告诉 Compose 编译器，如果对象的属性没有变化，那么这个对象就是稳定的。
- **好处:** Compose 可以更自信地跳过重组，提高效率。`data class` 默认是稳定的，除非属性是不可观察的类型。

```kotlin
// 推荐使用 @Stable 注解或确保属性是稳定的
@Stable
data class UserState(val name: String, val age: Int)
```

### 列表性能优化 (`key` 与 `contentType`)

- **`key`:** 为 `LazyColumn/Row` 中的每个项目提供唯一标识，确保在列表数据变化时，Compose 能正确识别和重用 Composable 实例。

```kotlin
LazyColumn {
    items(
        items = users,
        key = { user -> user.id }  // 提供唯一 key
    ) { user ->
        UserItem(user = user)
    }
}
```

### 状态驱动的外部操作 (Side Effects)

> **[提示]** 副作用是指在 Composable 函数作用域之外执行的操作（如 I/O、启动协程、修改共享对象）。本节概述它们在状态管理中的作用，**详细用法请参考专门的副作用章节**。

| API | 作用 | 触发时机 | 最佳用途 |
| :--- | :--- | :--- | :--- |
| **`LaunchedEffect`** | 启动协程，用于执行异步任务。 | **Key** 变化时，取消并重启协程。 | 状态变化后执行网络加载、计时器。 |
| **`DisposableEffect`** | 执行需要清理的副作用。 | **Key** 变化或 Composable 退出时。 | 注册/解注册监听器、生命周期观察者。 |
| **`SideEffect`** | 同步 Composable 状态到非 Compose 对象。 | 每次重组成功后。 | 分析/日志记录。 |
| **`snapshotFlow`** | 将 Compose State 转换为 Flow。 | 状态值变化时发射新值。 | 观察 Compose 状态并在 Flow 中进行处理。 |

```kotlin
// LaunchedEffect 示例：当状态 key 变化时执行异步操作
@Composable
fun DataLoader(userId: String) {
    LaunchedEffect(userId) { // 当 userId 变化时重启加载
        val data = repository.loadData(userId)
        // ... 更新状态
    }
}
```

## 动画 (Animations)

### 值动画 (Single-Value Animation)

- **`animate*AsState`:** 最简单的单值动画。适用于一个值在两个目标状态之间平滑过渡（如颜色、尺寸、浮点数）。

```kotlin
@Composable
fun MultipleAnimations() {
    var isExpanded by remember { mutableStateOf(false) }
    
    val size by animateDpAsState(targetValue = if (isExpanded) 200.dp else 100.dp)
    val alpha by animateFloatAsState(targetValue = if (isExpanded) 1f else 0.5f)
    val color by animateColorAsState(targetValue = if (isExpanded) Color.Red else Color.Blue)
    
    Box(
        modifier = Modifier
            .size(size) // 使用尺寸动画
            .graphicsLayer(alpha = alpha) // 使用透明度动画
            .background(color)
            .clickable { isExpanded = !isExpanded }
    )
}
```

### 多值/过渡动画 (Transition)

- **`updateTransition`:** 适用于同时协调多个属性从一个状态集转换到另一个状态集，确保它们同步。

```kotlin
enum class BoxState { Collapsed, Expanded }

@Composable
fun TransitionAnimation() {
    var currentState by remember { mutableStateOf(BoxState.Collapsed) }
    
    // 创建 Transition 实例，基于 currentState 驱动
    val transition = updateTransition(currentState, label = "boxTransition")
    
    // 动画属性 1: 颜色
    val color by transition.animateColor(label = "color") { state ->
        when (state) {
            BoxState.Collapsed -> Color.Gray
            BoxState.Expanded -> Color.Green
        }
    }
    
    // 动画属性 2: 大小
    val size by transition.animateDp(label = "size") { state ->
        when (state) {
            BoxState.Collapsed -> 50.dp
            BoxState.Expanded -> 150.dp
        }
    }
    
    Box(
        modifier = Modifier
            .size(size) // 动画属性 2
            .background(color) // 动画属性 1
            .clickable {
                currentState = if (currentState == BoxState.Expanded) {
                    BoxState.Collapsed
                } else {
                    BoxState.Expanded
                }
            }
    )
}
```

### 内容/可见性切换动画 (Content/Visibility Switching)

- **`AnimatedVisibility`:** 为 Composable 的出现/消失添加动画效果。
- **`AnimatedContent`:** 处理布局或状态的复杂切换，为整个内容块添加动画效果。
- **`Crossfade`:** 在两个内容之间进行简单的淡入淡出切换，通常用于状态值驱动的整体 UI 切换。
- **`animateContentSize` (Modifier):** 列表动画的核心。当 Composable 的尺寸（如列表项容器）因内容增减而改变时，为尺寸变化本身提供平滑过渡。

```kotlin
@Composable
fun ContentSwitchingExample() {
    var isVisible by remember { mutableStateOf(true) }
    var status by remember { mutableStateOf("Loading") }

    Column(Modifier.padding(16.dp)) {
        Button(onClick = { isVisible = !isVisible }) {
            Text("切换可见性/列表状态")
        }

        Spacer(Modifier.height(8.dp))

        // 1. AnimatedVisibility: 整个内容块的出现/消失动画
        AnimatedVisibility(
            visible = isVisible,
            enter = fadeIn() + expandVertically(),
            exit = fadeOut() + shrinkVertically()
        ) {
            // 2. animateContentSize: 当内部内容（如列表项）增减时，容器大小平滑变化
            Column(
                modifier = Modifier
                    .background(Color.LightGray)
                    .animateContentSize() 
            ) {
                // 模拟列表项显示
                (1..3).forEach {
                    Text(text = "List Item $it", modifier = Modifier.padding(vertical = 4.dp))
                }
            }
        }
        
        Spacer(Modifier.height(8.dp))

        // 3. AnimatedContent: 内容切换动画 (针对状态值的复杂内容替换)
        Button(onClick = { 
            status = if (status == "Loading") "Done" else "Loading"
        }) {
            Text("切换状态内容")
        }
        
        AnimatedContent(targetState = status, label = "statusSwitch") { targetStatus ->
            when (targetStatus) {
                "Loading" -> CircularProgressIndicator(Modifier.size(32.dp))
                "Done" -> Text("任务已完成！", style = MaterialTheme.typography.titleLarge)
            }
        }
    }
}
```

### 无限动画 (`InfiniteTransition`)

- **`rememberInfiniteTransition`:** 用于不停止的、循环往复的动画效果，例如加载指示器。

```kotlin
@Composable
fun InfiniteLoadingAnimation() {
    val infiniteTransition = rememberInfiniteTransition(label = "infiniteColor")
    
    val color by infiniteTransition.animateColor(
        initialValue = Color.Red,
        targetValue = Color.Blue,
        animationSpec = infiniteRepeatable(
            animation = tween(1000), // 每 1000ms 变化一次
            repeatMode = RepeatMode.Reverse // 颜色在 Blue 和 Red 之间来回反转
        ),
        label = "color"
    )
    
    Box(modifier = Modifier.size(50.dp).background(color))
}
```

### 自定义动画规格 (`AnimationSpec`)

- 定义动画的驱动规则、持续时间和插值方式。

```kotlin
val animatedValue by animateDpAsState(
    targetValue = targetSize,
    animationSpec = spring( // 弹簧动画 (Spring)
        dampingRatio = Spring.DampingRatioMediumBouncy,
        stiffness = Spring.StiffnessMedium
    )
    // 或：tween(durationMillis = 300, easing = FastOutSlowInEasing) // 缓动动画 (Tween)
    // 或：keyframes { /* ... */ } // 关键帧动画 (Keyframes)
)
```

### 协程控制动画 (`Animatable`)

- **`Animatable`:** 把动画当作“状态值随时间变化”的过程，在 `LaunchedEffect` 等协程中调用 `animateTo()` 精确控制开始/停止、串联与取消，适合更复杂的动画流程。

```kotlin
@Composable
fun CustomAnimatable() {
    // 创建 Animatable 实例，用于驱动浮点值
    val offset = remember { Animatable(0f) }
    
    LaunchedEffect(Unit) {
        // 协程中控制动画：值从 0f 动画到 200f
        offset.animateTo(
            targetValue = 200f,
            animationSpec = tween(durationMillis = 500)
        )
        // 结束后再动画回 0f
        offset.animateTo(
            targetValue = 0f,
            animationSpec = spring(stiffness = Spring.StiffnessLow)
        )
    }
    
    Box(
        modifier = Modifier
            .size(50.dp)
            .offset { IntOffset(offset.value.roundToInt(), 0) }
            .background(Color.Yellow)
    )
}
```

---

## 手势处理 (Gesture Handling)

### 基础交互手势

| Modifier | 作用 | 描述 |
| :--- | :--- | :--- |
| **`clickable { ... }`** | 处理单击 (`onClick`)。 | 默认包含 Ripple 效果和无障碍支持。 |
| **`combinedClickable { ... }`** | 处理多种点击事件。 | 可同时监听 `onClick`, `onLongClick`, `onDoubleClick`。 |
| **`draggable { ... }`** | 处理单轴拖动。 | 用于水平或垂直方向的滑动/拖拽。 |
| **`swipeable { ... }`** | 高级滑动组件。 | 用于实现类似 `SwipeToDismiss` 的基于锚点（Anchors）的滑动效果。 |

```kotlin
// 定义滑动锚点
private enum class DismissState { Dismissed, Default }
private val swipeAnchors = mapOf(
    -300f to DismissState.Dismissed, // 滑到左侧 300dp 为 Dismissed 状态
    0f to DismissState.Default     // 原始位置为 Default 状态
)

@OptIn(ExperimentalMaterialApi::class)
@Composable
fun BasicGestureExample() {
    val context = LocalContext.current
    var offsetX by remember { mutableStateOf(0f) }

    Column(Modifier.fillMaxWidth().padding(16.dp)) {
        // 1. combinedClickable 示例：处理多种点击 (同时包含 onClick 和 onLongClick)
        Text(
            "多重点击测试 (含 clickable 基础功能)",
            modifier = Modifier
                .fillMaxWidth()
                .background(Color.Cyan)
                .combinedClickable(
                    onClick = { Toast.makeText(context, "单击 (Clickable)", Toast.LENGTH_SHORT).show() },
                    onDoubleClick = { Toast.makeText(context, "双击", Toast.LENGTH_SHORT).show() },
                    onLongClick = { Toast.makeText(context, "长按", Toast.LENGTH_SHORT).show() }
                )
                .padding(16.dp)
        )

        Spacer(Modifier.height(16.dp))

        // 2. draggable 示例：水平拖动
        Text(
            "拖动我 (Draggable)",
            modifier = Modifier
                .offset { IntOffset(offsetX.roundToInt(), 0) }
                .background(Color.Magenta)
                .draggable(
                    orientation = Orientation.Horizontal,
                    state = rememberDraggableState { delta ->
                        offsetX += delta // 更新水平偏移量
                    }
                )
                .padding(16.dp)
        )

        Spacer(Modifier.height(16.dp))

        // 3. swipeable 示例：带锚点的滑动（类似 SwipeToDismiss）
        val swipeableState = rememberSwipeableState(initialValue = DismissState.Default)
        
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(50.dp)
                .background(Color.LightGray)
                .swipeable(
                    state = swipeableState,
                    anchors = swipeAnchors.entries.associate { it.value to it.key },
                    orientation = Orientation.Horizontal,
                    thresholds = { _, _ -> FractionalThreshold(0.5f) }
                )
        ) {
            Box(
                Modifier
                    .fillMaxHeight()
                    .offset { IntOffset(swipeableState.offset.value.roundToInt(), 0) }
                    .background(Color.Yellow)
                    .fillMaxWidth(0.9f) // 实际可滑动的内容
            ) {
                Text(
                    "滑动删除 (Swipeable)", 
                    modifier = Modifier.align(Alignment.Center)
                )
            }
        }
        
        if (swipeableState.currentValue == DismissState.Dismissed) {
             Text("项目已隐藏！", color = Color.Red)
        }
    }
}
```

### `pointerInput`

`pointerInput` Modifier 是所有手势处理的基础，通常配合 `detect*Gestures` 函数使用。

```kotlin
@Composable
fun PointerInputGestures() {
    // 用于记录图形的平移和缩放状态
    var offset by remember { mutableStateOf(Offset(0f, 0f)) }
    var scale by remember { mutableStateOf(1f) }
    
    Box(
        modifier = Modifier
            .fillMaxSize()
            .pointerInput(Unit) {
                // 1. 多点触控手势：缩放、平移
                detectTransformGestures { _, pan, zoom, _ ->
                    offset = offset.plus(pan) // 更新平移
                    scale = (scale * zoom).coerceIn(0.5f, 2f) // 更新缩放，并限制范围
                }
            }
            .pointerInput(Unit) { 
                // 2. 基础点击手势：单击、长按
                detectTapGestures(
                    onTap = { println("图形被单击") }, 
                    onLongPress = { println("图形被长按") }
                )
            }
    ) {
        // 使用 graphicsLayer 应用手势带来的平移和缩放效果
        Box(
            Modifier
                .size(100.dp)
                .graphicsLayer(
                    translationX = offset.x,
                    translationY = offset.y,
                    scaleX = scale,
                    scaleY = scale
                )
                .background(Color.Magenta)
                .align(Alignment.Center) // 居中显示
        )
    }
}
```

## 副作用 API (Side Effects)

在 Composable 函数作用域之外执行的操作，这些操作会影响应用的其他部分或外部。
**示例:** 启动网络请求、修改共享的非 Compose 状态对象、注册监听器、日志记录等。

### 为什么需要专门的 API？

Composable 函数应是**纯净 (Pure)** 的。Compose 提供的副作用 API 用于安全地管理这些操作的生命周期，确保它们在 Composable 退出 Composition 时能够被正确地取消或清理。

### 协程与异步管理

| API | 作用 | Key 依赖与生命周期 | 最佳用途 |
| :--- | :--- | :--- | :--- |
| **`LaunchedEffect`** | **在 Composition 内部启动协程。** | Key 变化时，取消并重启协程。退出 Composition 时自动取消。 | 异步数据加载、基于状态的导航跳转。 |
| **`DisposableEffect`** | 执行需要**清理**的副作用。 | Key 变化时，先清理旧副作用，再执行新副作用。 | 注册/解注册监听器、生命周期观察者。 |
| **`rememberCoroutineScope`** | **获取 Composition 范围的 `CoroutineScope`。** | 返回稳定 Scope。 | 在 **事件回调**（如 `onClick`）中启动协程。 |
| **`produceState`** | **将异步源（如 Flow/Suspend Function）转化为 `State`。** | Key 变化时，重新启动生产者协程。 | 从 Flow 或 Repository 加载数据到 Composable State。 |

```kotlin
// produceState 示例：将 Flow 转化为 Compose State
@Composable
fun FlowCollector(dataFlow: Flow<String>) {
    // 自动收集 flow，并将最新值作为 State<String> 返回
    val dataState by produceState(initialValue = "Loading...", dataFlow) {
        // 生产者协程：当 dataFlow 变化时，协程重新启动
        dataFlow.collect { value = it }
    }
    
    // 或者直接使用挂起函数
    val user by produceState<User?>(null, userId) {
        // Key 为 userId，当 userId 变化时，重新调用挂起函数
        value = userRepository.loadUser(userId)
    }

    Text("Current Data: $dataState")
}

// rememberCoroutineScope 示例
@Composable
fun SaveButton(viewModel: MyViewModel) {
    val scope = rememberCoroutineScope()
    Button(onClick = {
        // 在非 @Composable 上下文中，使用 scope 确保协程生命周期安全
        scope.launch {
            viewModel.saveData()
        }
    }) {
        Text("保存")
    }
}
```

### 状态同步与转换

| API | 作用 | 执行时机 | 机制 |
| :--- | :--- | :--- | :--- |
| **`SideEffect`** | **同步 Compose 状态到非 Compose 对象。** | 每次成功重组之后。 | 保证外部系统（如 Analytics）使用的值是 Compose 最新的。 |
| **`snapshotFlow`** | **将 Compose State 转化为 Kotlin Flow。** | 状态值变化时发射新值。 | 用于对 Compose 状态进行 Flow 操作（如 `debounce`, `filter`）。 |
| **`rememberUpdatedState`** | **捕获最新值而不引起副作用重启。** | 封装的值变化时不作为 Key 触发 `LaunchedEffect` 重启。 | 引用最新的回调或值，同时保持 `LaunchedEffect` 的生命周期稳定。 |

```kotlin
// snapshotFlow 示例：对 Compose 状态进行防抖处理
@Composable
fun SearchInput(queryState: State<String>) {
    // 使用 rememberUpdatedState 捕获最新的 queryState
    val latestQuery = rememberUpdatedState(queryState.value)

    // LaunchedEffect(Unit) 确保只启动一次，不因 query 变化而重启
    LaunchedEffect(Unit) {
        snapshotFlow { latestQuery.value } // 将最新的 Compose 状态转换为 Flow
            .debounce(300) // 过滤掉快速输入
            .filter { it.length > 2 }
            .collect { debouncedQuery ->
                println("Searching for: $debouncedQuery")
            }
    }
    // ... UI 描述
}

// SideEffect 示例
@Composable
fun AnalyticsReporter(screenName: String) {
    SideEffect {
        // 每次 screenName 变化且 Composable 成功重组后，都会更新外部服务
        analyticsService.setScreen(screenName)
    }
}
```

## ConstraintLayout

通过定义组件之间的约束关系来定位和调整组件的大小，从而避免嵌套过多的 `Column` 和 `Row`，提高布局性能。

- **`ConstraintLayout`:** 容器 Composable。
- **`constrainAs(ref) { ... }`:** Modifier 扩展函数，用于定义组件的约束规则。
- **`createRefs()`:** 创建引用（Ref），用于标识组件。
- **`createGuidelineFrom*()`:** 创建辅助线，用于定位。
- **`createBarrier()`:** **核心辅助工具**。创建屏障，用于约束到一组组件中最远或最近的边缘。

### ConstraintLayout 示例 (包含 Barrier, Bias, Dimension)

```kotlin
@Composable
fun ConstraintLayoutComplexExample() {
    ConstraintLayout(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        // 1. 创建 Refs
        val (titleRef, buttonRef, imageRef, longTextRef) = createRefs()
        
        // 2. 创建 Barrier (屏障)
        // 创建一个屏障，位于 titleRef 和 longTextRef 的最右侧 (End)
        val endBarrier = createBarrier(titleRef, longTextRef, direction = BarrierDirection.End)

        // 标题 (Title)：Edge 约束
        Text("Compose 标题", Modifier.constrainAs(titleRef) {
            top.linkTo(parent.top, margin = 8.dp)
            start.linkTo(parent.start) 
        })
        
        // 长文本 (LongText)：Edge 约束
        Text("这是可能很长的一段描述文本...", 
            Modifier
                .constrainAs(longTextRef) {
                    top.linkTo(titleRef.bottom, margin = 4.dp)
                    start.linkTo(parent.start) 
                    end.linkTo(imageRef.start, margin = 8.dp) // 避免与图片重叠
                    // 4. Dimension 约束: 宽度填充到约束
                    width = Dimension.fillToConstraints
                }
        )
        
        // 图片 (Image)：Edge 约束 + Bias 约束
        Image(
            painter = painterResource(id = R.drawable.my_image),
            contentDescription = "Image",
            modifier = Modifier
                .size(60.dp)
                .constrainAs(imageRef) {
                    top.linkTo(parent.top)
                    bottom.linkTo(parent.bottom) // 垂直居中
                    end.linkTo(parent.end)
                    // 5. Bias 约束: 垂直方向偏上 20%
                    verticalBias = 0.2f
                }
        )

        // 按钮 (Button)：使用 Barrier 约束
        Button(
            onClick = { /* ... */ },
            modifier = Modifier.constrainAs(buttonRef) {
                // 3. Barrier 约束：按钮的开始边缘约束到屏障 (title/longText 的最右侧)
                start.linkTo(endBarrier, margin = 16.dp) 
                top.linkTo(longTextRef.top) // 与长文本顶部对齐
            }
        ) {
            Text("操作按钮")
        }
    }
}
```

## Canvas

提供一个可绘制区域，用于执行底层图形绘制操作，如绘制自定义形状、路径、文本和图片，实现高性能的自定义 UI。

- **`Canvas`:** 最简单的绘图 Composable，提供整个绘制区域。
- **`drawBehind` / `drawWithContent` / `drawWithCache` (Modifier):** 允许在任何 Composable 的背景、前景或内容周围进行绘制。
- **`DrawScope`:** 在 `Canvas` 或 `draw*` Modifier 内部提供的作用域，包含所有绘图方法（如 `drawCircle`, `drawLine`, `drawPath`）。

### Canvas 示例 (绘制自定义图形)

```kotlin
@Composable
fun CustomShapeCanvas() {
    Canvas(
        modifier = Modifier
            .size(200.dp)
            .background(Color.White)
    ) {
        // 绘制一个圆角矩形
        drawRoundRect(
            color = Color.Blue,
            topLeft = Offset(50f, 50f),
            size = Size(100f, 100f),
            cornerRadius = CornerRadius(20f, 20f)
        )

        // 绘制一条自定义路径 (Path) - 箭头形状
        val path = Path().apply {
            moveTo(center.x, center.y)
            lineTo(center.x + 50f, center.y + 50f)
            lineTo(center.x + 50f, center.y - 50f)
            close()
        }
        drawPath(
            path = path,
            color = Color.Red,
            style = Fill // 填充路径
        )

        // 在任何 Composable 背景上绘制
        Text("文本", modifier = Modifier.drawBehind {
             drawCircle(Color.Yellow, radius = 5.dp.toPx()) // 在文本左下角绘制小圆点
        })
    }
}
```

## ComposeView：在 View 中使用 Compose

`ComposeView` 是一个标准的 Android `View`，可放置在任何 XML 布局中。它充当 Compose 系统的宿主。

### `ViewCompositionStrategy`

此策略决定了 Compose 组合何时被清理（释放内存）。推荐使用 `DisposeOnViewTreeLifecycleDestroyed`。

### 使用方法

- **XML 布局中声明 `ComposeView`:**

```xml
<androidx.constraintlayout.widget.ConstraintLayout ...>
    <androidx.compose.ui.platform.ComposeView
        android:id="@+id/compose_view"
        android:layout_width="match_parent"
        android:layout_height="match_parent"/>
</androidx.constraintlayout.widget.ConstraintLayout>
```

- **Activity/Fragment 中设置内容:**

```kotlin
class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        findViewById<ComposeView>(R.id.compose_view).apply {
            // 设置清理策略
            setViewCompositionStrategy(
                ViewCompositionStrategy.DisposeOnViewTreeLifecycleDestroyed
            )
            //// 设置 Compose 内容
            setContent {
                MaterialTheme { // 必须提供主题
                    ComposeGreeting(name = "From XML")
                }
            }
        }
    }
}
```

## AndroidView：在 Compose 中使用 View

- **`factory`:** 必需。用于创建并返回要嵌入的 View 实例。**只在第一次合成时调用。**
- **`update`:** 可选。每次 `AndroidView` 重组时调用，用于更新 View 的属性以匹配最新的 Compose 状态。

### `AndroidView` 示例 (集成 WebView)

```kotlin
@Composable
fun WebViewInCompose(url: String) {
    // 捕获 url 的最新状态，供 update 块使用
    val currentUrl = rememberUpdatedState(url)

    AndroidView(
        modifier = Modifier.fillMaxSize(),
        factory = { context ->
            // 1. 创建 View 实例 (只执行一次)
            WebView(context).apply {
                webViewClient = WebViewClient()
                settings.javaScriptEnabled = true
            }
        },
        update = { webView ->
            // 2. 根据 Compose 状态更新 View (每次重组时可能执行)
            webView.loadUrl(currentUrl.value)
        }
    )
}
```

## 混合使用 View 和 Compose 时的状态同步与互操作

### Compose 状态 -> View 状态 (单向同步)

将 Compose 状态作为参数传递给 `AndroidView`，并在 `update` 块中调用 View 的 setter 方法。

```kotlin
@Composable
fun ComposeStateToView(message: String) {
    AndroidView(
        factory = { context ->
            TextView(context) // 创建 View
        },
        update = { textView ->
            // Compose 状态 (message) 变化时，update() 会重新调用
            textView.text = message
        }
    )
}
```

### View 状态 -> Compose 状态 (单向同步)

把 View 的变化通过监听回传到 Compose 的 `State`。监听器用 `DisposableEffect` 管理生命周期，避免重复注册与泄漏。

```kotlin
@Composable
fun ViewStateToCompose() {
    // 1) Compose State 接收 View 的变化
    var textState by remember { mutableStateOf("Initial Text") }
    // 2) 持有 View 引用，供 DisposableEffect 注册/注销监听
    var editText: EditText? by remember { mutableStateOf(null) }
    // 3) 避免捕获旧 lambda：让监听始终调用最新的回调
    val onTextChanged by rememberUpdatedState<(String) -> Unit> { textState = it }

    AndroidView(
        modifier = Modifier.fillMaxWidth(),
        // 4) 只在首次合成时创建 View
        factory = { context ->
            EditText(context).also { editText = it }
        }
    )

    DisposableEffect(editText) {
        val view = editText ?: return@DisposableEffect onDispose {}
        // 5) 注册监听：View -> Compose
        val watcher = object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                onTextChanged(s?.toString().orEmpty())
            }
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) = Unit
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) = Unit
        }
        view.addTextChangedListener(watcher)
        // 6) 注销监听，避免泄漏/重复注册
        onDispose { view.removeTextChangedListener(watcher) }
    }

    Text("Captured Text: $textState")
}
```

### Compose ↔ View 双向同步

```kotlin
@Composable
fun EditTextInCompose() {

    // 1) Compose State 作为单一数据源
    var textState by remember { mutableStateOf("Initial Text") }
    // 2) 持有 View 引用，供 DisposableEffect 注册/注销监听
    var editText: EditText? by remember { mutableStateOf(null) }
    // 3) 避免捕获旧 lambda
    val onTextChanged by rememberUpdatedState<(String) -> Unit> { textState = it }

    AndroidView(
        modifier = Modifier.fillMaxWidth(),
        // 4) 只创建一次 View
        factory = { context ->
            EditText(context).also { editText = it }
        },
        update = { editText ->
            // 5) Compose -> View：先比较，避免 setText 触发监听导致循环
            if (editText.text.toString() != textState) {
                editText.setText(textState)
            }
        }
    )

    DisposableEffect(editText) {
        val view = editText ?: return@DisposableEffect onDispose {}
        // 6) View -> Compose
        val watcher = object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                onTextChanged(s?.toString().orEmpty())
            }
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) = Unit
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) = Unit
        }
        view.addTextChangedListener(watcher)
        onDispose { view.removeTextChangedListener(watcher) }
    }
}

```

### 互操作最佳实践

- **避免嵌套过多:** 不要在一个 `AndroidView` 中嵌入另一个 `ComposeView`，或反之，避免性能损失。
- **主题同步:** 确保通过 `ComposeView.setContent` 渲染 Compose 时，传入正确的 `MaterialTheme` 或自定义主题，以匹配原生 View 的主题风格。
- **生命周期:** `AndroidView` 内部 View 的生命周期与宿主 Composable 的生命周期保持一致，但手动创建的资源（如监听器、Manager）仍需在 `DisposableEffect` 中管理。
- **性能考量:** `AndroidView` 的 `update` 块在每次重组时都可能执行，应避免在其中执行复杂或耗时的操作。
- **避免互相打架:** 尽量让 Compose 作为单一数据源；双向同步时，更新 View 前先比较值，避免 `setText` 触发监听造成循环。

## 导航 (Navigation)

- **`NavController`:** 负责管理 Composable 堆栈、导航操作和回退。
- **`NavHost`:** 承载 Composable 导航图的容器。**`startDestination`** 参数用于指定导航图的默认主页。

- **进入:** `navController.navigate("route_name")`
- **回退:** `navController.popBackStack()`

### 基础使用示例

```kotlin
// 定义路由常量
object Destinations {
    const val HOME_ROUTE = "home"
    const val DETAIL_ROUTE = "detail"
}

@Composable
fun NavHostExample() {
    // 1. 创建 NavController
    val navController = rememberNavController()
    
    // 2. NavHost 定义导航图
    NavHost(
        navController = navController,
        startDestination = Destinations.HOME_ROUTE // 设置默认主页
    ) {
        // 目的地 A: Home 屏幕
        composable(Destinations.HOME_ROUTE) {
            HomeScreen(
                onNavigateToDetail = { 
                    // 导航到 Detail 屏幕
                    navController.navigate(Destinations.DETAIL_ROUTE) 
                }
            )
        }
        
        // 目的地 B: Detail 屏幕
        composable(Destinations.DETAIL_ROUTE) {
            DetailScreen(
                onBack = { 
                    // 返回到上一个屏幕
                    navController.popBackStack() 
                }
            )
        }
    }
}

// HomeScreen
@Composable
fun HomeScreen(onNavigateToDetail: () -> Unit) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text("Home Screen")
        Button(onClick = onNavigateToDetail) {
            Text("Go to Detail")
        }
    }
}

// DetailScreen
@Composable
fun DetailScreen(onBack: () -> Unit) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text("Detail Screen")
        Button(onClick = onBack) {
            Text("Go Back")
        }
    }
}
```

### 必传参数 (Required Arguments)

在路由定义中使用花括号 `{}` 定义参数名。

```kotlin
const val USER_ID_KEY = "userId"

NavHost(navController, startDestination = "list") {
    // 路由结构: "detail/{userId}"
    composable(
        route = "detail/{$USER_ID_KEY}",
        arguments = listOf(navArgument(USER_ID_KEY) { type = NavType.IntType })
    ) { backStackEntry ->
        // 接收参数
        val userId = backStackEntry.arguments?.getInt(USER_ID_KEY) ?: 0
        DetailScreen(userId)
    }
}
// 导航调用: 必须提供参数
navController.navigate("detail/123")
```

### 可选参数 (Optional Arguments)

在路由中使用问号 `?` 定义可选参数，必须在 `arguments` 中设置 `defaultValue` 或 `nullable = true`。

```kotlin
const val MESSAGE_KEY = "message"

composable(
    // 路由结构: "profile?message={message}"
    route = "profile?{$MESSAGE_KEY}",
    arguments = listOf(navArgument(MESSAGE_KEY) {
        type = NavType.StringType
        defaultValue = null // 设置为可选
        nullable = true
    })
) { backStackEntry ->
    val message = backStackEntry.arguments?.getString(MESSAGE_KEY)
    ProfileScreen(message)
}
// 导航调用 (可选参数可以不传)
navController.navigate("profile?message=welcome") // 传参
navController.navigate("profile") // 不传参
```

### 嵌套导航图 (Nested Navigation Graphs)

将大型应用的导航流程划分为独立的、可重用的模块（子图），每个子图有自己的起始目的地。

- **`navigation(startDestination = ..., route = ...)`:** 用于定义一个嵌套的导航图。

```kotlin
fun NavGraphBuilder.authGraph(navController: NavController) {
    // 定义认证模块的子图
    navigation(startDestination = "login", route = "auth_graph") {
        composable("login") { LoginScreen(navController) }
        composable("register") { RegisterScreen(navController) }
    }
}

@Composable
fun MainNavHost(navController: NavController) {
    NavHost(navController, startDestination = "main_graph") {
        // 主应用导航图
        composable("main_graph") { MainScreen(navController) }
        authGraph(navController) // 挂载嵌套导航图
    }
}
// 导航到子图的起始点
navController.navigate("auth_graph")
```

### 导航选项 (NavOptions)

控制导航行为，如弹出堆栈、单例模式或启动模式。主要通过 `popUpTo` 控制堆栈清理。

```kotlin
// 场景：从登录页跳转到主页，并清空所有之前的堆栈 (实现单例主页)
navController.navigate("home") {
    // popUpTo("login"): 弹出到 "login" 路由
    popUpTo("login") {
        // inclusive = true: 包含 "login" 路由本身也弹出
        inclusive = true
    }
    // launchSingleTop = true: 如果目标已经在栈顶，不重复创建实例
    launchSingleTop = true
}
```

### 底部导航栏集成 (Bottom Navigation)

使用 `Scaffold` 配合 `currentBackStackEntryAsState()` 监听当前路由，高亮选中的 Tab。

```kotlin
@Composable
fun MainScreen(navController: NavHostController) {
    // 监听当前路由，以确定哪个 Tab 处于选中状态
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route

    Scaffold(
        bottomBar = {
            NavigationBar {
                listOf("home", "profile").forEach { route ->
                    NavigationBarItem(
                        selected = currentRoute == route,
                        onClick = {
                            if (currentRoute != route) {
                                navController.navigate(route) {
                                    // 确保 Home 总是单例启动
                                    popUpTo(navController.graph.findStartDestination().id) { saveState = true }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            }
                        },
                        icon = { /* Icon */ },
                        label = { Text(route) }
                    )
                }
            }
        }
    ) { padding ->
        NavHost(navController, startDestination = "home", Modifier.padding(padding)) {
            composable("home") { /* ... */ }
            composable("profile") { /* ... */ }
        }
    }
}
```

### Deep Links (深层链接)

允许外部链接（如网页 URL 或通知）直接导航到应用内部的特定目的地。

- **`deepLinks`:** 在 `composable` 函数中定义 Deep Link 模板。

```kotlin
composable(
    route = "item/{itemId}",
    arguments = listOf(navArgument("itemId") { type = NavType.LongType }),
    deepLinks = listOf(
        navDeepLink {
            // 定义 scheme/host，用于匹配外部 URL
            uriPattern = "app://example.com/item/{itemId}"
        }
    )
) { backStackEntry ->
    val itemId = backStackEntry.arguments?.getLong("itemId") ?: 0L
    ItemDetailScreen(itemId)
}
```

### 处理返回按钮 (`BackHandler`)

覆盖 Android 设备的系统返回按钮行为，常用于确认退出、关闭弹窗或取消操作。

```kotlin
@Composable
fun CustomBackHandlerScreen() {
    var showConfirmDialog by remember { mutableStateOf(false) }

    // 当且仅当 enable = true 时，接管返回按钮
    BackHandler(enabled = !showConfirmDialog) {
        // 如果不在对话框中，拦截返回，显示确认对话框
        showConfirmDialog = true
    }

    if (showConfirmDialog) {
        AlertDialog(
            onDismissRequest = { showConfirmDialog = false },
            confirmButton = { 
                Button(onClick = { /* 执行退出操作 */ }) { Text("退出") }
            },
            dismissButton = { 
                Button(onClick = { showConfirmDialog = false }) { Text("取消") }
            },
            title = { Text("确认退出？") }
        )
    }
}
```

### 实践：将 NavController 传递给事件

**原则:** 避免将 `NavController` 直接作为参数传递给所有的 Composable。只在需要进行导航操作的事件回调中引用 `NavController`。

```kotlin
// 顶层 Composable 拥有 NavController 实例
@Composable
fun ListScreen(navController: NavController) {
    UserList(
        // 通过 lambda 事件回调向下传递，保持 UserList 的无状态
        onUserClick = { userId ->
            navController.navigate("detail/$userId") // 在回调中执行导航
        }
    )
}

// UserList 是无状态的，它接收一个事件回调 (onUserClick)
@Composable
fun UserList(onUserClick: (Int) -> Unit) {
    // ... UI 列表项
    Item(onClick = { onUserClick(123) }) // 触发事件
}
```

## 屏幕适配 (Screen Adaptation)

传统的屏幕适配依赖于像素（dp），Compose 推荐使用 **窗口大小类** (Window Size Classes) 来进行响应式设计。窗口大小类基于当前应用窗口的可用空间，而不是设备的物理尺寸。

窗口大小类将屏幕宽度和高度分别划分为三个级别：

| 级别 | 描述 | 最小宽度 (dp) | 适用设备示例 |
| :--- | :--- | :--- | :--- |
| **Compact (紧凑)** | 小屏幕，通常是手机竖屏。 | 0 | 手机 |
| **Medium (中等)** | 中等屏幕，通常是折叠屏或平板竖屏。 | 600 | 7寸平板 / 手机横屏 |
| **Expanded (扩展)** | 大屏幕，通常是桌面、大平板或折叠屏展开。 | 840 | 10寸平板 / 双栏布局 |

- **`calculateWindowSizeClass(activity)`:** 在 `Activity` 中计算当前的 `WindowSizeClass`。
- **`currentWindowMetrics()`:** 用于获取当前窗口的原始尺寸信息。

### 响应式布局实现策略（推荐）

- 基于窗口大小类的结构调整

根据窗口大小类，完全改变 Composable 的布局方式（如从单列切换到双列）。

```kotlin
@OptIn(ExperimentalMaterial3WindowSizeClassApi::class)
@Composable
fun ResponsiveLayout(activity: Activity) {
    val windowSizeClass = calculateWindowSizeClass(activity = activity)

    when (windowSizeClass.widthSizeClass) {
        // Compact 模式: 紧凑，使用单列布局
        WindowWidthSizeClass.Compact -> 
            SinglePaneLayout()

        // Medium 和 Expanded 模式: 宽敞，使用双列布局
        WindowWidthSizeClass.Medium, WindowWidthSizeClass.Expanded -> 
            DualPaneLayout()
    }
}
```

- 基于局部约束的布局调整 (`BoxWithConstraints`)

当子组件需要根据其父组件提供的**实际可用空间**来决定自身布局时使用。

```kotlin
@Composable
fun ItemLayoutWithConstraints() {
    // BoxWithConstraints 提供了 maxWidth
    BoxWithConstraints(Modifier.fillMaxWidth().height(100.dp)) {
        if (maxWidth > 400.dp) {
            // 如果父容器宽度超过 400dp，使用 Row 布局
            Row(Modifier.fillMaxSize()) {
                Text("标题", Modifier.weight(1f))
                Text("详情", Modifier.weight(1f))
            }
        } else {
            // 否则，使用 Column 布局
            Column(Modifier.fillMaxSize()) {
                Text("标题")
                Text("详情")
            }
        }
    }
}
```

- 改变 Composable 元素的样式或大小 (Changing Element Style)

在不改变整体结构的情况下，根据尺寸或状态调整元素的间距、字体或最大宽度。

```kotlin
@Composable
fun ScalableHeader(isExpanded: Boolean) {
    val horizontalPadding = if (isExpanded) 32.dp else 16.dp
    val fontSize = if (isExpanded) 24.sp else 18.sp

    Text(
        text = "响应式标题",
        fontSize = fontSize,
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = horizontalPadding)
    )
}
```

### 传统配置适配

- **`LocalConfiguration.current`:** 通过 CompositionLocal 获取当前的 Android 配置，包括屏幕宽度/高度（`screenWidthDp`）、方向（`orientation`）和语言。

示例：根据配置切换布局

```kotlin
@Composable
fun ConfigurationAdaptation() {
    val configuration = LocalConfiguration.current
    
    when {
        // 1. 大屏幕/平板布局
        configuration.screenWidthDp >= 600 -> {
            TwoPaneLayout()
        }
        // 2. 手机横屏布局
        configuration.orientation == Configuration.ORIENTATION_LANDSCAPE -> {
            LandscapeLayout()
        }
        // 3. 手机竖屏布局 (默认)
        else -> {
            PortraitLayout()
        }
    }
}
```

### 屏幕密度适配

实现类似传统 View 系统中根据设计稿基准宽度进行**等比缩放**的效果。

- **`CompositionLocalProvider` + `LocalDensity`:** 通过替换局部 `Density` 对象，改变 `dp` 到像素的转换比例。

```kotlin
@Composable
fun DensityAdaptationTheme(
    designWidth: Float = 375f, // 设计稿宽度，例如 375dp
    content: @Composable () -> Unit
) {
    val context = LocalContext.current
    val displayMetrics = context.resources.displayMetrics
    val screenWidthPixels = displayMetrics.widthPixels.toFloat()

    // 计算新的 dp 缩放比例 (targetDensity)
    val targetDensity = screenWidthPixels / designWidth
    
    // 保持用户设置的字体缩放比例 (fontScale)
    val fontScale = LocalDensity.current.fontScale
    
    // 创建新的 Density 对象
    val customDensity = Density(density = targetDensity, fontScale = fontScale)

    // 使用 CompositionLocalProvider 覆盖局部密度
    CompositionLocalProvider(
        LocalDensity provides customDensity
    ) {
        content() // 内部所有的 dp 都会按照 375 的基准进行等比缩放
    }
}
```

### 其他适配技巧

- 使用百分比和权重

使用 `Modifier.weight()` 和 `Modifier.fillMax*()` 比使用硬编码的 `dp` 更具弹性。

```kotlin
// 在 Row 中分配权重
Row(Modifier.fillMaxWidth()) {
    // 占据 1/3 宽度
    Box(Modifier.weight(1f).background(Color.Red)) { Text("1") }
    // 占据 2/3 宽度
    Box(Modifier.weight(2f).background(Color.Blue)) { Text("2") } 
}
```

- 最大宽度约束 (`sizeIn`)

使用 `Modifier.sizeIn(maxWidth = 600.dp)` 限制内容的最大宽度，避免内容在平板设备上过于分散。

```kotlin
@Composable
fun CenteredContentLayout(content: @Composable () -> Unit) {
    Box(
        modifier = Modifier.fillMaxWidth(),
        contentAlignment = Alignment.TopCenter // 居中对齐内容
    ) {
        Column(
            modifier = Modifier
                // 限制最大宽度为 600dp (适合平板模式下的内容阅读)
                .sizeIn(maxWidth = 600.dp)
                .fillMaxWidth()
        ) {
            content()
        }
    }
}
```

- 使用 `windowInsets` 适配异形屏和系统 UI

Compose 默认处理大部分 `WindowInsets`（如状态栏、导航栏），但对于自定义 UI 区域，应使用 `WindowInsets` API 确保内容不被系统 UI 遮挡。

```kotlin
@Composable
fun FullScreenContent() {
    // 填充到屏幕边缘
    Scaffold(
        modifier = Modifier.fillMaxSize(),
        contentWindowInsets = WindowInsets.systemBars // 确保内容避开系统栏
    ) { paddingValues ->
        // 内容区
        Box(modifier = Modifier.padding(paddingValues)) {
            Text("安全内容区域")
        }
    }
}
```

## 性能优化 (Performance Optimization)

Compose 的性能优化很大程度上是为了**减少不必要的重组 (Recomposition)** 和 **缩小重组范围**。

- 重组机制
  - **Composition:** 首次运行 Composable 时构建 UI 树的过程。
  - **Recomposition (重组):** 当 Composable 函数依赖的 **状态 (State)** 发生变化时，Compose 重新执行该函数，并更新必要的 UI 元素。
  - **Skip (跳过):** Compose 的优化机制。如果一个 Composable 的所有输入参数（Parameters）都是**稳定**且未发生变化的，Compose 会跳过执行该 Composable。

- 影响重组的因素
  - **State Read (状态读取):** 只有当 Composable **读取**了状态 (`val value by state`) 并且该状态发生变化时，该 Composable 才会重组。
  - **Unstable Types (不稳定类型):** 如果 Composable 接收了 Compose 无法确定其是否发生变化的类型作为参数，Compose 会默认重新执行该 Composable，即使其内容可能未变。

- 性能评估前提
  - **构建模式**：**不要在 Debug 模式下评估性能**。Compose 在 Debug 模式下包含大量为了调试（如 Layout Inspector）而保留的额外代码，运行速度会慢很多。始终使用 **Release** 或 **Profile** 构建版本进行性能测试。
  - **Profileable**：如果需要通过 Android Studio Profiler 分析 Release 版本，可以在 `AndroidManifest.xml` 中添加 `<profileable android:shell="true"/>`。

### 参数稳定性 (Stability)

Compose 编译器会将类型标记为以下之一：

| 标记 | 稳定性 | 描述 |
| :--- | :--- | :--- |
| **Stable (稳定)** | 可跳过 | 通过 `equals` 比较结果可靠，且当其公开属性改变时，Compose 能收到通知（如 `MutableState`）。 |
| **Immutable (不可变)** | 可跳过 | 对象创建后内容完全不可变。 |
| **Unstable (不稳定)** | 不可跳过 | Compose 无法确定其是否改变，因此**每次都会重组**。 |

- **基础类型** (Int, String, Float, Data Class) 默认稳定。
- **标记 `@Immutable` 或 `@Stable` 的 Class**：用于手动告诉 Compose 编译器保证稳定性（前提是你必须遵守该保证）。

### 集合 (Collections) 优化

**集合 (Collections)** 接口（`List`, `Set`, `Map`）在 Compose 中被默认视为 **Unstable**，因为它们虽然在 Kotlin 中看起来是只读的，但底层可能是可变的。

```kotlin
// 错误示范：MyComponent 会因为 list 被视为不稳定而频繁重组
@Composable
fun MyComponent(list: List<String>) { /* ... */ }
```

#### 解决方案

- **使用 `@Immutable` 或 `@Stable` 注解**：
    手动给包含集合的数据类打标签。

```kotlin
@Immutable
data class UserState(val name: String, val list: List<String>) // 开发者保证 list 不会改变
```

- **使用 kotlinx.collections.immutable**：
    这是官方推荐的方式。使用 `ImmutableList` 替代 `List`。

    ```kotlin
    // 推荐：ImmutableList 是稳定的
    @Composable
    fun MyComponent(list: ImmutableList<String>) { /* ... */ }
    ```

### 列表优化 (Lazy Layouts)

- **使用 `key`**：
    在 `LazyColumn` / `LazyRow` 中显式指定 `key`。如果列表发生重新排序或部分删除，Compose 可以通过 Key 识别 Item，避免重建整个列表项。

```kotlin
items(items = myItems, key = { it.id }) { item ->
    UserRow(item)
}
 ```

- **避免在 Item 中嵌套复杂逻辑**：尽量让 Item 是轻量级且高度可重用的。
- **`contentType`**：如果列表中有多种布局类型，指定 `contentType` 可以帮助 Compose 复用组件，提高滚动性能。

### 状态读取的位置

将状态读取尽可能地推到 UI 层次结构的**最低层 (State Read Locally)**，尽可能晚地读取 State，最好是在 Layout 或 Draw 阶段，而不是在 Composition 阶段，确保只有需要更新的最小范围 Composable 被重组。

例子一

```kotlin
// 优化前：整个 Column 都会重组
@Composable
fun BadExample(count: State<Int>) {
    Column { // 整个 Column 重组
        // 读取状态
        Text("Count: ${count.value}")
    }
}

// 优化后：只有需要更新的 Text 被重组
@Composable
fun GoodExample(count: State<Int>) {
    Column { // 不重组
        Text("Header")
        CounterText(count) // 只有这里重组
    }
}
@Composable
fun CounterText(count: State<Int>) {
    // 状态读取下沉到最小单元
    Text("Count: ${count.value}")
}
```

例子二

```kotlin
// 低效：scrollPosition 变化会导致整个 Box 重组
Box(Modifier.offset(y = scrollPosition.value.dp))

// 高效：使用 Lambda 版本。
// 仅在 Layout 阶段读取，不会触发重组，只触发重新布局(Relayout)
Box(Modifier.offset { IntOffset(0, scrollPosition.value) })
```

类似的还有 `drawWithCache` 或颜色 lambda，例如 `Modifier.background { ... }` (如果存在)。

### 派生状态 (derivedStateOf)

当一个状态变化非常频繁（如滚动距离），但 UI 只需要在特定阈值变化时更新（如“显示回到顶部按钮”），使用 `derivedStateOf`。

```kotlin
val listState = rememberLazyListState()

// 错误：每次滚动都会导致重组
val showButton = listState.firstVisibleItemIndex > 0

// 正确：只有当结果(true/false)改变时才通知下游重组
val showButton by remember {
    derivedStateOf { listState.firstVisibleItemIndex > 0 }
}
```

### remember

- **缓存计算**：对于耗时的计算操作，务必使用 `remember` 缓存结果。
- **带参数的 remember**：`remember(key1) { ... }`，当 key 变化时才重新计算。

### 图片加载优化

图片通常是内存和性能的大户。

- **指定大小**：加载图片时，尽量指定目标尺寸，避免将全分辨率大图加载到内存中。
- **使用库 (Coil/Glide)**：使用 `AsyncImage` (Coil) 并开启磁盘缓存和内存缓存。
- **矢量图 vs 位图**：简单的图标使用 VectorDrawable (xml)，复杂的照片使用 WebP/JPG。不要使用过于复杂的矢量图（XML path 极多），解析会阻塞主线程。

### 监测与调试工具

| 工具 | 用途 |
| :--- | :--- |
| **Layout Inspector** | 查看重组次数 (Recomposition Counts) 和跳过次数 (Skipped)。 |
| **Compose Compiler Metrics** | 生成报告，告诉你哪些类是 Stable，哪些是 Unstable，以及为什么。 |
| **System Trace** | 查看精确的帧耗时，定位是 Layout 慢、Measure 慢还是 Draw 慢。 |
| **Benchmarking** | 使用 Jetpack Macrobenchmark 编写自动化性能测试，监控启动时间和帧率。 |

- 如何开启 Compiler Metrics

在 `build.gradle.kts` (Module level) 中添加：

```kotlin
android {
    kotlinOptions {
        freeCompilerArgs += listOf(
            "-P",
            "plugin:androidx.compose.compiler.plugins.kotlin:reportsDestination=" + project.buildDir.absolutePath + "/compose_metrics"
        )
    }
}
```

- **`skipping = true`:** Composable 可跳过（性能良好）。
- **`restartable = true`:** Composable 是重组的最小单元（性能良好）。
- **`unstable` parameters:** 提示需要修复的参数稳定性问题。

## UI 测试

Compose 测试不再依赖传统的 View 层次结构，而是依赖于 **语义树 (Semantics Tree)**。

- **同步机制**: Compose 测试 API 默认包含自动同步机制，会自动等待 UI 处于空闲状态（Idle）后再执行下一步操作。

UI 测试三大步骤：Find -> Perform -> Assert

Compose UI 测试的核心模式：**查找节点 -> 执行操作 -> 验证结果。**

配置

在 `app/build.gradle` 中添加依赖，确保 Compose UI 测试工具可用：

```groovy
dependencies {
    // 核心测试库
    androidTestImplementation "androidx.compose.ui:ui-test-junit4:$compose_version"
    
    // 需要在这个 manifest 中注册 TestActivity，用于调试模式
    debugImplementation "androidx.compose.ui:ui-test-manifest:$compose_version"
}
```

### 定义 Test Rule

所有的 Compose UI 测试都需要一个 `ComposeTestRule`。

```kotlin
@get:Rule
val composeTestRule = createComposeRule() 
// 如果需要访问 Activity 或其 Context，使用 createAndroidComposeRule<MainActivity>()

@Test
fun myUiTest() {
    // 设置被测内容
    composeTestRule.setContent {
        MyAppTheme {
            // 被测 Composable
            LoginScreen()
        }
    }
    // ... 开始测试逻辑
}
```

### Finders (查找器)

用于定位 UI 元素，所有方法都以 `onNode` 或 `onAllNodes` 开头。对于复杂或无文本的组件，推荐使用 `testTag`。

| 方法 | 描述 | 最佳实践 |
| :--- | :--- | :--- |
| `onNodeWithText("Submit")` | 通过显示的文本查找 | 按钮、标签 |
| `onNodeWithContentDescription("Logo")` | 通过无障碍描述查找 | 图标、图片 |
| `onNodeWithTag("login_btn")` | **通过 `Modifier.testTag` 查找** | 复杂组件、动态内容 |
| `onRoot()` | 获取根节点 | 验证全局属性 |

### Actions (操作)

对找到的节点执行交互，需调用 `.perform...()`。

| 方法 | 描述 |
| :--- | :--- |
| `performClick()` | 点击 |
| `performTextInput("text")` | 输入文本 |
| `performScrollTo()` | 滚动直到可见 (用于 Lazy List) |
| `performSwipeUp()` | 手势滑动 |

### Assertions (断言)

验证节点状态，以 `.assert...()` 开头。

| 方法 | 描述 |
| :--- | :--- |
| `assertIsDisplayed()` | 验证元素可见 |
| `assertDoesNotExist()` | 验证元素不存在 |
| `assertIsEnabled()` | 验证是否启用 |
| `assertTextEquals("Success")` | 验证文本内容 |

### 使用 `testTag` 进行高精度定位

**应用代码:**

```kotlin
Button(
    onClick = {}, 
    modifier = Modifier.testTag("submit_button") // 添加 Tag
) {
    Text("Submit")
}
```

**测试代码:**

```kotlin
composeTestRule.onNodeWithTag("submit_button").performClick()
```

### 调试语义树

如果找不到元素，可以将当前的语义树打印到 Logcat 中进行分析。

```kotlin
// 打印整个树的语义信息
composeTestRule.onRoot().printToLog("TAG_SEMANTICS")

// 打印特定节点及其子树
composeTestRule.onNodeWithTag("my_component").printToLog("TAG_NODE")
```

### 测试列表 (LazyColumn/Row)

对于 `Lazy` 容器，只有可见的 Item 存在于语义树中。要测试屏幕外的 Item，必须先滚动。

```kotlin
composeTestRule.onNodeWithTag("item_50")
    .performScrollTo() // 自动滚动直到找到该元素
    .assertIsDisplayed()
```

---

Compose 的自动同步机制并非万能，在处理网络延迟或无限动画时需要手动干预。

### 使用 `waitUntil` 处理延迟

用于等待某个条件成立（例如网络请求完成后，错误信息出现）。

```kotlin
// 执行触发异步操作
composeTestRule.onNodeWithText("Load Data").performClick()

// 等待直到某个节点出现（设置超时时间 5 秒）
composeTestRule.waitUntil(timeoutMillis = 5000) {
    composeTestRule
        .onAllNodesWithText("Success Message")
        .fetchSemanticsNodes().isNotEmpty()
}

composeTestRule.onNodeWithText("Success Message").assertIsDisplayed()
```

### 处理无限动画

如果 UI 包含无限循环的加载动画，需要关闭时钟的自动推进，防止测试超时。

```kotlin
@Test
fun testWithInfiniteAnimation() {
    // 1. 关闭自动推进
    composeTestRule.mainClock.autoAdvance = false
    
    composeTestRule.setContent { CircularLoader() }

    // 2. 验证元素存在（测试不会因动画卡死）
    composeTestRule.onNodeWithTag("loader").assertIsDisplayed()
}
```

---

## 单元测试：逻辑层 (ViewModel/UseCase)

UI 测试很慢，业务逻辑（状态生成）应该在 JVM 上的单元测试中完成。

### 配置与 Coroutines Rule

测试 ViewModel 需要处理 Coroutines 和 `StateFlow/LiveData`，因此需要替换主 Dispatcher。

```groovy
testImplementation "junit:junit:4.13.2"
testImplementation "org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.x"
// Test Rule 放在 sharedTest 或 test 目录下
```

### ViewModel 测试示例

```kotlin
class MyViewModelTest {

    // 替换主线程 Dispatcher，确保协程测试可控
    @get:Rule
    val mainDispatcherRule = MainDispatcherRule() 

    @Test
    fun testStateUpdate() = runTest {
        val viewModel = MyViewModel()
        
        // 验证初始状态
        assertEquals("Initial", viewModel.uiState.value)
        
        // 执行操作
        viewModel.updateData()
        
        // 验证更新后状态
        assertEquals("Updated", viewModel.uiState.value)
    }
}
```

---

## 基于状态的 UI 测试 (State-Based UI Testing)

这是 Compose 测试的基石：确保 UI 对所有状态（Loading, Success, Error）的反映是正确的。

### 核心策略：状态提升 (State Hoisting)

将 Composable 分离为 **Stateless (无状态)** 和 **Stateful (有状态)** 两部分。测试时，我们只关注 **Stateless** 组件。

- **Stateless Component**: 只接收 `state` 作为参数，不与 ViewModel 耦合。
- **测试方法**: 直接传入模拟的 `state`，验证 UI 渲染是否正确。

### 状态测试用例示例

假设 `UserScreenContent` 是一个无状态组件。

```kotlin
@Test
fun testErrorState_showsRetryButton() {
    // 1. 直接设置 Error 状态
    composeTestRule.setContent {
        UserScreenContent(state = UserUiState.Error("Network error"), onRetry = {})
    }

    // 2. 验证错误 UI 是否显示
    composeTestRule.onNodeWithTag("retry_btn").assertIsDisplayed()
    
    // 3. 验证内容是否未显示
    composeTestRule.onNodeWithTag("content").assertDoesNotExist()
}
```

---

## 截图测试 (Screenshot Testing / Visual Regression)

截图测试在 **JVM** 上运行，可以快速验证 UI 的视觉回退，是 UI 状态测试的有力补充。最流行的库是 **Paparazzi** 或 **Roborazzi**。

在项目根目录 `build.gradle` (settings plugin)：

```groovy
plugins {
    id 'app.cash.paparazzi' version '1.3.1'
}
```

在 `app/build.gradle`：

```groovy
dependencies {
    testImplementation "app.cash.paparazzi:paparazzi-junit4:1.3.1"
}
```

### 截图测试示例

截图测试通常放在 `src/test/` 目录下。

```kotlin
import app.cash.paparazzi.Paparazzi
import org.junit.Rule

class MyScreenshotTest {

    @get:Rule
    val paparazzi = Paparazzi() 

    @Test
    fun testErrorScreenSnapshot() {
        // 1. 设置被测内容 (直接传入固定的 State)
        paparazzi.snapshot {
            MyTheme {
                // 确保 Composable 是 Stateless 的
                UserScreenContent(state = UserUiState.Error("Offline"), onRetry = {})
            }
        }
        // 执行测试后，会在 build/reports/paparazzi 目录下生成截图
    }
}
```

### 截图测试流程

1. **记录 (Record)**: 第一次运行 `paparazziDebug` 任务，会生成参考图片 (`.png`)。
2. **验证 (Verify)**: 后续运行 `paparazziDebug` 任务，会将当前渲染的 UI **像素级对比**参考图片。
3. **失败处理**: 如果发现像素差异（例如设计师修改了字体颜色或边距），测试会失败。你需要手动检查差异，并决定是代码有 Bug 还是需要更新参考图片。

## 常见问题 (FAQ)

- **为什么我的视图状态会重置？**
  - 使用了 `remember` 而不是 `rememberSaveable`。配置更改（如旋转）会导致 `remember` 丢失数据。
- **为什么 LazyColumn 内状态丢失？**
  - 没有为 item 设置 `key`。当列表数据变化时，Compose 无法正确对应 item 状态。
- **为什么动画不生效？**
  - 忘记使用 `animate*AsState` 或状态没有触发重组。
- **为什么点击事件不触发？**
  - Modifier 顺序问题。`clickable` 应该在 `padding` 之前还是之后取决于你想要的点击区域。
- **如何隐藏键盘？**
  - `LocalSoftwareKeyboardController.current?.hide()`。
