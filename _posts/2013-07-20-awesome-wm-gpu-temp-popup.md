---
layout: post
title: "awesome wm gpu temp popup"
description: ""
category: config
tags: awesome bash
---
{% include JB/setup %}
#### final effect

![screenshot](/assets/images/gpu_popup.png)

taken by "shutter -s=1200,1,400,200 -e"

#### Environments
* awesome 3.4.14 with _[blingbling](http://awesome.naquadah.org/wiki/Blingbling)_
* nvidia optimus GT 555m
* bumblebee 3.2.1
* nvidia-319

#### bash script to get gpu temp
first if the discrete gpu is not in use,show it.

else we could use the *nvidia-smi* tool to get gpu status info which is not included in $PATH by default.
I choose to create a soft link of */usr/lib/nvidia-319/bin/nvidia-smi* to *~/bin/nvidia-smi*

so here is the script

{% highlight bash linenos=table %}
#!/bin/bash
bumble_status=$(optirun --status|awk -F " " '{print $NF}')
if [ "$bumble_status" = "off."  ]; then
    echo "Gpu :           off"
    exit 0
fi
bumble_temp=$( optirun --no-xorg nvidia-smi -q -d TEMPERATURE | grep Gpu)
echo "$(echo $bumble_temp | sed 's/\(\S\+\) C/          +\1.0°C/g')"
{% endhighlight %}
the _--no-xorg_ argument of optirun means "do not start secondary X server" and it just saves a lot of time to react

<!--more-->

#### blingbling/popup.lua

use the following to define a new popup with the name "cpusensors" and add gpu temp info to it

{% highlight lua linenos=table %}
local temppopup = nil
local function get_tempinfo( cpu_color, safe_color, high_color, crit_color)
  str=awful.util.pread("gpu_temp&&sensors |grep Core|awk -F '(' '{print $1}'")
  str=colorize(str,"Core %x", cpu_color)
  str=colorize(str,"Gpu", cpu_color)
  str=colorize(str,"high", high_color)
  str=colorize(str,"crit", crit_color)
  str=colorize(str,"off", crit_color)
  str=colorize(str,"+[0-4]%d.%d°C", safe_color)
  str=colorize(str,"+[5-7]%d.%d°C", high_color)
  str=colorize(str,"+[8-9]%d.%d°C", crit_color)
  return str
end

local function hide_tempinfo()
  if temppopup ~= nil then
     naughty.destroy(temppopup)
     temppopup = nil
  end
end
local function show_tempinfo(c1,c2,c3,c4)
    hide_tempinfo()
    temppopup=naughty.notify({
    text = get_tempinfo(c1,c2,c3,c4),
    timeout = 0, hover_timeout = 0.5,
})
end

function cpusensors(mywidget, args)
    mywidget:add_signal("mouse::enter", function()
        show_tempinfo( args["cpu_color"], args["safe_color"], args["high_color"], args["crit_color"])
    end)
    mywidget:add_signal("mouse::leave", function()
        hide_tempinfo()
    end)
end

{% endhighlight %}

#### rc.lua

create a widget and hook it with the defined popup.

done!

{% highlight lua linenos=table %}
tempicon       = widget ({ type = "imagebox" })
tempicon.image = image(beautiful.widget_temp)
blingbling.popups.cpusensors(tempicon,
{
    cpu_color   = "#9fcfff",
    safe_color  = beautiful.notify_font_color_1,
    high_color  = beautiful.notify_font_color_2,
    crit_color  = beautiful.notify_font_color_3,
})
{% endhighlight %}
