---
layout: post
title: "Udev rule cheatsheet"
description: ""
category: cheatsheet
tags: linux
---
{% include JB/setup %}

# Why?

udev rules are flexible and very powerful. Here are some of the things you can use rules to achieve:

* Rename a device node from the default name to something else
* Provide an alternative/persistent name for a device node by creating a symbolic link to the default device node
* Name a device node based on the output of a program
* Change permissions and ownership of a device node
* Launch a script when a device node is created or deleted (typically when a device is attached or unplugged)
* Rename network interfaces

# Rule writing

## Rule files and semantics

* `/etc/udev/rules.d/` directory, must have the .rules suffix.
* Files in that dir are parsed in lexical order.That's why most of them are named like number-name.rules.
* "#" as comments, one line one rule, no multi-line rules.
* One device can be matched by more than one rules.

### Rule syntax

* comma seperated key-value pairs.
* *match* keys used to filter the devices.
* *assignment* keys are invoked after all *match* keys are handled.
* Every rule should consist of at least one *match* key and at least one *assignment* key.
* equality operator (==) for *match* keys and (=) for *assignment* keys.

| Match key    | Explanation                                                             |
|--------------|-------------------------------------------------------------------------|
| KERNEL[S]    | match against the kernel name for the device[parent devices]            |
| SUBSYSTEM[S] | match against the subsystem of the device[parent devices]               |
| DRIVER[S]    | match against the name of the driver backing the device[parent devices] |
| ATTR[S]{foo} | match a sysfs attribute of the device[parent devices]                   |
| ACTION       | "add"/"remove"                                                          |
| ENV          | filter the environment variables                                        |

| Assignment key | Explanation                                   |
|----------------|-----------------------------------------------|
| GROUP          | change group                                  |
| OWNER          | change owner                                  |
| MODE           | change mode                                   |
| NAME           | change name                                   |
| ATTR{foo}      | set attribution                               |
| SYMLINK(+=)    | add a symlink                                 |
| PROGRAM        | path of the excutable to generate device name |
| RUN(+=)        | run external program upon certain events      |
| ENV{foo}       | set environment variable                      |
| OPTION(+=)     | all_partitions/ignore_device/last_rule        |

### String substitutions

* *%k* : kernel name for the device, e.g. 'sda3' for '/dev/sda3'
* *%n* : kernel number for the device, e.g. '3' for '/dev/sda3'
* *%c* : output of the 'PROGRAM' assignment value
* *%%* : literal %
* *&#36;&#36;* : literal &#36;

### String matching

Standard wildcard

* *&#42;* : ...
* *?*: ...
* *[]*: ...

### Example

{% highlight text %}
KERNEL=="fd[0-9]*", NAME="floppy/%n", SYMLINK+="%k"
KERNEL=="hiddev*", NAME="usb/%k"
KERNEL=="hda", PROGRAM="/bin/device_namer %k", NAME="%c{1}", SYMLINK+="%c{2+}"
ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="min_power"
ACTION=="add", SUBSYSTEM=="net", KERNEL=="eth0", RUN+="/usr/bin/ethtool -s eth0 wol d"
{% endhighlight %}

# reference

* http://www.reactivated.net/writing_udev_rules.html#terminology
* man udev
* man udevadm
