---
layout: post
title: "Cool down dude!"
description: ""
category: tweak
tags: linux arch cpu ツッコミ
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

## 其它

powertop 会有一些tuning的建议，但是用sysctl修改的话，重启之后又会恢复。
之前不知道什么是udev rules。但是照着[这篇](https://wiki.archlinux.org/index.php/Power_saving)照样画葫芦就能解决问题。
不知道用TLP是不是能直接搞定。我得仔细看看sysctl.d和udev rules的相关内容。

## 效果

完事之后，在我写这篇博客的时候，cpu temp一直稳定在50一下。我还是很满意的。

我得抓紧把我本子的电池给修好......神烦，aw就是个坑，等以后有钱了妥妥换mac。再坚持坚持吧。

## 吐槽

尼玛刚刚给客服打电话，那客服实在是太2了，整整浪费了我将近20分钟时间，最后还是按一开始我描述的方式处理了。
aw的保修期是3年，但是尼玛坑爹的电池保修期是1年（于是就莫名其妙的过保了），aw的电池型号特殊，根本不是标准件。这摆明了是坑你。客服说
新的电池要价700-800，我去年买了个登山包，超耐磨。后来我看某宝的普遍价格是300左右，实在是要换电池的话，又得给马老板创收了。

## 这不是吐槽，注意，这不是吐槽，这是喷......小朋友躲远点

本段写于11-28也就是5天后。

我本来真是不想再继续吐槽dell了，但是售后实在是太傻逼，已经把我惹怒，我觉得有必要在此记录这次报修的全过程。
首先，报修之前，我本子存在的问题。

1. 不插适配器，用电池的话，会无端地自动断电，电池电量几乎满。没有任何征兆的情况下。(全程主要矛盾)
2. 尘满，已经塞住出风口（我就不吐槽这本子的风扇有多难拆），这点其实可以忽略。

报修的过程：

1. 打电话，一个傻逼接的，在我描述存在的问题之后，那个傻逼首先的反应是，您的电池过保了，但是其他配件还在保。
这个问题，有两种可能性，要不是电池坏，要不是主板坏。我说，行那你派一个新的主板过来，再派一个新的电池过来，看看是哪个
部分出问题，如果是主板，就免费换，如果是电池，我再看看价格合适不合适，要不要买新的。那人说，不行，走流程的话，必须确定是哪部分出了问题才好派单，
非要我确定，是主板问题，还是电池问题。重新插拔电池之后，问题依旧。于是仍旧是两种可能性，我当时就不满意了，你浪费我时间来给自己图方便，
关键最后还不能解决问题。我说你浪费我那么多时间，最后还是不能确定，那你怎么处理你看着办。他说ok，这时我天真的以为，他会按我说的派一个主板一个电池过来进一步确定。
就像我上文描述那样"最后还是按一开始我描述的方式处理了"。

2. 25号接到合肥地区的电话，说26号会有工程师上门。26号遇见工程师的时候我傻了，他只带了个主板过来。那我想，行吧，你说是主板问题，你换吧，顺便我好清灰。
于是他开始拆，拆一半光驱砸地上了，换完之后测试了一下，读写都是正常，也就没在意。好的，换完主板，本子很给力地没怎么断电了。我心想，可能真是主板问题。行，解决了，还特别美滋滋的。
天真！他前脚一走，我后脚发现一开flashplayer，sensors显示cpu温度97。风扇狂转出风都是凉的，我打电话问他，说，是不是cpu跟导热管的接触不良导致的啊。
他很肯定地告诉我，那个温度是假的，这种情况他见过，刷一下bios就好了。尼玛我指装了个arch，哪里给你刷bios去？官方提供的只有exe。我还特地查了wiki。flashrom[支持的硬件型号](http://www.flashrom.org/Supported_hardware)，
你dell的主板那么多血红的no。另外，我磁盘分区表用的gpt，win压根不能装在gpt的磁盘上。于是我尝试用winpe启动，试了两个版本，load到一半就会卡主，咨询了下相关人士，表示winpe
并不是那么通用。（这一切都是没文化导致的，尼玛你骗我说刷bios能解决，我居然信了）。

3. 实在没办法，看个视频97度，风扇狂转，绝壁不能忍。27号，打电话给合肥地区的dell售后外包公司。地址在中绿广场1415。那边的工程师告诉我，如果bios是最新版就不是刷bios能解决的。
于是我背着电脑，坐1路车到底，我自己找他们去了，那边的工作人员态度很好（那边的工程师是整个过程中唯一没有过错的人，值得表扬下...诶，不犯错已经需要表扬了）。他给我重新拆机，
在导管和cpu之间涂了些硅胶，装上，温度立马就降下来了。但是任然比我没换主板之前温度偏高。写这段话的时候cpu是54度，上面明确记录换之前是50度以下。而且换主板的时候将一个满尘的出风口
清理干净了。理论上温度肯定是应该更低。但是在测试温度的同时，发现电池断电的现象依旧存在，也就是说主板白换，电池还是坏的。重新插拔电池，依旧，这已经可以确定是电池的问题。
电池寿容量缩水什么的都能理解，突然断电是不是太不应该了。算了，不吐槽dell拙计的产品质量（2年换4次硬件的机子也是少数吧，内存/适配器/网卡/电池）。

4. 27号晚上，读碟的时候发现光驱的声音不同以往了，虽然不影响读写，但是作为我来说，你给我换主板，电池问题没解决，还摔我光驱，导致我光驱读碟声音异常，是不是不能忍？是可忍，孰不可忍？
28好我再次拨通dell客服热线。我依次描述了整个事件，表示现在任然存在的问题：

    * 散热虽然比没涂硅胶的时候好了不少，但是依旧温度不低（跟满尘比都高），我问接线员：看480p的flash正常温度是多少，她非要问我现在多少度（是不是我说100度，你也能说正常？）。诶，我就要你先说，她说50-80度。
    好的，我实测温度是74-84。注意这是刚刚清灰过，而且换主板之前，在我按照上文处理过之后。480p的flash最多到个66度。
    * 电源，电源，该死的电源，你至少给我个新的试试，让我确定是电池的问题，我好买新的啊，cnm。
    * 光驱的异响，让我很不爽，但是我也明确表示，读写是OK的。

听完我这上面1,2,3这一大段过后，那货不但没有道歉，没有提供处理办法，倒是让我给她听光驱的异响（难不成我会骗你？）。我当时在图书馆阅览室，身边没带光盘。为了说明我说的是事实，我只好回寝室拿光盘回来，给她听该死的声音。
听完后她表示，没听清，再听一遍...完事后那货表示这是正常声音，wcnmb。我就知道你会说是正常的，尼玛之前什么声音我又不是不知道，不管正常不正常，至少它摔过（还不是我摔的），而且声音跟之前不一样了(咔咔咔，明显是有什么障碍物的存在)。
我只是把我观察到的问题陈述给你听对吧，我也明确表示读写是正常的。三个毛病，你自己不会分析主次么？非得跟我抬杠，逼逼叨逼逼叨。张口就是磁盘异响，你丫是不是只会分辨这玩意了？

最后的最后，她丫的表示要提交上级进行审批，你丫早干啥去了，我跟你个小喽啰说话不管用的逼逼半天我图个啥？
丫的还要我再等两天才会有人跟我联系。操你妈逼的DELL。

FUCK YOUR MOTHER IN THE HOLE，DELL！


## 参考

* [sysctl.d]( http://0pointer.de/public/systemd-man/sysctl.d.html )
* [udev rules]( http://www.reactivated.net/writing_udev_rules.html )