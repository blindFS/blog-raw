---
layout: post
title: "Turn off the lights"
description: ""
category: fun
tags: linux python
---
{% include JB/setup %}
#### 无聊的人生

其实这些事情真的很无聊，但是我本身就是个无聊的人，所以我干了。
可能是我孤陋寡闻，我一直没有在笔记本上找到台式机那种直接关掉显示器的类似功能。
意思是，如果我合上盖子。它会断网，这让人很不愉快。不过我貌似在gnome-power-manager里设置了n久之后会
turn off display。但是等这么久是很折磨人的。
当然你可以lock screen用xscreensaver或者gnome-screensaver。可是我想的是能直接关掉显示然后去睡觉。

找来找去找了个奇葩玩意叫vbetool，用法就是

{% highlight sh %}
vbetool dpms on #turn on display
vbetool dpms off #turn off display
{% endhighlight %}

说他奇葩是应为当turn off了以后你不能通过单一的按键或者移动鼠标来恢复而是必须要输入上头那个命令，而且是sudo，于是还要带密码。
为了不那么痛苦，最简单的方法就是alias了吧

{% highlight sh %}
alias von='sudo vbetool dpms on'
alias voff='sudo vbetool dpms off'
{% endhighlight %}

这样的话，我反正是能够接受。

#### pyAlienFX

关了显示器简单，但这不是重点。重点是键盘背光......
我的机子是Alienware M14xR1。键盘背光的亮度足以影响睡眠质量。windows下用alienware官方的fx软件很简单就关了，
而且我一直以为linux下是不会有这么无聊的东西的，直到我膝盖中了一箭
居然还有 [这货](http://code.google.com/p/pyalienfx/) ，我去。
看了下时间，Oct 2011 - Nov 2012。果然，在我买机器的那会它还没出生。而那段时间正好俺不务*正业*，没怎么关心这些个玩意。
总之先搞来试试再说。一开始我以为是一个废弃了半年多的烂摊子，没想到的是，虽然是个烂摊子，居然还在更新，今天早上还pull了一小下。
这让我有点小意外。
用法嘛，是很简单滴，我这里就简单记录下几处需要的修改就行了。
首先是个很明显的bug
在pyAlienFX_Indicator.py里status bar 的icon他原本写的是他自己的绝对路径。

{% highlight python %}
self.ind = appindicator.Indicator("pyAlienFX", "./images/indicator_off.png", appindicator.CATEGORY_APPLICATION_STATUS)
self.ind.set_status(appindicator.STATUS_ACTIVE)
self.ind.set_attention_icon("./images/indicator_on.png")
{% endhighlight %}

然后针对M14x的机型在pyAlienFX.py里要把BLOCK_BATT_SLEEPING有关的这行注释掉。原因嘛，估计是不支持这个选项。

{% highlight python %}
#Block 0x07 ! Battery Sleeping !
# self.controller.Set_Loop_Conf(Save,self.computer.BLOCK_BATT_SLEEPING) # line743
self.controller.Add_Loop_Conf(area,"morph",color2,'000000')
self.controller.Add_Loop_Conf(area,"morph",'000000',color2)
{% endhighlight %}

这样之后，基本功能就可以实现了，比如on/off，还有选择几个常规颜色。
我为什么说它是个烂摊子呢，主要是界面丑爆。

![screenshot](/assets/images/alienfx.png)

这不科学的布局，这是在黑gtk么？
值得一提的是indicator的图标我自己g了个，为了配合 [malys-uniblue](http://browse.deviantart.com/art/malys-uniblue-update-11-09-2012-298501868) 这个图标主题。
这种方面我可能是有强迫症。ps：goldendict的图标g了但是不生效，可能是没找对位置。但是能locate到的goldendict的图标我都改了。这让我蛋疼不已

如果只是这样，还是让我很不爽。应为，首先，界面太丑太丑，我根本不敢用，另外，我是终端控，能用cli解决的东西坚决不开gui。

`Don't panic!`

这种小事总是有办法的。写了个kbtoggle.py的简单脚本

{% highlight python linenos %}
#!/usr/bin/python
# -*- coding: UTF-8 -*-
import sys
from AlienFX.AlienFXEngine import *
from pyAlienFX import Daemon_Controller, pyAlienFX_GUI

if __name__ == "__main__":
    driver = AlienFX_Driver()
    computer = driver.computer
    controller = Daemon_Controller()
    conn = controller.makeConnection()
    gui = pyAlienFX_GUI()
    if not conn:
        controller = AlienFX_Controller(driver)
    if len(sys.argv) != 2:
        print "\33[3;32m======================"
        print "\33[3;31mUSAGE:kbtoggle on/off"
        print "\33[3;32m======================"
        sys.exit()
    if sys.argv[1] == "off":
        controller.Reset(computer.RESET_ALL_LIGHTS_OFF)
    elif sys.argv[1] == "on":
        gui.Set_Conf()
    else:
        print "\33[3;32m======================"
        print "\33[3;31mUSAGE:kbtoggle on/off"
        print "\33[3;32m======================"
{% endhighlight %}
虽然这里调用了pyAlienFX_GUI这个类，但是界面并没有初始化，所以还是个cli脚本。
我看了下他gui部分的代码，发现当前的键盘亮暗是用一个局部的布尔值记录的，然后我就湿了。
没办法，只有自己处理这个问题了。
我本来想的是用一个文件记录下键盘当前的亮暗状况，这样就不用传参数了，但是作为一个有洁癖的青年，
多一个没用的文件是件很痛苦的事情，纠结了很久，还是用参数吧，最多也就是多4个keystrokes。
突然想到可以配合一个bash脚本用环境变量来记录状态。但是一样的道理多一个文件......还是算了吧。
另外有种错觉，带参数的脚本显得比较大气上档次......大不了再alias嘛，呵呵。

好了，这下可以安心睡觉了。
