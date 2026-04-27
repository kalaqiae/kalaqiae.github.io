---
title: "Android Koin"
date: 2025-12-11T14:09:13+08:00
draft: true
tags: ["Android"]
categories: ["Android"]
---

模块 组件 注入 生命周期 作用域  测试 性能 优化 和 Hilt 对比

## 1. Koin 的设计理念与取舍

Koin 提供的是一种以 Kotlin DSL 为核心、依赖在运行时解析的依赖注入方案。

它并不追求编译期的强安全性，而是用更低的使用成本和更高的灵活性，  
换取更快的开发效率。

---

### 1.1 什么是 Koin？

Koin 是一个 Kotlin First 的依赖注入框架，主要特点是：

- 使用 Kotlin DSL 定义依赖
- 无注解、无代码生成
- 依赖关系在运行时解析

它更像是一个“用代码描述依赖关系的容器”，而不是一个编译期工具。

---

### 1.2 核心机制与设计取舍

#### 1.2.1 Service Locator vs Dependency Injection

从使用方式上看，Koin 更接近 Service Locator：

```kotlin
val repository: UserRepository by inject()
```

依赖并非完全通过构造函数显式传入，而是通过容器在运行时获取。

优点是简单、灵活；  
代价是依赖关系不再完全显式，编译期无法完整校验依赖图。

---

#### 1.2.2 运行时解析（Runtime Resolution）

Koin 的依赖图是在运行时构建的，这意味着：

- 依赖缺失
- 参数不匹配
- 定义顺序错误

这些问题只能在运行时暴露，可能直接导致应用崩溃。

---

#### 1.2.3 与编译期生成方案的对比

Hilt / Dagger 通过编译期代码生成来保证依赖安全，但代价是：

- 注解体系复杂
- 编译时间增加
- 构建工具链更重

---

### 1.3 Koin vs Hilt / Dagger

| 特性 | Koin | Hilt/Dagger | 优势 |
| :--- | :--- | :--- | :--- |
| **底层机制** | 服务定位器 | 编译时依赖注入 | Hilt/Dagger 在编译时发现错误 |
| **代码实现** | Kotlin DSL (函数) | Java/Kotlin 注解 | Koin 代码更简洁易读 |
| **学习曲线** | 低 | 高 | Koin 几乎无需学习 DI 概念即可上手 |
| **编译速度** | 快 (无代码生成) | 慢 (需要 KAPT/KSP) | Koin 显著提高大型项目的编译速度 |
| **错误检查** | 运行时 (`checkModules()` 辅助) | 编译时 | Hilt/Dagger 更加安全可靠 |
| **包大小** | 小 (纯 Kotlin 库) | 较大 (依赖生成代码) | Koin 轻量级 |

---

### 1.4 核心术语速览

- **Module**：一组依赖定义的集合  
- **Definition**：具体的依赖声明，如 single / factory / scoped  
- **Graph**：由所有依赖定义构成的依赖关系图，在运行时解析  
- **Scope**：用于控制依赖的生命周期范围  
- **Component**：依赖的使用者，在 Android 中通常是 Activity、Fragment、ViewModel  

---

## 2. Koin 的基础使用

### 2.1 项目初始化

#### 2.1.1 依赖引入

```kotlin
dependencies {
    // 引入 Koin BOM
    implementation(platform("io.insert-koin:koin-bom:3.x.x"))
    // 核心库 & Android 扩展
    implementation("io.insert-koin:koin-android")
}
```

---

#### 2.1.2 启动 Koin

通常在 Application 中完成初始化：

```kotlin
class App : Application() {

    override fun onCreate() {
        super.onCreate()

        startKoin {
            // 绑定 Android Context
            androidContext(this@App)
            // 加载定义好的 Modules
            modules(appModule, networkModule)
        }
    }
}
```

`startKoin {}` 的职责是：

- 初始化 Koin 容器
- 绑定 Android Context
- 加载所有 Module 并构建运行时依赖图

---

### 2.2 依赖定义与生命周期

在 Koin 中，所有依赖定义都写在 `module {}` 中。  
理解不同定义方式的生命周期差异，是避免内存问题和初始化错误的关键。

```kotlin
val appModule = module {
    // dependency definitions
}
```

---

#### 2.2.1 single：单例（默认懒加载）

