---
layout: post
title: "Awesome wm client & gtk.window"
description: ""
category: tweak
tags: awesome linux gtk
---
{% include JB/setup %}

## Problem

我最近试了下screenkey这个包，发现了些之前没有注意到的有趣的东西。
按道理来说，screenkey应该是作为一个ontop的窗口，具有固定的位置和尺寸，
而且有一定透明度，不允许focus, 无decorator的存在。
但是在awesome wm中确并不是如此。好在这是个python脚本，pygtk实现，方便我查找问题的所在。
我看了下它的代码，却找不出什么问题。于是我切换到gnome下，它看上去就一切正常了。
于是我猜想，并不是所有对gtk.window属性的设置都能被awesome接受。

为了排除是pygtk的问题，我用c写了个简单的窗口来测试一些属性。

{% highlight c %}
#include <gtk/gtk.h>

int main (int argc, char *argv[])
{
    GtkWidget *window;
    gtk_init (&argc, &argv);
    window = gtk_window_new (GTK_WINDOW_TOPLEVEL);
    g_signal_connect (window, "destroy", G_CALLBACK (gtk_main_quit), NULL);

    gtk_window_set_wmclass(GTK_WINDOW(window), "GtkTest", "GtkTest");
    gtk_window_set_default_size(GTK_WINDOW(window), 500, 500);
    gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_MOUSE);
    gtk_window_set_modal(GTK_WINDOW(window), FALSE);
    gtk_window_set_accept_focus(GTK_WINDOW(window), FALSE);
    gtk_window_set_focus_on_map(GTK_WINDOW(window), FALSE);
    /* gtk_window_set_resizable(GTK_WINDOW(window), FALSE); */
    gtk_window_set_opacity(GTK_WINDOW(window), 0.8);

    gtk_widget_show (window);
    gtk_main ();
    return 0;
}
{% endhighlight %}

测试的结果，简单来说，问题集中在focus, position, size这几个方面。

* 如果采用tiling的布局，那么显然position和size会有问题，因为gtk并不支持awesome中所谓floating那套玩意(或者我没找到)。而tiling时只有floating的窗口才允许有自由的position和size。
* 如果是floating的布局，基本上等同于所有窗口视作floating，那么pos和size会有作用。
* focus完全不起作用。
* 其他测试过的属性能正常工作，只不过*set_opacity()*这个函数貌似在3.0中被挪到gdk层了。

先不去管pos和size的问题，光是focus的问题就能让screenkey非常的棘手，因为每当你从键盘输入的时候，screenkey这个窗口自动开启，并且自动获取焦点。
于是你本来想要操作的窗口将不会响应。

## Solution

尽管这一切貌似是由awesome的不足和其平铺的特性决定的。
`Don't panic!`
awesome依旧提供了足够的方案来解决。
由于有rule的存在，我们不用修改screenkey的任何源码，就可以完美解决这个问题。

首先用*xorg-xprop*这个工具获得screenkey的wmclass。然后添加如下的rule:

{% highlight lua %}
{ rule = { class = "Screenkey" },
properties    = {
    opacity   = 0.50,
    floating  = true,
    ontop     = true,
    focus     = false, },
callback = function( c )
    c:geometry( { x = 0, width = 3200, y = 700, height = 120 } )
end },
{% endhighlight %}

client的具体的属性和函数，可以参考本文下方给出的文档连接。

* focusable属性不知道是干啥用的(完全没有效果貌似...)，反倒是focus能解决问题。
* 直接用一个回调函数解决窗口的大小和位置，省的折腾gtk。

## Terminology explanation

* glib：为高层提供底层数据结构，处于相对的最底层。
* gdk：作为gtk的下层，包装了X。
* gtk：这个就不解释了。
* wm：window manager，直接跟X通信的存在，主要负责窗口的特性显示。gtk.window的很多属性都是需要通过wm来体现。
* compositor：这个玩意跟wm傻傻分不清，不去管它。我倾向于将wm理解为功能相对简单的compositor。
* de：desktop environment，嗯，就那么回事吧。


## Document links

* http://awesome.naquadah.org/doc/api/modules/client.html
* https://developer.gnome.org/pygtk/2.22/class-gtkwindow.html
