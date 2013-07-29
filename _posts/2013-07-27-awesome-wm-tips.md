---
layout: post
title: "awesome wm tips"
description: ""
category: config
tags: linux awesome shell
---
{% include JB/setup %}

#### 两个简单实用的好东西

* [eminent](http://awesome.naquadah.org/wiki/Eminent)
* [revelation](http://awesome.naquadah.org/wiki/Revelation)

上头那个是个动态的标签管理。简单来说就是在当前标签对应的桌面没有窗口的时候，自动隐藏这个标签。
一般情况下切换桌面的快捷键是**mod+num**，如果当标签不是数字时（我就不是），可能不能很快地反应过来对应的快捷键。
但是这点小问题对于我这样最多只用5个桌面的人来说忽略不计。
<br />
下面那个很牛逼，就像是gnome下**mod+w**的预览功能。而且是对全部桌面下窗口的预览。像这样：

![revelation](http://awesome.naquadah.org/w/images/thumb/Revelation.png/600px-Revelation.png)

这两个好东西还有个共同的有点就是配置及其简单。
基本上就是下载下来require一下就搞定了。

#### 参考主题和一些配置

我的配置基本上是根据 [这个主题](https://github.com/romockee/powerarrow) 来的。我觉得不论从样式，功能，色彩的角度来说。
这套东西都是及其靠谱。当初为了让它能适应我的电脑，费了不少劲，也做了一些个人的修改。之前干了点啥就不去回忆了，反正配置都在，
要记起来也简单。至于之后如果有什么功能上的改变，我想还是有必要记录一下，主要是实在没啥正儿八经的东西要记录的......

前段时间不知道为啥，感觉chromium有内存泄露。看个长点的视频内存就用掉5,6个g。而这套配置的htop popup是针对cpu利用排序的，当鼠标浮动到
cpu widget的时候会出来，但是mem widget时啥都没有，于是我添加了个针对mem利用排序的htop popup来方便观察异常状态。
还是popup.lua，很简单，只需要给show_process_info这个函数加个参数来区分排列方法即可，其它东西都是现成的。

{% highlight lua linenos %}
local function show_process_info(inc_proc_offset, title_color,user_color, root_color, sort_order)
    local save_proc_offset = proc_offset
    hide_process_info()
    proc_offset = save_proc_offset + inc_proc_offset
    if sort_order == "cpu" then
        processstats = awful.util.pread('/bin/ps --sort -c,-s -eo fname,user,%cpu,%mem,pid,gid,ppid,tname,label | /usr/bin/head -n '..proc_offset)
    elseif sort_order == "mem" then
        processstats = awful.util.pread('/bin/ps --sort -rss,-s -eo fname,user,%cpu,%mem,pid,gid,ppid,tname,label | /usr/bin/head -n '..proc_offset)
    end

    processstats = colorize(processstats, "COMMAND", title_color)
    processstats = colorize(processstats, "USER", title_color)
    processstats = colorize(processstats, "%%CPU", title_color)
    processstats = colorize(processstats, "%%MEM", title_color)
    processstats = colorize(processstats, " PID", title_color)
    processstats = colorize(processstats, "GID", title_color)
    processstats = colorize(processstats, "PPID", title_color)
    processstats = colorize(processstats, "TTY", title_color)
    processstats = colorize(processstats, "LABEL", title_color)
    processstats = colorize(processstats, "root", root_color)
    processstats = colorize(processstats, os.getenv("USER"), user_color)
    processpopup = naughty.notify({
        text = processstats,
        timeout = 0, hover_timeout = 0.5,
    })
end

function htop(mywidget, args)
    mywidget:add_signal("mouse::enter", function()
        show_process_info(0, args["title_color"], args["user_color"], args["root_color"], args["sort_order"])
    end)
    mywidget:add_signal("mouse::leave", function()
        hide_process_info()
    end)

    mywidget:buttons(awful.util.table.join(
    awful.button({ }, 4, function()
        show_process_info(-1, args["title_color"], args["user_color"], args["root_color"], args["sort_order"])
    end),
    awful.button({ }, 5, function()
        show_process_info(1, args["title_color"], args["user_color"], args["root_color"], args["sort_order"])
    end),
    awful.button({ }, 1, function()
        if args["terminal"] then
            awful.util.spawn_with_shell(args["terminal"] .. " -e htop")
        else
            awful.util.spawn_with_shell("xterm" .. " -e htop")
        end
    end)
    ))
end
{% endhighlight %}
既然说起popup.lua，那有一点我记得比较清楚就是：netstat起初非常的卡，原因是没有添加-n参数即不进行域名解析，所以-n还是必须的。

#### awesome wallpaper switch

这套配置的github repo里提供了一个脚本，用来切换背景。长相如下：

{% highlight bash linenos %}
#! /bin/bash
WALLPAPERS="/home/farseer/.config/awesome/wallpapers/"
ALIST=( `ls -w1 $WALLPAPERS` )
RANGE=${#ALIST[@]}
let "number = $RANDOM"
let LASTNUM="`cat $WALLPAPERS/.last` + $number"
let "number = $LASTNUM % $RANGE"
echo $number > $WALLPAPERS/.last
awsetbg $WALLPAPERS/${ALIST[$number]}
{% endhighlight %}

很简单而实用，但是我的wallpaper不多，我就把$RANDOM换成1了。我还在awesome wiki上看到一些 [蛋疼的东西](http://awesome.naquadah.org/wiki/Cycling_Random_Wallpaper_Or_Xscreensaver)。
我觉得相比之下写成bash对我来说更友爱。而且也没必要在后台跑着定时切换，占资源（虽然用不了多少，但是不爽）。

#### 几个前段时间才发现的东西......

* flash播放器的自动全屏问题。

{% highlight lua %}
{ rule = { instance = "exe" },
    properties = { floating = true } },
{ rule = { instance = "plugin-container" },
    properties = { floating = true } }
{% endhighlight %}
上边针对chrome，下边firefox。加到rules里头，这两个的flash还起不一样的名字，蛋疼。

* awesome居然也能支持标题栏和按钮。

{% highlight lua %}
client.add_signal("manage", function (c, startup)
     --awful.titlebar.add(c, { modkey = modkey })

    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)
{% endhighlight %}

把titlebar那行的注释去掉就有了，虽然我相信没人会这么做......

* reddit上看到的好玩但是没啥用的功能。

{% highlight sh linenos %}
function alert {
    RVAL=$?                 # get return value of the last command
    DATE=`date`             # get time of completion
    LAST=$history[$HISTCMD] # get current command
    LAST=${LAST%[;&|]*}     # remove "; alert" from it
    LAST=${LAST//\"/'\"'}   # "} # 拙计的pygement，不过vim有的时候也会这样，high regin太坑爹了。place slash in front of quotation mark in order not to break lua
    # check if the command was successful
    if [[ $RVAL == 0 ]]; then
        BG_COLOR="#000b10"
        FG_COLOR="#839496"
        RESAULT="complete"
    else
        BG_COLOR="#f366a2"
        FG_COLOR="#000b10"
        RESAULT="fail"
    fi
    MESSAGE="naughty.notify({ \
            title = \"Command $RESAULT on: \t\t$DATE\", \
            text = \"$ $LAST\", \
            timeout = 6, \
            bg = \"$BG_COLOR\", \
            fg = \"$FG_COLOR\", \
            margin = 28, \
            width = 382, \
            })"
    # send it to awesome
    echo $MESSAGE | awesome-client -
}
{% endhighlight %}

这个东西我稍稍修改了一点点，作用就是在终端执行一段命令之后用notify来弹窗提示，当然输入执行的时候也要添加;alert或者&amp;&amp;alert。
我是作为一个zsh plugin来用的，其实功能上来说完全可以不用这么麻烦，直接notify-send就行了。就当了解下naughty.notify和awesome-client了。
这玩意对我来说没有意义，自从添加之后一次也没用到过。我想对高端大气的gentoo用户应该有点用，一不小心就把emerge给黑了......

说起notify，顺便记录下两个跟awesome无关的好东西：

* [mpdnotify](https://github.com/vehk/mpdnotify)
    <br />  对带空格的路径需要自行sed，然后在ncmpcpp的config里头添加execute_on_song_change="execute command"
* [weechat-beep.pl](http://weechat.org/scripts/source/beep.pl.html/)
    <br />  然后/iset beep找到对应的command内容改成notify-send blablabla。这样在别人highlight你的时候就会收到notification了。这是真实用。