```kotlin
val appModule = module {
    single { UserRepositoryImpl() }
}
```

特性：

- 全局唯一实例  
- 默认懒加载（首次调用 inject/get 时创建）

---

#### 2.2.2 factory：每次创建新实例

```kotlin
val appModule = module {
    factory { LoginUseCase(get()) }
}
```

特性：

- 每次注入都会创建新对象  
- 适用于无状态、轻量级对象

---

#### 2.2.3 scoped：作用域内单例

```kotlin
scoped { SessionManager(get()) }
```

特性：

- 在特定 Scope 生命周期内是单例  
- Scope 关闭后对象自动销毁  
- 适用于 Activity/Fragment 级别或用户会话级对象

---

#### 2.2.4 急切加载 (Eager Loading)

```kotlin
val dataModule = module {
    single(createdAtStart = true) { DatabaseInitializer() }
}
```

特性：

- App 启动时立即创建实例  
- 适用于 SDK 初始化、数据库或日志工具  
- 会影响启动耗时，应谨慎使用

---

### 2.3 依赖注入方式

#### 2.3.1 `inject`：懒加载注入 (推荐)

基于 Kotlin 属性委托，懒加载，适合绝大多数 Android 组件

```kotlin
class MainActivity : AppCompatActivity() {
    private val userRepo: UserRepository by inject()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        userRepo.login()
    }
}
```

---

#### 2.3.2 `get`：直接获取

立即从容器中获取实例，常用于非 Android 组件类（如普通 Kotlin 类、Utils 类）或者在 `module` 定义块内部使用。

```kotlin
// 在普通类中需实现 KoinComponent 接口(不推荐滥用）
class Helper : KoinComponent {
    fun doSomething() {
        val service: ApiService = get()
        service.call()
    }
}

// 在 Module 定义中（最常见用法）,`get()` 更适合在 Module 定义内部使用，用于解析构造函数依赖。
val appModule = module {
    // get() 会自动推断构造函数需要的类型，并去容器查找
    single { UserViewModel(get(), get()) }
}
```

---

### 2.4 接口与实现绑定

在遵循依赖倒置原则（DIP）的架构中，应优先注入接口而非具体实现，以降低模块间耦合。

假设存在如下结构：

```kotlin
interface NetworkService
class NetworkServiceImpl : NetworkService
```

#### 2.4.1 泛型声明（推荐)

在定义时明确指定返回类型为接口。

```kotlin
val remoteModule = module {
    // 告诉 Koin：这是一个 NetworkService，具体实现是 NetworkServiceImpl
    single<NetworkService> { NetworkServiceImpl() }
}
```

#### 2.4.2 使用 `bind` 操作符

当一个类实现了多个接口，或者为了代码可读性，可以使用 `bind`。

```kotlin
val remoteModule = module {
    // 定义实现类，同时绑定到接口
    single { NetworkServiceImpl() } bind NetworkService::class

    // 如果实现了多个接口
    // single { MyImpl() } binds arrayOf(InterfaceA::class, InterfaceB::class)
}
```

> 注：如果你使用了 `bind` 或泛型声明，在注入时必须请求接口类型，否则会抛出 `NoBeanDefFoundException`。

```kotlin
// 正确
val service: NetworkService by inject()

// 错误（除非你单独定义了 NetworkServiceImpl 类型）
// val service: NetworkServiceImpl by inject()
```

---

## 3. Android 集成

### 3.1 ViewModel 注入（核心）

Koin 为 Android ViewModel 提供了专门的 `viewModel` DSL。  
它可以理解为一种 **为 Android ViewModel 定制的 factory**，内部封装了 `ViewModelProvider` 相关逻辑，用于正确处理生命周期与配置变更。

---

#### 3.1.1 定义 ViewModel

在 Module 中，使用 `viewModel {}` 而不是 `single {}` 或 `factory {}`：

```kotlin
val viewModelModule = module {
    viewModel {
        MainViewModel(
            userRepository = get(),
            logger = get()
        )
    }
}
```

这样定义的 ViewModel：

- 会自动绑定 `ViewModelStore`
- 能正确处理屏幕旋转等配置变更
- 不需要手动编写 `ViewModelProvider.Factory`

---

#### 3.1.2 在 Activity / Fragment 中使用

在 Activity 或 Fragment 中，通过属性委托获取 ViewModel：

