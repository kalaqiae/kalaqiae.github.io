---
title: "Android Textview"
date: 2022-03-12T16:27:58+08:00
draft: false
tags: ["Android","Textview"]
categories: ["Android"]
---

### TextView ellipsize

配合 maxLines 使用，超出部分省略号表示，跑马灯等效果

marquee 使用跑马灯效果时记得设置 tvMarquee.setSelected(true); 需要注意不要抢了其他控件的焦点

marqueeRepeatLimit 限制滚动次数可以设置 marquee_forever 或 1

<!--more-->

Combining ellipsize=marquee and maxLines=1 can lead to crashes. Use singleLine=true instead

Combining ellipsize and maxLines=1 can lead to crashes on some devices. Earlier versions of lint recommended replacing singleLine=true with maxLines=1 but that should not be done when using ellipsize.

译：将 ellipsize和maxLines = 1组合在一起会导致某些设备崩溃。 早期版本的lint建议用maxLines = 1替换singleLine = true，但在使用ellipsize时不应该这样做。

### TextView maxEms

em 是一个印刷排版的单位，表示字宽的单位。 em 字面意思为：equal M（和 M 字符一致的宽度为一个单位）简称 em。ems 是 em 的复数表达。

使用 ellipsize 时，想要限制宽度不能用 maxLength 用 maxEms

### TextView setMargins

```java
    //得到父容器的 LayoutParams 如果xml中没有该控件就要 new 的方式， RelativeLayout 是父容器类型，也可能是其他类型
    RelativeLayout.LayoutParams layoutParams = (RelativeLayout.LayoutParams) child.getLayoutParams();
    RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
    //设置的值是 px ，有需要可以 dp 转 px
    layoutParams.setMargins(DisplayUtils.dp2px(mContext, 15), 0, 0, 0);
    child.setLayoutParams(layoutParams);
```

使用 MarginLayoutParams 设置

```java
    private void setMargins(View child, int left, int top, int right, int bottom) {
        ViewGroup.LayoutParams params = child.getLayoutParams();
        ViewGroup.MarginLayoutParams marginParams;
        if (params instanceof ViewGroup.MarginLayoutParams) {
            marginParams = (ViewGroup.MarginLayoutParams) params;
        } else {
            marginParams = new ViewGroup.MarginLayoutParams(params);
        }
        marginParams.setMargins(0, 0, 0, 0);
        child.setLayoutParams(marginParams);
    }
```

### TextView Drawables

可以用 setCompoundDrawables 或 setCompoundDrawablesWithIntrinsicBounds

setCompoundDrawables 画的 drawable 的宽高是按 drawable.setBound() 设置的宽高，所以必须先设置 drawable 的宽高，在调用该方法，才会显示

setCompoundDrawablesWithIntrinsicBounds 是画的 drawable 的宽高是按 drawable 固定的宽高，即：用 getIntrinsicWidth() 与 getIntrinsicHeight() 获得

```java
    Drawable drawable = ContextCompat.getDrawable(context, R.drawable.***);
    textview.setCompoundDrawablesWithIntrinsicBounds(null, drawable, null, null);
```

```java
    Drawable drawable = ContextCompat.getDrawable(context, R.drawable.***);
    rightDrawable.setBounds(0, 0, drawable.getMinimumWidth(), drawable.getMinimumHeight());
    textview.setCompoundDrawables(null, null, drawable, null);
```

### TextView Html 标签

可以修改个别文字样式

```java
Spanned message = null;
if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
    message = Html.fromHtml(getString(R.string.cdata_text),Html.FROM_HTML_MODE_LEGACY);
}else {
    message = Html.fromHtml(getString(R.string.cdata_text));
}
text.setText(message);
//设置 a 标签点击跳转
text.setMovementMethod(LinkMovementMethod.getInstance());
```

在 string.xml 用 <![CDATA[]]> 或者直接转义 Html 标签

```xml
<string name="cdata_text"><![CDATA[1.<a href="https://kalaqiae.com/">kalaqiae<a><br/>2.<b>bold</b> 3.<font color = "#FF0000">color text</font>]]></string>
```

如果要获取到 a 标签的点击事件（比如想自定义跳转页面） textview 需要设置  android:autoLink="web" 然后用另外写事件

### 阴影

android:shadowColor 阴影颜色 android:shadowDx 阴影的水平偏移量 android:shadowDy 阴影的垂直偏移量 android:shadowRadius 阴影的范围

```xml
<TextView
android:layout_width="wrap_content"
android:layout_height="wrap_content"
android:layout_marginTop="30dp"
android:shadowColor="#FF000000"
android:shadowDx="5"
android:shadowDy="5"
android:shadowRadius="3"
android:text="阴影效果"
android:textColor="#FFF"
android:textSize="30sp" />

<TextView
android:layout_width="wrap_content"
android:layout_height="wrap_content"
android:layout_marginTop="30dp"
android:shadowColor="#CCCCCC"
android:shadowDx="0.5"
android:shadowDy="0.5"
android:shadowRadius="2"
android:text="浮雕效果"
android:textColor="#FF000000"
android:textSize="30sp" />
```

### 行间距

<!-- https://blog.csdn.net/ccpat/article/details/45507751 -->
android:lineSpacingExtra 设置行间距 android:lineSpacingMultiplier 设置行间距的倍数

```xml
<TextView
android:layout_width="wrap_content"
android:layout_height="wrap_content"
android:includeFontPadding="false"
android:lineSpacingMultiplier="1.2"
android:lineSpacingExtra="4dp" />
```
