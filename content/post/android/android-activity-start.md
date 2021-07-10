---
title: "activity 跳转"
date: 2021-07-10T22:38:45+08:00
draft: false
tags: ["Android","Activity"]
categories: ["Android"]
---

### 用第三方跳转

[ARouter](https://github.com/alibaba/ARouter)

### 显式启动

#### 方法一

```java
startActivity(new Intent(this, TestActivity.class));
```

<!--more-->

#### 方法二

```java
Intent intent = new Intent();
intent.setClass(this, TestActivity.class);
startActivity(intent);
```

#### 方法三（可用于打开其它的应用）

```java
Intent intent = new Intent();
intent.setComponent(new ComponentName(this, TestActivity.class));
startActivity(intent);
```
<!-- 待补充 -->

#### 结束页面返回数据 startActivityForResult

```java
public static final int RESULT_OK = -1;
//跳转方式
startActivityForResult(new Intent(this, TestActivity.class), RESULT_OK);

//重写 onActivityResult
@Override
protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    switch (resultCode) {
        case RESULT_OK:
            String result = data.getExtras().getString("result");
            break;
    }
}
```

在 TestActivity 结束时返回数据

```java
Intent intent = new Intent();
intent.putExtra("result", "test");
OtherActivity.this.setResult(RESULT_OK, intent);
finish();
```

### 隐式启动

#### 通过 action 跳转

```java
Intent intent = new Intent();  
intent.setAction("com.test.jump");  
startActivity(intent);
```

在AndroidManifest.xml 中给要跳转的 activity 设置 action

```xml
<activity android:name=".TestActivity" >  
    <intent-filter>  
        <action android:name="com.test.jump"/>  
        <category android:name="android.intent.category.DEFAULT" />  
    </intent-filter>  
</activity>
```

#### 通过 Scheme 跳转协议跳转

URL Scheme 协议格式：
scheme://host:port/path 协议名://主机:端口/路径  
和网址差不多 https://loaclhost:8080/index.jsp  
e.g. kalaqiae://jump.test:8888/TestActivity?id=123  
其实就是定协议，端口可以不写，kalaqiae://jump.test/TestActivity

在AndroidManifest.xml 中给要跳转的 activity 的 intent-filter 里设置 Scheme

```xml
<activity android:name=".TestOneActivity">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <!--指定该activity能被浏览器安全调用-->
        <category android:name="android.intent.category.BROWSABLE" />
        <data
            android:host="jump.test"
            android:path="/TestActivity"
            android:scheme="kalaqiae" />
    </intent-filter>
</activity>
```

在对转的 activity 的 onCreate 中处理获取的数据

```java
Uri uri = getIntent().getData();
if (uri != null) {
    String url = uri.toString();
    String scheme = uri.getScheme();
    String host = uri.getHost();
    int port = uri.getPort();
    String path = uri.getPath();
    List<String> pathSegments = uri.getPathSegments();
    String query = uri.getQuery();
    //获取指定参数值
    String id = uri.getQueryParameter("id");
    Log.e(TAG, "id: " + id);
}
```

在 Android 中调用

```java
Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse("kalaqiae://jump.test/TestActivity?id=123"));
startActivity(intent);
```

网页中调用

```html
<a href="kalaqiae://jump:test/TestActivity?id=123">test</a>
```

判断 Scheme 是否有效

```java
PackageManager packageManager = getPackageManager();
Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse("kalaqiae://jump.test/TestActivity?id=123"));
List<ResolveInfo> activities = packageManager.queryIntentActivities(intent, 0);
boolean isValid = !activities.isEmpty();
if (isValid) {
    startActivity(intent);
}
```

### 传递数据

使用 intent

```java

Intent intent = new Intent(this, TestActivity.class);
intent.putExtra("data", "value");
TestBean bean = new TestBean();
//传递序列化对象
intent.putExtra("data", bean);
startActivity(intent);

//TestActivity 获取数据
Intent intent = getIntent();
String str = intent.getStringExtra("data");
Serializable serializable = intent.getSerializableExtra("bean");
```

使用 Bundle 传递

```java
Intent intent = new Intent(MainActivity.this,TwoActivity.class);
Bundle bundle = new Bundle();
bundle.putString("data", str);
intent.putExtra("bundle", bundle);
startActivity(intent);

//TestActivity 获取数据
Intent intent = getIntent();
Bundle bundle = intent.getBundleExtra("bundle");
String str = bundle.getString("data");
```

### 反射跳转

通过反射获取 activity 可以做到跨 module 跳转，感觉没必要，用 Scheme 的方式就好。

```java
Class clz = Class.forName("com.kalaqiae.TestActivity");
startActivity(new Intent(this, clz));
```

### 其他

隐式跳转不用导入 activity 引用，所以可用于跨 module 跳转。腾讯推送用的是 Scheme 方式跳转。个人觉得 Scheme 比 action 好用一些，可以带参数，如果同时集成了极光和腾讯推送，用 Scheme 的方式跳转兼容两种推送点击消息跳转。
