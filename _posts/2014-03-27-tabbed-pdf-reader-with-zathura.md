---
layout: post
title: "Tabbed pdf reader with zathura"
description: ""
category: tweak
tags: linux font ツッコミ
---
{% include JB/setup %}

## Zathura

linux下一直找不到一款称心如意的pdf阅读器，虽然说windows下的foxit也不一定能满足我的兽欲，但好歹看上去狂霸酷眩拽。
相比之下evince和okular简直不忍直视。okular我就不多说，光是KDE就可以把我恶心到不行。evince的细节设计还是挺到位的，
比如vi的按键设定，ui的布局，屏幕的利用率。但是功能...
前段时间注意到zathura这个软件，觉得可以用来提升逼格，于是果断来一发。
其实平心而论，就实用性来说，zathura还不如evince。但一些特性导致zathura其实很有撸点:

* bookmark的操作比evince灵活，且方便。毕竟纯键盘，感觉是要好一些。另外evince如果要自由使用bookmark的话需要把side pane显示出来，屏幕利用率就降下来了。
* 类似vimrc的配置文件，甚至支持按键的map，对于vimer来说显得十分友好
* 类似dwb，uzbl，vimperator的follow link方式。完全脱离鼠标的操作。但是我很不喜欢它把按键映射到数字，还不像uzbl那样可以自定义。asdf这行按键应该是最舒服的选择。
* 可以选择夜间模式，只要在zathurarc中添加`set recolor true`就可以默认打开夜间模式，黑底白字，十分nice。

但是这些都不是导致它在我心中超越evince的关键因素。重点在于zathura提供了一个"-e"的命令行参数，可以reparent到指定的窗口，这导致了zathura是可以tabbed的！
说实话，我最不满evince的就是它不能tab。按理说这点要求应该不难实现。但是据我所知，如果不算zathura，linux下还没有可以tab的pdf阅读器，浏览器当然不能算。
虽然确实有不少人应该是拿浏览器在看pdf...

关于zathura的配置，zathurarc的manpage都有非常详细的介绍了。而且默认的配置就以及比较到位了，我就不多谈。

## Tabbed zathura

以下内容我都是在[这位同志的配置](https://github.com/vickychijwani/dotfiles/)中抄来的，用到了两个额外的工具，wmctrl和tabbed。
在arch的community中都已存在。
实现的手段其实很简单，主要是两个脚本，首先raise-or-run:

{% highlight sh %}
#!/bin/bash
if [ "$#" = 2 ]; then
    wmctrl -x -a "$1" || $2
else
    wmctrl -x -a "$1" || $1
fi
{% endhighlight %}

`wmctrl -x -a xxx` 的意思就是使WM_CLASS为xxx的窗口获得焦点。整个脚本的意思就是如果某个xxx窗口正在运行，则获取焦点，否则运行xxx
然后是zathura-tabbed:

{% highlight sh %}
#!/bin/bash

raise-or-run "tabbed.tabbed" "tabbed" &
until wmctrl -lx | grep "tabbed.tabbed"; do
    sleep 0.5
done

if [ "$#" = 0 ]; then
    zathura -e `wmctrl -lx | grep "tabbed.tabbed" | cut -d' ' -f1`
else
    zathura -e `wmctrl -lx | grep "tabbed.tabbed" | cut -d' ' -f1` "$1"
fi
{% endhighlight %}

前边的部分就是保证tabbed正常运行，然后通过wmctrl找到tabbed窗口的xid，然后用zathura的-e参数将新产生的窗口嵌入到tabbed的内部。

## XLFD

虽说tabbed这货很实用，但是外观相当不友善，而且最奇葩的是，配置只能通过修改config.h并重新编译来改变。
我最不能忍的就是它的字体，X logical font description 格式的字符串。XCreateFontSet总是说我缺少一堆charset。
改了好久的locale，终于啥都不少了，但是尼玛字体还是没变...
不用fontconfig的都是奇葩，这货不至于这么古董吧...
XLFD这玩意本身我觉得就很蛋疼。

如果我哪天实在无聊的不行，我可能会尝试把tabbed改成基于fontconfig。
目前来说，还是先把pdf的名称都换成英文的，因为中文字体丑的简直无法直视。