```kotlin
class UserActivity : AppCompatActivity() {

    // 自动关联当前 Activity 的生命周期
    private val userViewModel: UserViewModel by viewModel()

    // 如果是在 Fragment 中，想共享 Activity 的 ViewModel
    // private val sharedViewModel: UserViewModel by activityViewModel()
}
```

这种方式：

- 不需要手动创建 ViewModelFactory
- 不需要处理 SavedStateHandle（除非你需要）
- 与官方 ViewModel 使用方式保持一致

---

#### 3.1.3 `viewModelOf`（减少样板代码）

在 Koin 3.2+ 中，可以使用 `viewModelOf` 直接引用构造函数：

```kotlin
val viewModelModule = module {
    viewModelOf(::MainViewModel)
}
```

`viewModelOf` 的优势：

- 构造函数 **只能接收依赖**
- 不允许混入运行时参数
- Module 定义更接近“依赖声明”而非“实例创建”

使用建议：

- 无运行时参数的 ViewModel → **优先使用 `viewModelOf`**
- 需要参数的 ViewModel → 使用 `viewModel { (param) -> ... }`

#### 3.1.4 ViewModel 注入的幕后机制（了解即可）

Koin 内部通过自定义的 `ViewModelProvider.Factory` 实现：

- ViewModel 实例仍由 Android Framework 管理
- Koin 仅负责构造函数依赖解析
- 不需要手动编写 Factory 类

---

### 3.2 Android Context 的使用

在 `startKoin {}` 中调用 `androidContext()` 后，Koin 容器持有的是 **Application Context**。(初始化参考2.1.2)

#### 3.2.1 在 Module 使用 Context

在 Module 中可以通过 `androidContext()` 获取 Application Context：

```kotlin
val dataModule = module {
    //`single` (单例) 生命周期与 Application 一致，应该用 Application Context。不能持有 Activity Context，否则会导致内存泄漏
    single {
        Database(
            context = androidContext()
        )
    }
}
```

---

### 3.3 Activity / Fragment 中的注入

除了 ViewModel，也可以注入 Adapter、ImageLoader 或工具类等对象。

- **不推荐直接使用 `get()`**
  - 虽然可以直接获取实例，但可读性和可维护性较差
- **推荐使用 `by inject()`**
  - 支持延迟加载
  - 语法更声明式，代码更简洁
  - 更符合依赖注入的使用习惯
- 生命周期：注入对象的存活时间由 Module 定义（single / factory / scoped）决定，与注入位置无关。
- 并非绑定：inject() 仅负责获取对象。若需对象随 Activity 销毁而释放，必须配合 Scope 使用。
- 
```kotlin
class DetailFragment : Fragment() {

    private val analytics: AnalyticsTracker by inject()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        analytics.trackPage("detail")
    }
}
```

---

### 3.4 Android 中的 Scope 管理

当依赖的生命周期需要严格跟随某个 Android 组件时，可以使用 Scope。

---

1. **定义 Scope Module**
    ```kotlin
    val activityModule = module {
        scope<DetailActivity> {
            // 在 DetailActivity 存活期间，DetailPresenter 是单例
            scoped { DetailPresenter(get()) }
        }
    }
    ```

2. **在 Activity 中绑定**
    ```kotlin
    class DetailActivity : AppCompatActivity(), AndroidScopeComponent {

        // 1. 复写 scope 属性，通过 activityScope() 绑定生命周期
        override val scope: Scope by activityScope()

        // 2. 使用 scope.inject() 获取作用域内的实例
        private val presenter: DetailPresenter by scope.inject()

        override fun onCreate(savedInstanceState: Bundle?) {
            super.onCreate(savedInstanceState)
        }
    }
    ```

Scope 会在 Activity 销毁时自动关闭，对象随之释放。

---

### 3.5 带参数的 ViewModel 注入

有时 ViewModel 需要通过 Intent 接收外部动态参数。

#### 3.5.1 Module 中声明参数

使用 lambda 表达式接收 `parameters`：

```kotlin
val appModule = module {
    // 使用解构声明获取参数
    viewModel { (userId: String) ->
        UserDetailViewModel(userId = userId, repository = get())
    }
}
```

#### 3.5.2 在 UI 层传递参数

使用 `parametersOf` 传递参数：

