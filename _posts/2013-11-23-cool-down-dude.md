---
layout: post
title: "Cool down dude!"
description: ""
category: tweak
tags: linux arch cpu
---
{% include JB/setup %}

## 没文化真可怕

昨天上实验课，一哥们发现我本子的cpu常年70-80摄氏度，然后给我普及了好多关于节电环保的常识。（还是好人多）
尼玛我之前一直以为是笔记本风扇又尘满堵塞了（虽然说出风是小了好多）。

## 关闭独显

我之前的理解：因为cpu的温度一般会比gpu高20多度，于是应该尽量使用独立gpu来降低cpu的负荷。
但是事实上没事开着独显是一件很不低碳的行为，而且会增加cpu温度。毕竟连的是一个导热片，下游的温度升高之后，上游的热量也不能有效地扩散。
要关闭独显很简单，装bbswitch就是了。

他告诉我一个简单的方法判断独显是否开启：
lspci之后对应的nvidia选项末尾是（rev ff）则为关闭，否则处于开启状态。

## 调节cpu governor

那哥们发现我的cpu主频一直是3Ghz。叫我手动改`/sys/devices/system/cpu/cpu*/cpufreq/scaling_governor`，并且安装cpufreqd。

[方法](https://wiki.archlinux.org/index.php/CPU_Frequency_Scaling)

我之前想当然地认为睿频这种事情应该交给内核自己来处理。
后来发现原来这方面它挺傻逼的。跟我一样:-) ......

cpufreqd依赖cpupower。
我用cpupower就基本能满足需求了，就没再安装cpufreqd。
配置嘛,主要是这些

{% highlight ini %}
# Define CPUs governor
# valid governors: ondemand, performance, powersave, conservative, userspace.
governor='powersave'

# Limit frequency range
# Valid suffixes: Hz, kHz (default), MHz, GHz, THz
min_freq="0.8GHz"
max_freq="3GHz"
{% endhighlight %}

动态检查cpu frequency的命令：`$ watch grep \"cpu MHz\" /proc/cpuinfo`

## 检测工具

那哥们还很热心地向我介绍了两个检测工具

* powertop `$ sudo powertop --html` 能够生成html格式的[report](assets/other/powertop.html)（样式还挺美观的...）。
* iotop

那哥们说他找不着powertop的切换report的按键。
manpage里头的确也没写，后来我找了好久，终于发现是ctrl+tab。

## 效果

完事之后，在我写这篇博客的时候，cpu temp一直稳定在50一下。我还是很满意的，虽然powertop还建议修改一些pci的配置，
但是作为一个懒人，写service还是太麻烦了。而且这些选项的影响应该非常小。暂时忽略吧。

我得抓紧把我本子的电池给修好......神烦，外星人就是个坑，等以后有钱了妥妥换mac。再坚持坚持吧。
