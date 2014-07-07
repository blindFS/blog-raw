---
layout: post
title: "Basic usage of ioctl in a linux kernel module"
description: ""
category: notes
tags: ツッコミ linux kernel
---
{% include JB/setup %}

## 不求甚解

虽然对代码的格式和规范有一定的强迫症，但我认为自己还是属于实用主义者。
现实告诉我一个任务需要用到 ioctl，作为一个 newbie，对此一无所知。
看了网络上大段落的讨论，始终还是不得要领。
搞定之后回头看，觉得自己毕竟图样，有的时候看内核代码比看manpage或者是教程
要靠谱。不管怎样，我就是简单记录下使用这个函数的步骤和要点，至于原理嘛，能吃么？
说明: 以下步骤针对 char device，相关定义在 `<linux/cdev.h>` 查找

## ioctl()

### 用户态函数

用户空间的ioctl函数要做的是将指令--cmd传递给fd对应的内核模块，nothing else.
通过传递过去的指针参数，获得内核模块所返回的信息来完成调用。

* 头文件用 `<stropts.h>` 或者 `<sys/ioctl.h>`
* 定义如下 `int ioctl(int fd, int cmd, .../* arg */)`
    1. fd 就是打开的 file description 实例，通常通过 `open("/dev/dev_filename", permission)` 获得
    2. cmd 是一个32bit的指令，包含了 驱动设备类型，指令号，io方向，数据尺寸 四个部分的内容，
    具体怎么排列的我不关心... cmd的生成方式后文会有介绍
    3. arg 通常为一个指针变量，用来在内核态与用户态之间进行数据拷贝

### 内核态 file operation

1. 内核模块中需要创建一个函数，如 `long ioctl_func(struct file *f, unsigned int cmd, unsigned long arg)`
2. 需要创建一个 file_operations 实例，将实例中的 unblocked_ioctl 成员赋值为之前定义的函数
3. 创建 "/dev/dev_filename" 目录项

### Macros to create cmd

内核提供了一系列的宏来辅助生成那32bit的ioctl指令：

{% highlight c %}
#define _IOC_NRBITS 8
#define _IOC_TYPEBITS   8
#define _IOC_SIZEBITS   13
#define _IOC_DIRBITS    3
#define _IOC(dir,type,nr,size)          \
    ((unsigned int)             \
     (((dir)  << _IOC_DIRSHIFT) |       \
      ((type) << _IOC_TYPESHIFT) |      \
      ((nr)   << _IOC_NRSHIFT) |        \
      ((size) << _IOC_SIZESHIFT)))

#define _IO(type,nr)        _IOC(_IOC_NONE,(type),(nr),0)
#define _IOR(type,nr,size)  _IOC(_IOC_READ,(type),(nr),sizeof(size))
#define _IOW(type,nr,size)  _IOC(_IOC_WRITE,(type),(nr),sizeof(size))
#define _IOWR(type,nr,size) _IOC(_IOC_READ|_IOC_WRITE,(type),(nr),sizeof(size))
{% endhighlight %}

io反向什么的一眼就懂，剩下的移位操作具体怎么移我不关心，反正重要的就是三个辅助参数:

1. type为一个8bit的char，作为不同device之间的区分
2. nr则是同一个type下的不同指令的序号，同样占用8bit
3. size 很容易看出来就是类型标识，代表了这个io指令传递的arg的大小。最简单的用法:

{% highlight c %}
#define MY_TYPE 't'
#define MY_COMMAND_0 _IOW(MY_TYPE, 0, int)
#define MY_COMMAND_1 _IOR(MY_TYPE, 1, int)
{% endhighlight %}

### Template code for cdev

模板代码中包含了基本的目录项的创建与回收，具体机制我没啥兴趣，char device 反正是按照这个套路来，其它的
用到了再说...

{% highlight c %}
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/errno.h>
#include <linux/cdev.h>
#include <linux/device.h>

#define FIRST_MINOR 0
#define MINOR_CNT 1

static dev_t dev;
static struct cdev c_dev;
static struct class *cl;

static int my_open(struct inode *i, struct file *f) {
    return 0;
}

static int my_close(struct inode *i, struct file *f) {
    return 0;
}

static long my_ioctl(struct file *f, unsigned int cmd, unsigned long arg) {

    ...

    switch (cmd) {
        case COMMAND1:
            ...
            break;
        default:
            return -EINVAL;
    }

    ...

    return 0;
}

static struct file_operations my_ops = {
    .owner = THIS_MODULE,
    .open = my_open,
    .release = my_close,
    .unlocked_ioctl = my_ioctl,
};

static int __init my_init(void) {
    int ret;
    struct device *dev_ret;

    printk("initializing...\n");

    if ((ret = alloc_chrdev_region(&dev, FIRST_MINOR, MINOR_CNT, "name")) < 0)
        return ret;

    cdev_init(&c_dev, &my_ops);

    if ((ret = cdev_add(&c_dev, dev, MINOR_CNT)) < 0)
        return ret;

    if (IS_ERR(cl = class_create(THIS_MODULE, "char"))) {
        cdev_del(&c_dev);
        unregister_chrdev_region(dev, MINOR_CNT);
        return PTR_ERR(cl);
    }

    if (IS_ERR(dev_ret = device_create(cl, NULL, dev, NULL, "dev_filename"))) {
        class_destroy(cl);
        cdev_del(&c_dev);
        unregister_chrdev_region(dev, MINOR_CNT);
        return PTR_ERR(dev_ret);
    }

    printk("inited successfully\n");
    return 0;
}

static void __exit my_exit(void) {
    device_destroy(cl, dev);
    class_destroy(cl);
    cdev_del(&c_dev);
    unregister_chrdev_region(dev, MINOR_CNT);
}

module_init(my_init);
module_exit(my_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("xxx");

{% endhighlight %}

顺便吐槽下pygmentize对c语法的高亮...绿油油的一片，简直不能看。
