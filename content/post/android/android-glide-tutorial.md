---
title: "Android Glide Tutorial"
date: 2022-03-12T16:45:18+08:00
draft: false
tags: ["Android","Glide"]
categories: ["Android"]
---

### Glide 图片加载回调监听

* 可以使用 ImageViewTarget ， RequestListener 监听, RequestListener 可以监听网络图片是否加载成功。
* 可以使用 listener 或 addListener 添加 RequestListener 监听。当调用多个 listener 方法时，只会调用最后的 listener 回调， addListener 方法会依次调用多个 addListener 设置的回调。

<!--more-->

```java
Glide.with(mContext).load(source)
                .listener(new RequestListener<Drawable>() {
                    @Override
                    public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Drawable> target, boolean isFirstResource) {
                        return false;
                    }

                    @Override
                    public boolean onResourceReady(Drawable resource, Object model, Target<Drawable> target, DataSource dataSource, boolean isFirstResource) {
                        return false;
                    }
                })
                .into(new ImageViewTarget<Drawable>(target) {
                    @Override
                    public void onLoadStarted(@Nullable Drawable placeholder) {
                        super.onLoadStarted(placeholder);
                    }

                    @Override
                    public void onLoadFailed(@Nullable Drawable errorDrawable) {
                        super.onLoadFailed(errorDrawable);
                    }

                    @Override
                    public void onResourceReady(@NonNull Drawable resource, @Nullable Transition<? super Drawable> transition) {
                        super.onResourceReady(resource, transition);
                        target.setImageDrawable(resource);
                    }

                    @Override
                    protected void setResource(@Nullable Drawable resource) {
                    }
                });
```
