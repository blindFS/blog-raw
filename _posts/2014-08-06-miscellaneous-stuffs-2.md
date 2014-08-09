---
layout: post
title: "Miscellaneous stuffs 2"
description: ""
category: Config
tags: arch linux im awesome compton gtk gpu ツッコミ
---
{% include JB/setup %}

最近这段时间遇到的好多令人郁闷的事情......有些解决了，有些待解决，随便记录一下。
话说rmbp倒是更新了，很想换的说，暂时先忍忍吧...

## Networkmanager 0.9.10.0-2 ...

这玩意更新之后问题大大滴。

### openvpn

我之前使用openvpn来科学上网，openvpn是作为一个systemd service启动的，
顺便提一下，默认的service脚本有点小问题，如果openvpn的service在
network 的一些service，比如dhcpd之前启动，则是无效的，因此最好在 [Unit]
中加入 `After=network.target`。
对于之前版本的 nm， 用这个方法来连接非常的完美。
但是升级之后就不是这样了，虽然隧道是建好了，但是报文不走隧道。
甚至是某些报文走隧道，某些不走... DNS没问题，
好多时候能够ping通youtube，但是 `curl -vv youtube.com` 超时。当时我 downgrade `networkmanager, libnm-glib`
这两个包之后，一切正常。于是我初步判断是nm更新导致的。

后来通过安装 networkmanager-openvpn 连上过几次，但是都持续不了多久就失效了。

* 经过我长期的测试发现，新版本下的 openvpn 是否能连接成功完全是随机事件... ipv6更加没戏, 还是老实用 ss 或者 downgrade.

### create_ap

我用 create_ap 这个脚本来创建热点，nm 更新之后 create_ap 也变得无效了。
我给脚本的维护者提交相应 issue 之后，问题立即得到了解决。虽然现在这已经不是问题，但是从侧面证明了
这次 nm 更新的坑爹之处

## 去掉 Gtk3 和 compton 的双重阴影

这个双重阴影的bug出来好久了，我一直没怎么关注，前段时间突然好奇是否有方法解决，搜索之后
从 Arch 论坛上找到了如下的解决方案... (解决方案有两种，从compton下手，从gtk下手，我倾向于后者)

创建如下文件: `~/.config/gtk-3.0/gtk.css`
{% highlight css %}
.window-frame, .window-frame:backdrop {
    box-shadow: 0 0 0 black;
    border-style: none;
    margin: 0;
    border-radius: 0;
}

.titlebar {
    border-radius: 0;
}
{% endhighlight %}

### Synapse and compton

多数 Gtk3 的窗口不会再出现之前烦人的双阴影了，但是 Synapse 照旧。
Synapse 是我最近才发现的，个人非常喜欢的软件。自从上次搞掉 gmrun 之后，就一直用 awesome 自己的 promptbox
来快速启动应用，Synapse 无论从任何方面都远超这两者，直逼 OSX 的 Alfred (我瞎扯淡的，没用过...)。
不管怎样，Synapse 在 compton 下要特殊照顾下，如下:
`shadow-exclude = [ "n:e:Notification", "class_g='Sogou-qimpanel'", "class_g='Synapse'"];`

### fcitx-sogoupinyin and compton

上面的 Sogou-qimpanel 是真对搜狗的输入法提示框的。
之前的 fcitx-sogoupinyin 有些bug，经常卡死，这次的是搜狗官方参与的版本。
启动后会把原来 fcitx 的一套ui覆盖掉，但是其他输入法(mozc, rime)还在，总的来说挺好看的，
而且我比较习惯搜狗拼音了。有个毛病是输入法提示框的阴影会有残留，于是我用了对待 Synapse 一样的
方法来解决。顺便再提一次，我用来检测某个窗口属性(name, class ...)的命令行工具叫 xprop。

* 有个毛病是，搜狗这套 ui 下 mozc 输入法的图标显示不出来，但是 rime 的正常，我试过复制图标到类似路径，但是无果...

## osdlyrics and Awesome wm

osdlyrics 是一款非常棒的歌词实时下载显示软件。支持包括我使用的 mpd 在内的许多播放器和后端.
但是 Awesome wm 下，其默认的显示位置是左上，看上去有点尴尬...
修改的办法是

1. 现在其首选项中将 OSD 中的 dock 替换为 normal
2. 用 xpromp 获取其窗口属性
3. 添加如下规则:
{% highlight lua %}
{ rule = { name = "OSD Lyrics" },
    properties       = {
        border_width = 0,
        floating     = true,
        ontop        = true,
        focus        = true },
    callback         = function( c )
        c:geometry( { x = 0, width = 1600, y = 800, height = 100 } )
    end
}
{% endhighlight %}
4. 再将其替换回 dock 模式...

话说我很好奇它这个 dock 模式是用什么方式实现的, 感觉像是一种不可 focus, ontop 的 window。
顺便一说，我把显示颜色的上中下调成了一样的颜色，扁平化的设计看多了，不喜欢那种色彩过渡的效果...

所以现在的节奏就是用 you-get 去网易云音乐下载 320，然后 mpc update，用 osdlyrics 下歌词... 真是爽！
顺便吐槽下 ncmcpp 默认的歌词下载真是太弱了，怎么都下不到... 就算下到了还是静态的 txt ...

