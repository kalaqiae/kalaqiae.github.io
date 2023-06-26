---
title: "Ubuntu Note"
date: 2023-06-26T22:09:47+08:00
draft: true
tags: ["Linux","Ubuntu","note"]
categories: ["Linux"]
---

[Linux命令大全(手册)](https://www.linuxcool.com/)

<!--more-->

我装的是 Ubuntu 18.0.4 ，版本不同有地方可以不一样

### other

软件一般装在 /opt

快捷方式一般在 /usr/share/applications

查看当前路径大小 df -h .

切换输入法win + 空格 

打开 terminal alt+ctrl+t 

修改环境变量后 source ~/.bashrc

查看环境变量 echo $PATH

编辑文本可以用 nano gedit 

### ubuntu安装 Android studio

```shell script
~/Downloads$ sudo tar -zxvf android-studio-2022.2.1.20-linux.tar.gz -C /opt //下载后解压到 opt 下 
android-studio/bin/studio.sh //执行 studio.sh
sudo gedit /usr/share/applications/android-studio.desktop //创建快捷方式 
```

```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=Android Studio
Exec="/opt/android-studio/bin/studio.sh" %f
Icon=/opt/android-studio/bin/studio.png
Categories=Development;IDE;
Terminal=false
StartupNotify=true
StartupWMClass=android-studio
```


### kvm

运行android模拟器需要

```shell script
egrep -c '(vmx|svm)' /proc/cpuinfo
sudo apt install  qemu-kvm virt-manager libvirt-daemon-system virtinst libvirt-clients bridge-utils
sudo adduser $USER libvirt
sudo adduser $USER kvm
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
lsmod | grep kvm
virt-manager
```

### ubuntu AOSP

[Android AOSP](https://source.android.com/docs/setup/start?hl=zh-cn)

我选了 Android10 ，下载估计1小时，编译了快3小时，总的用了4小时

### ubuntu 修改分区大小 gparted

只能调整一个分区的前后