```kotlin
class UserDetailActivity : AppCompatActivity() {

    private val userId by lazy { intent.getStringExtra("UID") ?: "" }

    // 动态传参
    private val viewModel: UserDetailViewModel by viewModel { 
        parametersOf(userId) 
    }
}
```

#### 3.5.3 Fragment 参数与依赖的边界

需要区分两件事：

- Fragment 参数：属于 UI 状态，应通过 arguments/Intent 传递
- 依赖对象：属于业务依赖（Repository、UseCase、Manager），应通过 Koin 注入

不应将业务依赖通过 arguments 传递，也不应用依赖注入替代 UI 参数。  
判断原则：可复用、全局一致 → 依赖，与页面实例强相关 → 参数

---

## 4. Jetpack Compose 集成

Compose 下 Koin 的核心是：ViewModel 注入与在 Navigation 中正确选择 ViewModelStoreOwner（避免作用域错位）。

在使用 Jetpack Compose 时，需要额外引入 Koin 对 Compose 的扩展库，以便在 Composable 函数中安全、简洁地获取依赖。

---

### 4.1 Compose 环境下的 Koin 配置

#### 4.1.1 Compose 基础配置

Compose 的基础配置与是否使用 Koin 无关，但必须先确保项目已开启 Compose：

```kotlin
android {
    buildFeatures {
        compose = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.x.x"
    }
}

dependencies {
    implementation(platform("androidx.compose:compose-bom:202x.xx.xx"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.ui:ui-tooling-preview")
    debugImplementation("androidx.compose.ui:ui-tooling")
}
```

---

#### 4.1.2 Koin Compose 依赖

在原有 `koin-android` 的基础上，为 Compose 增加扩展依赖：

```kotlin
dependencies {
    implementation(platform("io.insert-koin:koin-bom:3.x.x"))
    implementation("io.insert-koin:koin-android")
    implementation("io.insert-koin:koin-androidx-compose")

    // 如果你使用 Navigation-Compose，并希望更方便地与 NavBackStackEntry 配合
    // implementation("io.insert-koin:koin-androidx-compose-navigation")
}
```

如果你已经在 Application 中完成了 `startKoin { androidContext(...) modules(...) }`，Compose 层通常不需要额外初始化。

---

### 4.2 Composable 中注入 ViewModel

在 Compose 中，不再直接操作 Activity / Fragment，而是通过 Composable 函数描述 UI。  
Koin 提供了 `koinViewModel()` 来替代传统的 `by viewModel()`。

---

#### 4.2.1 使用 `koinViewModel()` 获取 ViewModel

```kotlin
@Composable
fun UserScreen() {
    val viewModel: UserViewModel = koinViewModel()
    val state = viewModel.uiState

    UserContent(state = state)
}
```

`koinViewModel()` 的行为特征：

- 默认绑定当前 `NavBackStackEntry` 或宿主的 `ViewModelStoreOwner`
- 支持配置变更（如旋转屏幕）
- 与非 Compose 场景下的 `viewModel()` 行为一致

---

#### 4.2.2 与 `viewModelOf` 的配合使用

在 Module 中推荐继续使用 `viewModelOf`：

```kotlin
val appModule = module {
    viewModelOf(::UserViewModel)
}
```

Compose 层无需关心依赖构造细节，只关注状态与事件。

---

#### 4.2.3 带参数的 ViewModel（`parametersOf`）

当 ViewModel 需要页面参数时，仍按 Koin 的参数注入方式处理：

```kotlin
val detailModule = module {
    viewModel { (userId: String) ->
        UserDetailViewModel(userId = userId, repository = get())
    }
}
```

Composable 中传参：

```kotlin
@Composable
fun UserDetailRoute(userId: String) {
    val viewModel: UserDetailViewModel = koinViewModel { parametersOf(userId) }
    UserDetailScreen(state = viewModel.uiState)
}
```

边界仍然成立：`userId` 是 UI 参数，`repository` 是业务依赖。

参数注入是必要能力，但不是默认选择。复杂参数通常更适合通过 `SavedStateHandle` 管理。

---

### 4.3 Composable 中注入普通依赖

除了 ViewModel，也可以在 Composable 中直接获取普通依赖对象。

---

#### 4.3.1 使用 `koinInject()`

