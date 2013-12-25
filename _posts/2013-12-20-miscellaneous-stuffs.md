---
layout: post
title: "Miscellaneous stuffs"
description: ""
category: config
tags: awesome linux xrandr android
---
{% include JB/setup %}

## Multiple display handling within awesome using xrandr

### Basic usage of xrandr

* Query for available outputs : `xrandr -q`
* Extended screen : `xrandr --output out1 --auto --output out2 --auto --right-of out1 ...`
* Duplicate screen : `xrandr --output out1 --auto --output out2 --auto --same-as out1`

### Circling throught possible configurations

I found the solution from [awesome wiki](http://awesome.naquadah.org/wiki/Using_Multiple_Screens).
However, the provided function does not include the duplicate option which is useful when connected to a projector.

`Don't panic!`

Tweaked a [little bit](https://gist.github.com/farseer90718/8037645).

What I did is simply add another item with *dlabel* and *dcmd* in the list called *menu*.

### XF86 keys

I can't bind that xrandr function to the **XF86Display** which is 'fn+F1' on my laptop.
So I tried to find out why.
I looked up the keycode in the default xmodmap configuration file, and it is 235.
Then I installed the 'xorg-xev' package and found out that X did not recieve any keycode when I pressed that combination.
Give up and used anther comb ...

## Usb-keyboard auto suspend issue

There was a keyboard issue.
The keyboard need some kind of wakeup action every other 5s, so it will ignore some characters that I type.
Then I realized in a [previous article](/tweak/2013/11/23/cool-down-dude/), I have enabled such a udev rule:

{% highlight text %}
ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
ACTION=="add", SUBSYSTEM=="usb", TEST=="power/autosuspend", ATTR{power/autosuspend}="2"
{% endhighlight %}

Disable that, everything is fine now.

## About Android 4.4 kitkat

I flushed my phone with [this rom](http://forum.xda-developers.com/showthread.php?t=2525906) yesterday.
It's extremely fast.
Glade to know that this device is still quite usable.


