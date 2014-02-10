---
layout: post
title: "Start using Rime IM"
description: ""
category: tweak
tags: IM linux
---
{% include JB/setup %}

### 实在是搞不懂

用了一段时间的*fcitx-sogou*，一直有个问题解决不能。
只要是a开头的词句，就会出现严重的卡顿，而且选项之一必须是“阿里旺旺”。
这个“阿里旺旺”的词条是我输入一次之后记忆的，但是一直挥之不去，像是被马云附体了，实在可怕。
最近这个问题愈演愈烈，一旦卡顿，非得切到tty用kill不可。
看了下AUR中该包的评论，貌似有这个问题的不止我一人啊。

### 走投无路

素闻rime是一款神级输入法，其实我是尝试过的，而且是在sogou之前。我当时的第一感觉是，不顺手。
而且个人感觉rime在繁体中文中的表现才是其长处，而我个人几乎没有使用繁体中文的场合。
加上rime的配置比其他的拼音输入法都要麻烦一些（还没有找到图形化的配置工具）。

既然sogou被我pass了，而其他的拼音输入法，例如google-pinyin，我觉得还是不够智能。
于是我只能再试试rime，毕竟真正的神器很可能出面相不那么和谐。

### fcitx-rime的基本配置

配置文件主要是存放在`/usr/share/rime-data`，虽然`~/.config/fcitx/rime` 下也有些软链和备份，但是光是修改那部分文件是不会有任何作用的。
我需要做的修改主要是:

* 切换至简体：按*Ctril+~*即可切换
* 添加一些模糊音的规则（前后鼻音部分真的亚历山大）：修改`/usr/share/rime-data/luna_pinyin.schema.yaml`，添加类如

{% highlight text %}
- derive/([ei])n$/$1ng/
- derive/([ei])ng$/$1n/
{% endhighlight %}

之后执行`sudo rime_deploy build /usr/share/rime-data/`，之后重启fcitx。

* 修改*fcitx-quickphrase*插件的触发快捷键，默认是通过*;*触发，但是rime下不能使用。

### 遗留问题

* *fcitx-cloudpinyin* 这个插件貌似不能在rime下使能。
* 尚且对该输入法一无所知，需要在使用中进一步了解。
