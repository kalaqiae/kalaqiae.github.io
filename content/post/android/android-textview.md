---
title: "Android Textview"
date: 2022-03-12T16:27:58+08:00
draft: false
tags: ["Android","Textview"]
categories: ["Android"]
---

### TextView ellipsize

配合 maxLines 使用，超出部分省略号表示，跑马灯等效果

marquee 使用跑马灯效果时记得设置 tvMarquee.setSelected(true);

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