```kotlin
@Composable
fun AnalyticsEffect() {
    val tracker: AnalyticsTracker = koinInject()

    LaunchedEffect(Unit) {
        tracker.trackPage()
    }
}
```

注意：

- `koinInject()` 是立即获取
- 更适合轻量级、无状态依赖

---

#### 4.3.2 使用边界与注意事项

- UI 层优先只依赖 ViewModel
- 不要在大量 Composable 中随意注入 Repository / Manager
- 避免将 DI 当作状态管理工具使用

如果发现多个 Composable 直接注入同一个依赖，通常说明：

- ViewModel 职责不够集中
- 状态提升（State Hoisting）设计有问题

---

### 4.4 Compose Navigation 中的 ViewModel 管理

Navigation-Compose 的 ViewModel 生命周期与 `NavBackStackEntry` 绑定。  
当你在导航目的地内部创建 ViewModel 时，要确保 ViewModel 的 owner 是正确的 BackStackEntry，否则会出现：

- 目的地切换时 ViewModel 没销毁（泄漏式持有）
- 多个目的地误共享同一个 ViewModel（状态串台）
- 回退栈恢复时状态丢失或错乱

---

#### 4.4.1 每个目的地一个 ViewModel（默认推荐）

把 ViewModel 获取放在 `composable(route) { backStackEntry -> ... }` 内部，并显式指定 owner：

```kotlin
@Composable
fun AppNavGraph(navController: NavHostController) {
    NavHost(navController = navController, startDestination = "user") {
        composable("user") { backStackEntry ->
            val viewModel: UserViewModel = koinViewModel(viewModelStoreOwner = backStackEntry)
            UserContent(state = viewModel.uiState)
        }
    }
}
```

这样 ViewModel 的创建/销毁严格跟随该目的地在回退栈中的生命周期。

此时 ViewModel 的生命周期通常是：

- 创建：首次进入该路由
- 销毁：该路由从导航栈移除

---

#### 4.4.2 在多个目的地间共享 ViewModel（按 NavGraph 共享）

当多个目的地属于同一个流程（例如注册流程、下单流程），通常希望共享同一个 ViewModel。  
做法是把 owner 绑定到某个 NavGraph 的 BackStackEntry：

```kotlin
@Composable
fun UserNavGraph(navController: NavHostController) {
    val graphRoute = "user_graph"

    NavHost(navController = navController, startDestination = "list", route = graphRoute) {
        composable("list") {
            val graphEntry = remember(navController) { navController.getBackStackEntry(graphRoute) }
            val viewModel: UserViewModel = koinViewModel(viewModelStoreOwner = graphEntry)
            UserListScreen(state = viewModel.uiState)
        }

        composable("detail") {
            val graphEntry = remember(navController) { navController.getBackStackEntry(graphRoute) }
            val viewModel: UserViewModel = koinViewModel(viewModelStoreOwner = graphEntry)
            UserDetailScreen(state = viewModel.uiState)
        }
    }
}
```

这个模式的本质是：把 ViewModel “挂”在一个更高层级的 owner 上，从而实现多个目的地共享状态。

---

#### 4.4.3 常见坑与排查方向

- 页面 recomposition 不会导致 ViewModel 重建；但 owner 选错会导致 ViewModel 作用域不符合预期
- 若出现“状态串台”，优先检查 route 是否复用、是否把 owner 写成了 Activity（导致全局共享）
- 若出现“回退后状态消失”，优先检查是否在不同 backStackEntry 上各创建了一份 ViewModel


---

### 4.5 Compose 中的参数传递与 ViewModel 边界

在 Compose + Navigation 场景下，同样需要区分：

- 参数（Argument）：来自导航参数，与页面实例强相关
- 依赖（Dependency）：Repository / UseCase 等，由 Koin 提供

---

#### 4.5.1 通过 Navigation 传递参数

```kotlin
composable("detail/{id}") { backStackEntry ->
    val userId = backStackEntry.arguments?.getString("id") ?: ""
    val viewModel: UserDetailViewModel = koinViewModel { parametersOf(userId) }
    UserDetailScreen(state = viewModel.uiState)
}
```

---

#### 4.5.2 不要在 Composable 中滥用参数注入

参数注入是必要能力，但不是默认选择：

- 复杂参数：优先通过 `SavedStateHandle`
- 业务状态：应由 ViewModel 管理
- Composable：只负责展示与事件分发

---
