---
layout: post
title: "Awesome wm tips 2"
description: ""
category: tweak
tags: linux awesome xdotool
---
{% include JB/setup %}

## Fixed width for net widget

一般来说awesome用户的systray是放在其它widgets的左侧的。
至少我是这样，默认的配置也是这样。
那么这时候如果添加了网速检测的widget，而且它的占位不固定，就会导致systray的位置一直变化，
又晃眼，又影响操作...

`Don't panic!`

可以用lua下string的format函数来限定输出的位宽。当然同时需要配合一款等宽字体。
我希望只有net的字体是mono系的，所以我不能改变全局的字体设置。但这些都是小意思。

解决方法：
{% highlight lua %}
netwidget = wibox.widget.background(lain.widgets.net({
    settings = function()
        widget:set_markup(markup.font("Monofur 12",
        markup("#7AC82E", " " .. string.format("%05.1f", net_now.received))
        .. " " ..
        markup("#46A8C3", " " .. string.format("%05.1f", net_now.sent) .. " ")))
    end
}), "#313131")
{% endhighlight %}

这里我用的是lain中的net。
当然其它的widgets也有这个问题，但是它们的变动频率都较低。因此没有太大的影响。

## xdotool

这真是神器，号称X11下的按键精灵。
很久没有用外接鼠标了，就连dota2我也是只用触摸板虐虐ai或者被ai虐虐而已。
触摸板那个玩意，大家都懂，能不碰尽量别碰。
但是日常使用中，还是有很多场合需要用到鼠标。（比如可恶的flash）
但是自从有了xdotool，再也不用担心触摸板挂掉。

首先，将鼠标的移动和点击，通过awesome的按键绑定映射到键盘

{% highlight lua %}
local safeCoords               = {x=1600, y=900}
local chromiumCloseDownloadBar = {x=3180, y=876}
local mouseMoveInterval        = 15
globalkeys = awful.util.table.join(
...
awful.key({ modkey, altkey }, "m", function() awful.util.spawn("xdotool mousemove " .. safeCoords.x .. " " .. safeCoords.y) end),
awful.key({ modkey, altkey }, "d", function() awful.util.spawn("xdotool mousemove " .. chromiumCloseDownloadBar.x .. " " .. chromiumCloseDownloadBar.y .. " click 1") end),
awful.key({ modkey, altkey }, "j", function() awful.util.spawn("xdotool mousemove_relative 0 " .. mouseMoveInterval) end),
awful.key({ modkey, altkey }, "k", function() awful.util.spawn("xdotool mousemove_relative 0 -" .. mouseMoveInterval) end),
awful.key({ modkey, altkey }, "h", function() awful.util.spawn("xdotool mousemove_relative -- -" .. mouseMoveInterval .. " 0") end),
awful.key({ modkey, altkey }, "l", function() awful.util.spawn("xdotool mousemove_relative " .. mouseMoveInterval .. " 0") end),
awful.key({ modkey, altkey }, "1", function() awful.util.spawn("xdotool click 1") end),
awful.key({ modkey, altkey }, "3", function() awful.util.spawn("xdotool click 3") end),
... )
{% endhighlight %}

我这里实现了两个固定的操作，

* 将鼠标移动到边缘，眼不见为净。
* 把chromium中底部令人讨厌的正在下载条关闭(全屏的时候)。

当然xdotool的功能还有很多。可惜我不打页游，要不然写个挂机脚本啥的，非常的妥帖。