* 不过有个问题没有解决，可能是由于网络原因或者其他，经常性会下载到如下的失败文件, 并命名为 xxx.lrc。
{% highlight xml %}
<?xml version="1.0" encoding="UTF-8" ?>
<result errmsg="Search ID or Code error!" errcode="32006"></result>
{% endhighlight %}
然后该软件就会默认该曲目的歌词已经存在，需要手动删除...

## gdm autostart scripts

我通过 gdm service 来启动 X，所以自动启动脚本的位置跟 xinit 不同，在 `/etc/gdm/Xsession`
所以 `~/.xinitrc` 这个脚本是不会自动执行的，需要在 `/etc/X11/xinit/xinitrc.d/` 中创建一个
link 文件。

* 这里有个问题是，即便脚本是顺利执行了，xmodmap 放在脚本中却是不生效，我只好放到 awesome 的配置
中来自动启动了... (修改了我原先坑爹的 xmodmap 的配置，现在直接通过 keycode 替换了，简单快捷..., 之前忘记 clear Lock 了
, 所以一直没用这种方法...)

### gnome-tweak-tool fix

除了在启动脚本中自动执行之外，还可以通过 XDG 的 autostart 来指定开机自动启动的应用程序，我将 $XDG_CONFIG_HOME 设置成了
`~/.config`, 所以启动脚本都添加在 `~/.config/autostart` 之下。
最简单的添加方法我觉得还是通过 gui 工具 gnome-tweak-tool. 但是这玩意有个小 bug 不知道为啥还是没有修正，参考 archwiki
可以找到修复的方法:
{% highlight diff %}
--- /usr/lib/python2.7/site-packages/gtweak/tweaks/tweak_group_startup.py   2014-03-29 20:03:49.000000000 +0400
+++ ./tweak_group_startup_fixed.py  2014-05-11 21:44:54.225244734 +0400
@@ -17,6 +17,7 @@
 from __future__ import print_function

 import os.path
+import getpass
 import subprocess
 import logging

@@ -207,7 +208,7 @@
         exes = []
         cmd = subprocess.Popen([
                     'ps','-e','-w','-w','-U',
-                    os.getlogin(),'-o','cmd'],
+                    getpass.getuser(),'-o','cmd'],
                     stdout=subprocess.PIPE)
         out = cmd.communicate()[0]
         for l in out.split('\n'):
{% endhighlight %}

## Awesome couth minor fix

我用 awesome 的 couth 库来添加控制音量的 widget. 不知道是不是我的情况比较奇葩，
`amixer -c0 toggle` 的时候，只能静音，不能恢复... 去掉 -c0 (card 0) 的话，toggle 正常，但是
音量增减无效。

`Don't panic!`

rc.lua 相关配置如下:
{% highlight lua %}
awful.key({}, "XF86AudioRaiseVolume", function () couth.notifier:notify( couth.alsa:setVolume('-c0 Master','2dB+')) volumewidget.update() end),
awful.key({}, "XF86AudioLowerVolume", function () couth.notifier:notify( couth.alsa:setVolume('-c0 Master','2dB-')) volumewidget.update() end),
awful.key({}, "XF86AudioMute", function () couth.notifier:notify( couth.alsa:setVolume('Master','toggle')) volumewidget.update() end),
{% endhighlight %}

couth 做如下修改:
{% highlight diff %}
--- a/lib/alsa.lua
+++ b/lib/alsa.lua
@@ -93,8 +93,8 @@ function M:getVolume(ctrlToHighlight)
   for _,ctrl in ipairs(couth.CONFIG.ALSA_CONTROLS) do
     if volumes[ctrl] then
       local prefix, suffix = '',''
-      if ctrl == ctrlToHighlight then
+      if string.find(ctrlToHighlight, ctrl) then
        prefix,suffix = '<span color="green">',"</span>"
       end
       table.insert(ret, prefix .. couth.string.rpad(ctrl, pad_width) .. ': '
         .. self:muteIndicator(volumes[ctrl]['mute']) .. ' '
{% endhighlight %}

* 有个问题是，mpd 如果设置了开机自动启动，然后自动恢复之前播放曲目的话，当时的音量是不受 couth，或者说 amixer -c0 控制的。
需要停止，再次启动。我猜测是 asound 的配置在 mpd 启动那会还没有生效，或者是 pulseaudio 还没启动。小问题，不要紧...

## Disable NVIDIA card on system startup

不知道从哪次内核更新或者是显卡驱动更新之后，反正已经好久了，开机后N卡的状态默认是开着的。
这让我很是郁闷，我找到了 bbswitch 的 [README](https://github.com/Bumblebee-Project/bbswitch)。
试了下其中的方法(kmod & systemd)... 但是不管用，估计是加载 nvidia 驱动模块的时候又自动 on 了。

搜索到的解决办法如下<del> [gist](https://gist.github.com/farseer90718/24f5c200524dd05a20c3) </del>
在 `/etc/bumblebee/bumblebee.conf` 中修改 TurnCardOffAtExit 为 true.

综上所述，最近的日子不太平。小毛病不断，我确实想换 mac 了，但是又觉得略麻烦...
