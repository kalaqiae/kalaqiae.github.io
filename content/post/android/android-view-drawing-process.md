---
title: "Android View Drawing Process"
date: 2025-04-15T23:38:38+08:00
draft: true
tags: ["Android","View"]
categories: ["Android"]
---

### View 的绘制流程

* 主要流程：Measure -> Layout -> Draw

* 入口 ViewRootImpl.performTraversals()， performTraversals() 方法内部依次调用 performMeasure(), performLayout(), performDraw()

* 整个流程简单描述：
  * View 的绘制流程分为三个核心步骤：measure、layout 和 draw，由 ViewRootImpl 的 performTraversals() 方法触发
  * 测量阶段：确定 View 的宽高，父 View 通过 measure() 调用子 View 的 onMeasure()，并传入 MeasureSpec （模式和尺寸），子 View 根据 MeasureSpec 计算自身大小，通过 setMeasuredDimension() 保存结果,如果子 View 是 ViewGroup，还需递归测量其所有子 View
  * 布局阶段：确定 View 的位置，父 View 通过 layout(l, t, r, b) 方法设置自身位置，并调用 onLayout() 方法，在 onLayout() 中，父 View 会遍历子 View，并通过调用每个子 View 的 layout(l, t, r, b) 方法，触发它们自身的 onLayout()，从而递归完成整个布局过程
  * 绘制阶段：将 View 绘制到屏幕。draw() 方法依次执行以下操作：绘制背景（drawBackground()）、调用 onDraw() 绘制自身内容、绘制子 View（dispatchDraw()）、绘制装饰（如滚动条）
<!--more-->

* 触发方式：
  * requestLayout()：触发完整流程（Measure → Layout → Draw），适用于尺寸或位置变化。
  * invalidate()：仅触发 Draw 流程，适用于内容变化（如文字/图片更新）
  * postInvalidate():非 UI 线程调用重绘
  
* Android 的视图树是 层级结构，最顶层是 DecorView（FrameLayout），它作为 ViewGroup 负责管理所有子 View 的绘制流程（即使自定义 View 不是 ViewGroup 类型，View 的绘制也涉及 ViewGroup）

#### Measure（测量）

目的：确定 View 的宽高

* 核心流程：ViewRootImpl.performMeasure(), View.measure(), View.onMeasure()

* ViewGroup(从根 View 到子 View 进行递归测量)
  * onMeasure()，定自身的尺寸，并为子 View 创建合适的 MeasureSpec
  * measureChildren()，遍历测量所有子 View
  
* View（计算自身宽高）
  * onMeasure()（必须调用 setMeasuredDimension() 保存结果，否则会抛异常）
  * 自定义 View 需处理 wrap_content 场景（否则默认行为与 match_parent 相同）

* 父 View 通过 MeasureSpec（包含模式和尺寸）向子 View 传递测量约束，MeasureSpec 由父 View 的布局规则和子 View 自身的 LayoutParams 共同决定，MeasureSpec 有三种模式
  * EXACTLY: 精确值:父 View 已经确定了子 View 的精确尺寸,如 match_parent 或具体数值
  * AT_MOST: 最大尺寸:父 View 为子 View 指定了一个最大尺寸（如当子 View 的 LayoutParams 设置为 wrap_content 时）。子 View 的实际尺寸不能超过这个最大值，但可以比它小
  * UNSPECIFIED: 未指定:父 View 不对子 View 的尺寸施加任何限制,ScrollView 中常见）

