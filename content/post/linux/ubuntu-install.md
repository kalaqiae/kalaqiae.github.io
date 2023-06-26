---
title: "Ubuntu install"
date: 2023-06-07T16:31:59+08:00
draft: true
tags: ["Linux","Ubuntu"]
categories: ["Linux"]
---

Linux Window 双系统安装记录。安装的 Linux 为 Ubuntu 18.0.4。也可以用 Vmware 虚拟机装 Linux。

<!--more-->

安装双系统注意！！！很多文档比较旧，使用了传统 BIOS ，和 UEFI 启动方式区别不少

[双系统教程](https://blog.csdn.net/NeoZng/article/details/122779035)

### Linux 启动盘制作

可以用 Rufus Etcher UNetbootin 等来制作启动盘。  
这里用了 [Rufus](https://rufus.ie/zh/) Rufus 可以创建 Windows 和 Linux 启动盘，需要下载 iso 文件

以下是 Rufus 制作启动盘的界面，选择了设备，iso文件，分区类型，点击开始，完成后要自己关闭窗口  
![Rufus](https://cdn.jsdelivr.net/gh/kalaqiae/picBank/img/linux_ubuntu_install_rufus.png)

#### Rufus 分区类型说明

MBR（Master Boot Record）：MBR 是传统的分区方案，适用于 BIOS 系统和旧版本的 Windows 操作系统。它使用32位分区标识符（Partition ID）来标识主分区、扩展分区或逻辑分区。

GPT（GUID Partition Table）：GPT 是现代计算机系统使用的分区方案，适用于 UEFI 系统和最新的 Windows 操作系统。它使用全球唯一标识符（GUID）来标识分区，并支持更大的磁盘容量和更多的分区。

#### Rufus 目标系统类型说明

BIOS 系统上安装 Windows 7 或更早版本的操作系统，则必须使用 MBR 分区类型

UEFI 系统上安装 Windows 8 或更高版本的操作系统，则必须使用 GPT 分区类型

#### 查看启动方式是 BIOS 还是 UEFI

命令行输入 msinfo32 看 BIOS 模式 UEFI 则为 UEFI 启动方式

### 安装 Ubuntu

修改启动方式为制作好的 linux 启动盘优先启动，关闭 bitlocker fast boot 等，我的电脑只修改了启动顺序就好了，其他电脑不知道

注意！！！很多文档比较旧，使用了传统 BIOS，和 UEFI 启动方式区别不少

具体安装过程中的选项可以看后面的图。我选了 English，正常安装，安装 ubuntu 时下载更新可以不勾选，检测到已经装了 Windows 要选安装类型，选其他可以自己分区，联网的选项不建议连，安装后更换软件源安装会快点

选择语言
![linux_ubuntu_install_step1](https://cdn.jsdelivr.net/gh/kalaqiae/picBank/img/linux_ubuntu_install_step1.png)
选择键盘
![linux_ubuntu_install_step2](https://cdn.jsdelivr.net/gh/kalaqiae/picBank/img/linux_ubuntu_install_step2.png)
我选了正常安装，要选最小安装也行
![linux_ubuntu_install_step3](https://cdn.jsdelivr.net/gh/kalaqiae/picBank/img/linux_ubuntu_install_step3.png)
检测到已经装了 Windows 要选安装类型，选其他可以自己分区
![linux_ubuntu_install_step4](https://cdn.jsdelivr.net/gh/kalaqiae/picBank/img/linux_ubuntu_install_step4.png)
找到要安装的那个硬盘，点加号开始分区
![linux_ubuntu_install_step5](https://cdn.jsdelivr.net/gh/kalaqiae/picBank/img/linux_ubuntu_install_step5.png)
这里很重要，启动引导分区，选择 EFI System Partition ，分完后 Device for boot loader installation 记得选这个
![linux_ubuntu_install_step6](https://cdn.jsdelivr.net/gh/kalaqiae/picBank/img/linux_ubuntu_install_step6.png)
根分区 下拉框选择 / 注意是 Ext4文件系统
![linux_ubuntu_install_step7](https://cdn.jsdelivr.net/gh/kalaqiae/picBank/img/linux_ubuntu_install_step7.png)
交换分区 下拉框选择 swap area
![linux_ubuntu_install_step8](https://cdn.jsdelivr.net/gh/kalaqiae/picBank/img/linux_ubuntu_install_step8.png)
home 分区 Ext4文件系统
![linux_ubuntu_install_step9](https://cdn.jsdelivr.net/gh/kalaqiae/picBank/img/linux_ubuntu_install_step9.png)
最后是这样
![linux_ubuntu_install_step10](https://cdn.jsdelivr.net/gh/kalaqiae/picBank/img/linux_ubuntu_install_step10.png)
这里可以选择自动登录
![linux_ubuntu_install_step11](https://cdn.jsdelivr.net/gh/kalaqiae/picBank/img/linux_ubuntu_install_step11.png)

### 分区说明

重要的事情说三遍 注意！！！很多文档比较旧，使用了传统 BIOS，和 UEFI 启动方式区别不少

* 使用 UEFI 启动方式的双系统需要一个 EFI 分区，不需要 /boot 分区。SWAP 大于4g也可以是主分区。
* UEFI 不分主分区和逻辑分区，UBUNTU 安装时为了兼容 BIOS 所以还有这个选项
使用传统 BIOS 引导方式的双系统需要一个独立的 /boot 分区。SWAP 大于4g，只设置成逻辑分区。主分区只能有4个

SWAP 分区，一般是1到2倍内存的大小，如果内存够大也还是建议设置以下

我的硬盘1t，内存16g，方案（按顺序）是 EFI 系统分区1g，根分区500g，swap 分区32g，home 分区420g

#### 分区不同的原因

由于分区表的结构所决定。在传统的MBR（Master Boot Record）分区表中，每个主分区都需要占用16字节的空间，其中包括分区起始地址、分区大小等信息。而MBR分区表的最后两个字节则用于存储分区表的校验和。

因为MBR分区表最多只能存储64个字节，所以最多只能有4个主分区或3个主分区和1个扩展分区。如果想要创建更多的分区，则需要使用扩展分区来划分出若干个逻辑分区。但是，由于MBR分区表的限制，逻辑分区的数量也会受到限制。

对于UEFI固件，它所使用的GPT（GUID Partition Table）分区表可以支持更多的分区类型和更大的分区容量，并且不再受到像MBR分区表那样的64字节限制。因此，在使用GPT分区表时，可以创建更多的分区。

### 问题

* 开始安装黑屏问题：开始安装，点击 install ubuntu 随后出现黑屏问题，这是因为 Linux 对显卡的支持问题，安装完 Linux 后可以选择安装相关显卡驱动
解决：其他显卡没有试过不记录， Nvidia 的显卡，为安装时选择 install ubuntu，按 e 修改 quiet splash --- 为 quiet splash nomodeset
* 安装完成后进入系统黑屏问题：选择 Advanced options for Ubuntu -> recovery mode -> resume，
进入系统后，命令行输入 sudo nano /etc/default/grub ，修改 GRUB_CMDLINE_LINUX_DEFAULT="quiet splash" 为
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nomodeset" 保存后，sudo update-grub
* 网上有人说要先分逻辑分区再分主分区，不过我没遇到这个问题

安装完修改启动顺序，和修改使用u盘启动类似，需要找到改一下

用独立的一个硬盘装会比较好
