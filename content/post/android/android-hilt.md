---
title: "Android Hilt"
date: 2025-12-10T23:36:09+08:00
draft: true
tags: ["Android"]
categories: ["Android"]
---

[Hilt 官方文档](https://developer.android.com/training/dependency-injection/hilt-android)

Hilt 是 Dagger 在 Android 上的“约定优于配置”封装：帮你把常见的 Component / Scope / EntryPoint 组合好，让依赖图更容易落地到 Activity / Fragment / ViewModel / Service 等组件上。

<!--more-->

## 1. Hilt 基础理念

### 1.1 为什么需要依赖注入（DI）

- 模块解耦  
- 便于替换实现  
- 可测试性更强  
- 控制对象生命周期  

### 1.2 Hilt 是什么

- Google 官方推出的 Android DI 框架  
- 基于 Dagger  
- 自动为 Activity / Fragment / ViewModel 等注入依赖  

### 1.3 Hilt 与 Dagger 的区别

| 内容 | Hilt | Dagger |
|------|------|--------|
| 复杂度 | ⭐ 低 | ⭐⭐⭐ 高 |
| 自动注入 Android 组件 | ✔ | ✘ |
| 测试支持 | 强 | 需要额外配置 |

---

## 2. Hilt 基础使用流程

### 2.1 添加依赖

```kotlin
plugins {
    id("kotlin-kapt")
    id("com.google.dagger.hilt.android")
}

dependencies {
    implementation("com.google.dagger:hilt-android:2.52")
    kapt("com.google.dagger:hilt-android-compiler:2.52")
}
```

### 2.2 Application 注解

```kotlin
@HiltAndroidApp
class MyApp : Application()
```

### 2.3 Activity 注入

```kotlin
@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    @Inject lateinit var repository: UserRepository
}
```

### 2.4 构造函数注入

```kotlin
class UserRepository @Inject constructor(
    private val api: ApiService
) {
}
```

### 2.5 @Provides 提供依赖

```kotlin
@Module
@InstallIn(SingletonComponent::class)
object ConfigModule {

    @Provides
    fun provideBaseUrl(): String = "https://api.xxx.com"
}
```

---

## 3. Hilt Component（组件）与生命周期

Hilt 内置组件：

| Component | 生命周期 |
|----------|----------|
| SingletonComponent | 应用全局 |
| ActivityRetainedComponent | 跨配置变更的 Activity（承载 ViewModel） |
| ViewModelComponent | ViewModel |
| ActivityComponent | Activity |
| FragmentComponent | Fragment |
| ViewWithFragmentComponent | Fragment 内的 View |
| ViewComponent | View |
| ServiceComponent | Service |
| BroadcastReceiverComponent | BroadcastReceiver |

生命周期层级结构：

```text
Application
 └── ActivityRetained
      └── ViewModel
      └── Activity
           └── Fragment
                └── View
```

作用域示例：

```kotlin
@Singleton
class AppConfig @Inject constructor()
```

---

## 4. Hilt Module 详解

### 4.1 @Module 与 @InstallIn

```kotlin
@Module
@InstallIn(SingletonComponent::class)
object AppModule {
}
```

### 4.2 @Provides

```kotlin
@Module
@InstallIn(SingletonComponent::class)
object JsonModule {

    @Provides
    fun provideGson(): Gson = Gson()
}
```

### 4.3 @Binds（接口绑定）

```kotlin
@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {

    @Binds
    abstract fun bindUserRepository(
        impl: UserRepositoryImpl
    ): UserRepository
}
```

---

## 5. Qualifier（区分多实现）

```kotlin
@Qualifier
@Retention(AnnotationRetention.BINARY)
annotation class DebugClient

@Qualifier
@Retention(AnnotationRetention.BINARY)
annotation class ProdClient
```

使用：

```kotlin
@Module
@InstallIn(SingletonComponent::class)
object OkHttpModule {

    @DebugClient
    @Provides
    fun provideDebugClient(): OkHttpClient = ...
}
```

### 5.1 Context 注入（Application / Activity）

```kotlin
class FileLogger @Inject constructor(
    @ApplicationContext private val appContext: Context
)
```

---

## 6. Hilt + Jetpack 组件整合

### 6.1 HiltViewModel

```kotlin
@HiltViewModel
class MainViewModel @Inject constructor(
    private val repo: UserRepository
) : ViewModel()
```

### 6.2 Compose 中使用 hiltViewModel()

```kotlin
@Composable
fun HomeScreen(
    vm: HomeViewModel = hiltViewModel()
)
```

### 6.3 Compose Navigation + Hilt

```kotlin
composable("home") {
    val vm: HomeViewModel = hiltViewModel()
    HomeScreen(vm)
}
```

---

## 7. Hilt + Retrofit（网络层最佳实践）

```kotlin
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    fun provideRetrofit(): Retrofit {
        return Retrofit.Builder()
            .baseUrl("https://xxx.com")
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }

    @Provides
    fun provideApi(retrofit: Retrofit): ApiService {
        return retrofit.create(ApiService::class.java)
    }
}
```

---

## 8. Hilt 数据层集成

### 8.1 DataStore

```kotlin
@Provides
fun provideDataStore(
    @ApplicationContext context: Context
): DataStore<Preferences> {
    return PreferenceDataStoreFactory.create(
        produceFile = { context.preferencesDataStoreFile("settings") }
    )
}
```

### 8.2 MMKV 注入

```kotlin
@Provides
@Singleton
fun provideMMKV(): MMKV = MMKV.defaultMMKV()
```

### 8.3 Room

```kotlin
@Provides
fun provideDb(
    @ApplicationContext context: Context
): AppDatabase {
    return Room.databaseBuilder(context, AppDatabase::class.java, "app.db").build()
}
```

---

## 9. Hilt + Clean Architecture 最佳实践

### 9.1 推荐目录结构

```text
data/
    di/
    repository/
    datasource/
domain/
    usecase/
    model/
app/
    ui/
    di/
```

### 9.2 Repository 接口绑定

```kotlin
@Module
@InstallIn(SingletonComponent::class)
abstract class UserRepositoryModule {

    @Binds
    abstract fun bindUserRepo(
        impl: UserRepositoryImpl
    ): UserRepository
}
```

### 9.3 UseCase 注入

```kotlin
class GetUserUseCase @Inject constructor(
    private val repo: UserRepository
) {
}
```

---

## 10. Hilt 高级用法

### 10.1 EntryPoint

```kotlin
@EntryPoint
@InstallIn(SingletonComponent::class)
interface AnalyticsEntryPoint {
    fun analytics(): Analytics
}

val entry = EntryPointAccessors.fromApplication(
    context,
    AnalyticsEntryPoint::class.java
)
```

### 10.2 运行时参数：SavedStateHandle 与 AssistedInject

```kotlin
@HiltViewModel
class DetailViewModel @Inject constructor(
    private val savedStateHandle: SavedStateHandle
) : ViewModel() {
    val id: String = checkNotNull(savedStateHandle["id"])
}
```

如果是“非 Android 组件托管的对象”需要运行时参数，可以用 AssistedInject：

```kotlin
class ReportUploader @AssistedInject constructor(
    private val api: ApiService,
    @Assisted private val reportId: String
) {
    @AssistedFactory
    interface Factory {
        fun create(reportId: String): ReportUploader
    }
}
```

---

## 11. Hilt 测试

### 11.1 测试依赖

```kotlin
androidTestImplementation("com.google.dagger:hilt-android-testing:2.52")
kaptAndroidTest("com.google.dagger:hilt-android-compiler:2.52")
```

### 11.2 @HiltAndroidTest

```kotlin
@HiltAndroidTest
class HomeViewModelTest {

    @get:Rule
    var hiltRule = HiltAndroidRule(this)

    @Test
    fun testLoadData() { ... }
}
```

### 11.3 替换 Module

```kotlin
@TestInstallIn(
    components = [SingletonComponent::class],
    replaces = [NetworkModule::class]
)
@Module
object FakeNetworkModule { ... }
```

---

## 12. 常见错误与解决方案

### 12.1 Missing binding

- 没有 `@Inject` 构造函数
- 没有 `@Provides` / `@Binds`
- 作用域冲突（例如把短生命周期对象注入到长生命周期作用域）

### 12.2 ViewModel 注入失败

- 必须使用 `@HiltViewModel`
- Compose 中用 `hiltViewModel()`

---

## 13. 大型项目中的 Hilt 组织方式

```text
core/
    di/
    network/
    database/

feature_x/
    ui/
    data/
    di/
```

关键建议：

- 每个模块独立 DI
- 不要把所有依赖塞进 SingletonComponent
- 依赖分层：app / core / feature

---

## 14. Hilt 最佳实践总结

- 优先使用构造函数注入
- 少用巨型 Module
- 使用 Qualifier 而不是 `@Named`
- 不滥用 `@Singleton`
- Compose 中统一使用 `hiltViewModel()`
- Repository 层使用接口 + 实现