```java
//MeasureSpec 同时包含模式和尺寸两部分信息，表现形式是一个32位整数,通过 位操作 将模式和尺寸合并为一个 int
// View.java
public final void measure(int widthMeasureSpec, int heightMeasureSpec) {
    ...
    onMeasure(widthMeasureSpec, heightMeasureSpec); // 调用子类实现的测量逻辑
    ...
}
// TextView.java
protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
    int width = calculateWidth(widthMeasureSpec);  // 根据MeasureSpec计算宽度
    int height = calculateHeight(heightMeasureSpec); // 计算高度
    setMeasuredDimension(width, height); // 必须调用！保存测量结果
}

// FrameLayout.java
@Override
protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
    int count = getChildCount();
    
    // 测量所有子View
    for (int i = 0; i < count; i++) {
        final View child = getChildAt(i);
        if (mMeasureAllChildren || child.getVisibility() != GONE) {
            // 递归测量子View
            measureChildWithMargins(child, widthMeasureSpec, 0,
                    heightMeasureSpec, 0);
            // ...
        }
    }
    
    // 根据子View测量结果确定自身大小
    // ...
    setMeasuredDimension(resolveSizeAndState(maxWidth, widthMeasureSpec, childState),
            resolveSizeAndState(maxHeight, heightMeasureSpec,
                    childState << MEASURED_HEIGHT_STATE_SHIFT));
}

// ViewGroup.java
protected void measureChildWithMargins(View child,
        int parentWidthMeasureSpec, int parentHeightMeasureSpec,
        int widthUsed, int heightUsed) {
    
    final MarginLayoutParams lp = (MarginLayoutParams) child.getLayoutParams();
    
    // 计算子View的MeasureSpec
    final int childWidthMeasureSpec = getChildMeasureSpec(parentWidthMeasureSpec,
            mPaddingLeft + mPaddingRight + lp.leftMargin + lp.rightMargin
                    + widthUsed, lp.width);
    final int childHeightMeasureSpec = getChildMeasureSpec(parentHeightMeasureSpec,
            mPaddingTop + mPaddingBottom + lp.topMargin + lp.bottomMargin
                    + heightUsed, lp.height);
    
    // 调用子View的measure方法
    child.measure(childWidthMeasureSpec, childHeightMeasureSpec);
}
```

#### Layout（布局）

目的：确定 View 及其子 View 在父容器中的位置（通过 left, top, right, bottom 定位）

* 核心流程：ViewRootImpl.performLayout(), View.layout(), onLayout()

* ViewGroup(如果有从根 View 到子 View 进行递归确认位置)
  * onLayout()（必须重写，会在 onLayout() 里调用子 View 的 layout(l, t, r, b) 确定位置）

* View
  * onLayout()（通常为空实现，因为 View 无子 View，ViewGroup 需实现布局逻辑）

```java
// View.java
public void layout(int l, int t, int r, int b) {
    // 1. 比较新旧位置是否变化
    if (l != mLeft || r != mRight || t != mTop || b != mBottom) {
        // 2. 更新位置（mLeft/mRight/mTop/mBottom）
        setFrame(l, t, r, b); 
        // 3. 触发布局回调
        onLayout(changed, l, t, r, b); 
    }
}

// FrameLayout.java
@Override
protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
    for (int i = 0; i < getChildCount(); i++) {
        View child = getChildAt(i);
        if (child.getVisibility() != GONE) {
            // 计算子View的位置（考虑gravity、padding等）
            child.layout(childLeft, childTop, 
                        childLeft + child.getMeasuredWidth(), 
                        childTop + child.getMeasuredHeight());
        }
    }
}
```

#### Draw（绘制）

目的：将 View 显示到屏幕

* 核心流程：ViewRootImpl.performDraw(), View.draw(), onDraw()

* ViewGroup（先绘制自己，再绘制子 View）
  * dispatchDraw()：默认遍历调用子 View 的 draw() 方法
  * 默认已实现 dispatchDraw()，无需重写（除非需要控制子 View 绘制顺序）
  * 若自定义 ViewGroup 有自身内容，需同时重写 onDraw() 和 dispatchDraw()

* View（绘制自身内容（如背景、文字））
  * onDraw()
  
* 绘制顺序
  * 绘制背景（drawBackground()）
  * 绘制内容（onDraw()）
  * 绘制子 View（dispatchDraw()，ViewGroup 中实现）
  * 绘制装饰（如滑动条）

```java
// View.java
public void draw(Canvas canvas) {
    // 1. 绘制背景（可跳过，若背景为null）
    drawBackground(canvas);
    
    // 2. 绘制自身内容（onDraw()）
    onDraw(canvas);
    
    // 3. 绘制子View（dispatchDraw()）
    dispatchDraw(canvas);
    
    // 4. 绘制装饰（滚动条、前景等）
    onDrawForeground(canvas);
}

// ViewGroup.java
@Override
protected void dispatchDraw(Canvas canvas) {
    for (int i = 0; i < getChildCount(); i++) {
        View child = getChildAt(i);
        if (child.getVisibility() != GONE) {
            // 递归绘制子View
            drawChild(canvas, child, drawingTime);
        }
    }
}
```

#### 优化

* onDraw() 避免创建对象（如 Paint、Path 等）
* 避免过度绘制
* 硬件加速
