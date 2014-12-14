---
layout: post
title: "Mount options"
description: ""
category: cheatsheet
tags: linux
---
{% include JB/setup %}


## 一个困扰了很久的毛病

一直以来usb存储插在我的笔记本上时，写设备的速度低到不行。但是鉴于用usb传数据的需求有限，
一直没有管它。直到最近我才发现是因为使用udisks-glue时配置了不妥的mount option导致的。
udisks-glue是一个用于自定义一些设备事件发生时的响应操作的工具（比如，自动mount，发送notification），
如果使用的是gnome这样的桌面环境，是不需要这种工具的，gnome本身就能妥善处理自动挂载这样简单的操作。
通过 `gsettings list-recursively |grep mount` 这条指令就能查看到gnome下关于设备自动挂载的设置。
我使用这个工具的主要原因是为了配合awesome的blingbling库中的widget，当设备状态发生改变时，自动挂载，发送通知，
并且通过awesome-client与widget进行通信，达到通过widget来显示设备状态等效果。


话说回来，问题在于我在一般usb disk的挂载选项中添加了sync，这组选项包括sync,async,flush，区别在于:

* 如果使用了sync，所有写操作立即发生在移动磁盘，这样将减少设备的寿命，是个非常不好的选择
* async就是sync的反面，系统将些操作进行buffer，并对真实的写操作进行了优化，默认选项
* flush是专门真对(V)FAT文件系统的挂载选项，是一种介于sync和async之间的选项，系统在每次设备驱动变为空闲的时候执行真实的写操作，但是写操作的顺序可能被打乱

顺便一提，如果执行mount指令的时候不加任何参数，将显示当前的所有挂载项，以及其对应选项，效果等同与`cat /proc/mounts`。

## 测试设备的读写速度

可以通过dd指令测试设备的读写速度(没有找到更好的方法)。

* 测试写速度 `dd if=/dev/urandom of=./testfile bs=8k count=10000`, 感觉随机比较准确 `/dev/zero` 的话快的太假了...
* 测试读速度 `sudo sh -c "sync && echo 3 > /proc/sys/vm/drop_caches"` 清除cache，然后 `dd if=./testfile of=/dev/null bs=8k`
* 测试读速度也可以采用hdparm

经过测试，我的设备在三种不同挂载选项下对应的写速度如下:

* sync : 250KB/s
* flush : 7.8MB/s
* async : 17.7MB/s

可见差别非常明显。

## 其它挂载选项

简单记录，手册页中有更详细描述。
`/etc/fstab` 或者 `mount -o` 支持如下选项:

* auto/noauto 控制是否自动在启动时挂载
* dev/nodev 如果是nodev，则不允许通过 /dev/ 目录下的文件来访问
* exec/noexec exec表示允许执行该文件系统上的文件
* rw/ro 读写或者只读
* suid/nosuid uid和sgid位是否有效，安全性考虑
* user/users/nouser user意味着某个普通用户都能挂载，nouser意味着只有root能够挂载，users所有用户
* owner 指定所有者，同时意味着nosuid, nodev
* atime/noatime/nodiratime/relatime 关于如何更新文件inode中的atime(access time)信息，默认为relatime，只在修改文件时更新。
* defaults 默认选项如下 rw,suid,dev,exec,auto,nouser,async
