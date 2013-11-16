---
layout: post
title: "Run arm binary on x86 cpu"
description: ""
category: embedded_system
tags: arm assembly qemu
---
{% include JB/setup %}

### 略坑

起完标题发觉有点不大对劲，无奈洋文拙计，不知道该如何描述这个事情，算了不去管它。
其实就是用**qemu-arm**来模拟运行arm程序，省的用开发板呗。

话说我倒是有个烂大街的板子，这方面我一直是小白（虽然其实我哪方面都是小白貌似...）。后来跟一个同学交流了一下，
才发现odroid比起pi来说真是只有那么高性价比了。我买的时候倒是看到过相关新闻，但是没怎么留意，而且我还被无良商家给坑了,
算了，说多都是泪。

### 安装相关包

AUR里头好多arm交叉编译的toolchains，直接把我吓懵了。我挨个试了下，好些个编译不过，最后留的是这些。

* qemu 不用多说了
* cross-arm-linux-gnueabi-newlib
* cross-arm-linux-gnueabi-gcc-base

但是这个newlib也不照，还是会少一些库，还是拷贝过来的arm-none-linux-gnueabi-gcc好使。
各个toolchains的区别:

* 命名**arch [-vendor] [-os] - eabi**
* 如果带os则有os限制
* eabi：embedded-application binary interface跟abi对应，gnueabi应该跟一般的eabi也有所区别。
* vendor：供应商，忽视之。
* none：会改变header和lib的搜索路径，可通过`gcc -print-sysroot`查看，由于我拷贝的none版本非常完整，所以一般不用担心缺库的问题。

在网上搜了下newlib，没看明白怎么玩的。不管他，总之用傻瓜工具先...

### 测试

GNU arm 汇编 冒泡排序

bubblesort.s

{% highlight asm %}
.data
  myWords: .ascii "helloworld"
  myWordEnd:

.text
.global _start

_start:
    ldr r3, =myWordEnd    @ end address
loop:
    mov r4, #0            @ clear mark
    ldr r0, =myWords      @ reset r0 to the beginning address

inner_loop:
    ldrb r1, [r0], #1     @ load byte to r1, r0++
    ldrb r2, [r0]         @ load byte to r2
    cmp r1, r2            @ compare r1, r2

    strgtb r1, [r0]       @ swap in mem if gt
    strgtb r2, [r0, #-1]
    movgt r4, #1          @ mark 1 if swapped

    cmp r0, r3            @ loop end detection
    bne inner_loop        @ loop if not ended

    cmp r4, #1            @ if swapped in this mainloop then loop
    beq loop
print:
    ldr r1, =myWords
    add r1, r1, #1        @ ascii need this while byte don't
    mov r0, #1            @ stdout
    mov r2, #10           @ length
    swi     #0x900004     @ sys_write
    mov r0, #0
    swi     #0x900001     @sys_exit
{% endhighlight %}

Makefile

{% highlight basemake %}
TARGET=arm-none-linux-gnueabi
AS=$(TARGET)-as
LD=$(TARGET)-ld

all:bubblesort

bubblesort:bubblesort.o
    $(LD) -o bubblesort bubblesort.o

bubblesort.o:bubblesort.s
    $(AS) -o bubblesort.o bubblesort.s

clean:
    rm -f bubblesort.o bubblesort
{% endhighlight %}

`$qemu-arm bubblesort` 得到相应输出
