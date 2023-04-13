---
title: "Android Localization"
date: 2022-08-25T10:22:00+08:00
draft: false
tags: ["Android","Localization"]
categories: ["Android"]
---

### 切换语言

获取 string.xml 里的字段时，可以用下面的 getAttachBaseContext 获取对应语言的 context  
集成 tinker 热更适配要拿到对的上下文

<!--more-->

```kotlin

    /**
     * 在 BaseActivity 里 attachBaseContext 使用
     * 设置语言后跳转到启动模式 singleTask 的页面
     * 并设置 intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK 就能做到应用内切换
     */
    override fun attachBaseContext(newBase: Context?) {
        //注意 androidx 语言失效问题 这么写有问题
        //super.attachBaseContext(newBase?.let { AppUtilsKtx.getAttachBaseContext(it) })
        val context = AppUtilsKtx.getAttachBaseContext(newBase)
        val configuration = context.resources.configuration
        // 此处的ContextThemeWrapper是androidx.appcompat.view包下的
        // 你也可以使用android.view.ContextThemeWrapper，但是使用该对象最低只兼容到API 17
        // 所以使用 androidx.appcompat.view.ContextThemeWrapper省心
        val wrappedContext = object : ContextThemeWrapper(context, R.style.Theme_AppCompat_Empty) {
            override fun applyOverrideConfiguration(overrideConfiguration: Configuration?) {
                if (overrideConfiguration != null) {
                    overrideConfiguration.setTo(configuration)
                }
                super.applyOverrideConfiguration(overrideConfiguration)
            }
        }
        super.attachBaseContext(wrappedContext)
    }

    class AppUtilsKtx {

        companion object {

            /**
             * 代码中注意有些地方需要用这个 Context 比如在自定义 View 的构造函数或者使用 app 的 Context 获取 string 资源时
             */
            fun getAttachBaseContext(context: Context): Context {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    return setAppLanguageApi24(context)
                } else {
                    setAppLanguage(context)
                }
                return context
            }

            /**
             * 设置应用语言
             */
            @Suppress("DEPRECATION")
            fun setAppLanguage(context: Context) {
                val resources = context.resources
                val displayMetrics = resources.displayMetrics
                val configuration = resources.configuration
                // 获取当前语言，默认设置跟随系统
                val locale = getAppLocale()
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                    configuration.setLocale(locale);
                } else {
                    configuration.locale = locale;
                }
                resources.updateConfiguration(configuration, displayMetrics)
            }

            /**
             * 兼容 7.0 及以上
             */
            @TargetApi(Build.VERSION_CODES.N)
            private fun setAppLanguageApi24(context: Context): Context {
                val locale = getAppLocale()
                val resource = context.resources
                val configuration = resource.configuration
                configuration.setLocale(locale)
                configuration.setLocales(LocaleList(locale))
                return context.createConfigurationContext(configuration)
            }

            /**
             * 获取 App 当前语言
             */
            private fun getAppLocale() =
                when (MMKV.defaultMMKV().decodeString(CHOOSE_LANGUAGE, "")) {
                    "" -> {
                        getSystemLocale()
                    }
                    Locale.ENGLISH.language -> {
                        Locale.ENGLISH
                    }
                    Locale.CHINA.language -> {
                        Locale.CHINA
                    }
                    //很多语言在 Locale 中没有变量，可以直接用字符串
                    "ar" -> {
                        Locale("ar")
                    }
                    else -> Locale.ENGLISH
                }

            /**
             * 获取当前语言，如未包含则默认英文
             */
            private fun getSystemLocale(): Locale {
                val systemLocale = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    LocaleList.getDefault()[0]
                } else {
                    Locale.getDefault()
                }
                return when (systemLocale.language) {
                    Locale.ENGLISH.language -> {
                        Locale.ENGLISH
                    }
                    Locale.CHINA.language -> {
                        Locale.CHINA
                    }
                    Locale("ar").language -> {
                        Locale("ar")
                    }
                    else -> {
                        Locale.ENGLISH
                    }
                }
            }

            fun isAr(): Boolean {
                return LANGUAGE_ARABIA == MMKV.defaultMMKV().decodeString(CHOOSE_LANGUAGE, "")
            }
        }
    }
```

### string

strings.xml 中，点击右上角的 Open editor 可以总览编辑，点击左上角地球图标添加新语言，还可以筛选未翻译  
中文（中国）：values-zh-rCN 中文（台湾）：values-zh-rTW , zh 代表语言 rCN 代表地区

```xml
//设置不可翻译
<string name="app_name" translatable="false">AppName</string>
```

### RTL

Android 4.1.1（API 级别 16）不支持 android:supportsRtl="true" , start 和 end  
右键项目选择 Refactor > Add Right to Left Support  
如果 targetSdkVersion 为 17 或更高选中 Replace Left/Right Properties with Start/End  
如果 targetSdkVersion 为 16 或更低，选中 Generate -v17 Versions 复选框  

