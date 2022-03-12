---
title: "Android 原生分享"
date: 2022-03-12T16:47:58+08:00
draft: false
tags: ["Android","Share"]
categories: ["Android"]
---

### 核心代码

```java
Intent sharingIntent = new Intent(Intent.ACTION_SEND);
// "text/plain" 和 "text/html" 区别：html 类型 可以识别加粗等标签
// 当需要分享图文时可以使用 "image/*"
sharingIntent.setType("text/html");
sharingIntent.putExtra(android.content.Intent.EXTRA_TEXT, Html.fromHtml("<b>This is the text shared.</b>"));
startActivity(Intent.createChooser(sharingIntent, "Share using"));
```

<!--more-->

### 封装使用

比如分享链接到 Facebook

ResolveInfo 可以获取包名， icon 和 Label ,通过包名限制分享的应用。可以通过 label 进一步筛选分享到应用中的选项

```java
AppUtils.shareUrl(this, bean.share_link, null, "facebook")
```

分享图片流程：使用 Glide 把图片转为 Bitmap 再插入到相册中 最后转为 uri 来进行分享，如果想让插入的图片显示还需要发送广播，这里不需要

```java
public static void shareUrl(Context context, String content, Object img, String packageName) {
        boolean appFound = false;
        Intent sharingIntent = new Intent(Intent.ACTION_SEND);
        sharingIntent.putExtra(Intent.EXTRA_TEXT, content);
        sharingIntent.setType("text/plain");
        List<ResolveInfo> matches = context.getPackageManager().queryIntentActivities(sharingIntent, PackageManager.MATCH_DEFAULT_ONLY);
        for (ResolveInfo info : matches) {
            if (info.activityInfo.packageName.contains(packageName)) {
                sharingIntent.setPackage(info.activityInfo.packageName);
                appFound = true;
                break;
            }
        }
        if (!appFound) {
            ToastUtils.show(context.getString(R.string.app_not_found));
            return;
        }
        try {
            if (img == null) {
                context.startActivity(sharingIntent);
            } else {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    // glide 的 CustomTarget 回调中可以获取图片宽高
                    Glide.with(context).asBitmap()
                            .load(img).into(new CustomTarget<Bitmap>() {
                        @Override
                        public void onResourceReady(@NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {

                            ByteArrayOutputStream bytes = new ByteArrayOutputStream();
                            //0-100 100则没有压缩 压缩格式为 PNG 则无效，因为 PNG 是无损压缩
                            resource.compress(Bitmap.CompressFormat.JPEG, 100, bytes);
                            try {
                                bytes.close();
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                            String path = MediaStore.Images.Media.insertImage(context.getContentResolver(), resource, "Title", null);
                            Uri imageUri = Uri.parse(path);

                            sharingIntent.putExtra(Intent.EXTRA_STREAM, imageUri);
                            sharingIntent.setType("image/*");
                            context.startActivity(sharingIntent);
                        }

                        @Override
                        public void onLoadCleared(@Nullable Drawable placeholder) {

                        }
                    });
                }
            }
        } catch (Exception e) {
            ToastUtils.show(context.getString(R.string.app_not_found));
            Log.e("shareUrl", e.getMessage());
        }
    }
```

AndroidManifest 增加如下代码，兼容 Android 11 的隐私软件包可见性

```xml
<queries>
        <intent>
            <action android:name="android.intent.action.SEND" />
            <data android:mimeType="image/jpeg" />
        </intent>
    </queries>
    <!--如果要查全部应用，如根据包名查询是否安装应用加QUERY_ALL_PACKAGES权限-->
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />
```

参考
[官方文档](https://developer.android.com/training/sharing/send)
[多种分享类型参考](https://guides.codepath.com/android/Sharing-Content-with-Intents)
<https://www.jianshu.com/p/88f166dd43b7>
[压缩可以随便看看这个](https://juejin.cn/post/6844903950991228942)
