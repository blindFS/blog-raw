---
layout: post
title: "Init raspberry pi with a laptop and an ethernet cable"
description: ""
category: config
tags: linux pi
---
{% include JB/setup %}

### blablabla ###

I received my pi yesterday.
I only had a ethernet cable and my laptop with me.The only internet access was ustc-wlt.
It bothered a little to setup my pi to connect via wlan to my pc's wireless card so it can share
the internet access from pc's ethernet.

### steps ###

* First of all,of course,download and extract the image file.I chose [archlinux](http://www.raspberrypi.org/downloads).
with SD card mounted on pc.
{% highlight sh %}
dd bs=1M if=xx.img of=/dev/mmcblk0
{% endhighlight %}

* Enlarge the partition.By default the root directory takes only 2G bytes while the SD card is usually larger than 4G.So this step is really necessary.
I missed this step at first but that didn't matter.
I used the gui tool Gparted to make it.It's simpler to use comparing to the cli tools.

* Config the ethernet of pi to use static ip address instead of dhcp.Replace the `/mount-point/etc/systemd/system/multi-user.target.wants/dhcpcd@eth0.service` with `/mount-point/
/usr/lib/systemd/system/dhcpcd.service` or its link.Create a network.service file in the same directory with the content:

{% highlight ini linenos %}
[Unit]
Description=Network
Wants=network.target
Before=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
EnvironmentFile=/etc/conf.d/network
ExecStart=/sbin/ip link set dev ${interface} up
ExecStart=/sbin/ip addr add ${address}/${netmask} broadcast ${broadcast} dev ${interface}
ExecStart=/sbin/ip route add default via ${gateway}
ExecStop=/sbin/ip addr flush dev ${interface}
ExecStop=/sbin/ip link set dev ${interface} down

[Install]
WantedBy=multi-user.target
{% endhighlight %}

Then create the `/etc/conf.d/network` :

{% highlight ini %}
interface=eth0
address=192.168.1.1
netmast=255.255.255.0
broadcast=192.168.0.255
gateway=192.168.1.2
{% endhighlight %}

* Switch the SD card to the pi and power it up.Use the cable to connect the ethernet interfaces of the devices.
Deploy an ip address in the same subnet with 192.168.1.1/24 to pc's eth0 using:
`sudo ifconfig eth0 192.168.1.2 netmask 255.255.255.0 up`
Since the sshd service is by default enabled on the pi.You can then `ssh root@192.168.1.1` as long as you can ping through.

* Try to share the internet access of pc's wlan0 to the pi.I tried this but failed,and I am still confused.
I checked the iptable of both device using `netstat -rn`.The pi's gateway was 192.168.1.2 which was the ip of pc's eth0.
And the gateway of pc was setted to certain interface of the route of USTC library which guaranteed the internet access of my laptop.
And I enabled pc-routing by setting the content of `/proc/sys/net/ipv4/ip_forward` to '1'.I could even ping from pi to pc's wlan0.However
the pi just couldn't get internet access.

* Change to share the internet access of pc's eth0 to the pi using a tool named [ap-hotspot](https://github.com/hotice/AP-Hotspot).
Login to the pi.Then type in these commands
{% highlight sh %}
ifconfig wlan0 up
wpa_passphrase <ssid> [pass] > /etc/wpa_supplicant/foo.conf
wpa_supplicant -D wext -i wlan0 -c /etc/wpa_supplicant/foo.conf &
{% endhighlight %}
Somehow everytime I tried to apply '-B' argument which means 'run in background as a daemon' to wpa_supplicant,it raised an error...

If a notification shows that a new device is added to the hotspot,change to ssh via the ip of wlan0.Reconnect pc's eth0 to the internet.Done!

* Change the mirrorlist of pacman to USTC mirror.
Modify the active line of `/etc/pacman.d/mirrorlist` to

{% highlight ini %}
Server = http://mirrors.ustc.edu.cn/archlinuxarm/armv6h/$repo
{% endhighlight %}

Then `pacman -Syu` and wait wait wait......

* Install other stuffs......


### TODO ###
Try to connect the ap-hotspot on startup.(the wpa_supplicant.service not helpful,looking for other approach.)