可以添加 layout-ldrtl((layout-direction-right-to-left) ) drawable-ldrtl-xxhdpi 来放对应资源

ViewPager 不支持 RTL ViewPager2 支持

除了布局文件,代码中还需注意 Gravity.LEFT , leftMargin , setMargins() , setPadding()。 setPaddingRelative() 对比 setPadding() 支持 start/end

Android 4.4（API 版本 19）支持使用 android:autoMirrored="true"

判断是否 rtl

```kotlin
        fun isRtl(): Boolean {
            return TextUtils.getLayoutDirectionFromLocale(Locale.getDefault()) == View.LAYOUT_DIRECTION_RTL
        }
        或
        fun shouldUseLayoutRtl(view: View): Boolean {
            return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                View.LAYOUT_DIRECTION_RTL == view.layoutDirection
            } else {
                false
            }
        }
```

在 layout.xml 中点击地球图标，选中 ar 布局也会镜像

RelativeLayout 中的子 View 使用 android:layout_centerInParent="true" 导致看不见子 View
因为父 View 使用了 wrap_content 没有确定大小，要么指定大小，要么在父 View 中使用 android:layoutDirection="ltr"

TextView 设置 android:inputType="textPassword" 时对齐有问题，需要设置 android:textAlignment="viewStart"

开发者选项中可以启用强制使用从右到左的布局方向

### TextView 和 EditView 全局设置 style

为了适配 Rtl 可以全局设置属性

```xml

    <style name="AppBaseTheme" parent="Theme.AppCompat.Light.NoActionBar">
        ···
        <item name="editTextStyle">@style/EditTextStyle.Alignment</item>
        <item name="android:textViewStyle">@style/TextViewStyle.TextDirection</item>
    </style>

    <style name="EditTextStyle.Alignment" parent="@android:style/Widget.EditText">
        <item name="android:textAlignment">viewStart</item>
        <item name="android:textDirection">locale</item>
    </style>

    <style name="TextViewStyle.TextDirection" parent="android:Widget.TextView">
        <item name="android:textDirection">locale</item>
        <item name="android:textAlignment">viewStart</item>
    </style>
```

自定义 View 的 style 不生效时，可能需要用到 ContextThemeWrapper
[设置view的style](https://juejin.cn/post/7021821759078793247)

```java
//在构造函数中使用 ContextThemeWrapper
public class StrokeTextView extends AppCompatTextView {
    private Float strokeWidth = 0.5F;

    public StrokeTextView(Context context) {
        this(new ContextThemeWrapper(context,R.style.TextViewStyle_TextDirection), null);
    }

    public StrokeTextView(Context context, AttributeSet attrs) {
        this(new ContextThemeWrapper(context,R.style.TextViewStyle_TextDirection), attrs, 0);
    }

    public StrokeTextView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(new ContextThemeWrapper(context,R.style.TextViewStyle_TextDirection), attrs, defStyleAttr);
        TypedArray arr = context.obtainStyledAttributes(attrs, R.styleable.StrokeTextView, defStyleAttr, R.style.TextViewStyle_TextDirection);
        strokeWidth = arr.getFloat(R.styleable.StrokeTextView_text_stroke_width, strokeWidth);
        arr.recycle();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        Paint paint = getPaint();
        paint.setStrokeWidth(strokeWidth);
        paint.setStyle(Paint.Style.FILL_AND_STROKE);
        super.onDraw(canvas);
    }
}
```

### other

[问题注意](https://www.jianshu.com/p/cd9a8ae37d82)

[多语言切换在Androidx失效](https://juejin.cn/post/6915751118416904199)

[时间格式问题](https://www.jianshu.com/p/df86ed66be11)

[使用 Translations Editor 本地化界面](https://developer.android.com/studio/write/translations-editor?utm_source=android-studio#resources)

[支持不同的语言和文化](https://developer.android.com/training/basics/supporting-devices/languages)

以前 ViewPager 在预加载时 Fragment 的生命周期就会走到 onResume , 现在做懒加载数据只要在 onResume 里做就可以了

RecyclerView 使用 GridLayoutManager 时适配 rtl ,写个继承 GridLayoutManager 的类，并重写 isLayoutRTL ，或者直接如下

```java
GridLayoutManager lm = new GridLayoutManager(this, 2) {
    @Override
    protected boolean isLayoutRTL() {
        return true;
    }
};
```

图片 rtl 反转通过 android:autoMirrored="true" 或者 drawable-ldrtl 资源或者设置 scaleX 或 rotationY 然后通过加载不同的 integer 来反转

```xml
android:scaleX="-1"

android:rotationY="@integer/rotation"
<integer name="rotation">0</integer>
<integer name="rotation">180</integer>
```
