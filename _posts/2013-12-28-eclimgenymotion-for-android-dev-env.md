---
layout: post
title: "Eclim+genymotion for android Dev Env"
description: ""
category: config
tags: android linux vim eclipse
---
{% include JB/setup %}

## Basic android development environment setup

Required packages(for arch only):

* jdk
* eclipse
* eclipse-android in AUR
* android-sdk in AUR
* android-sdk-build-tools in AUR
* android-sdk-platform-tools in AUR
* any other packages related to android-sdk...

Better to change the owner of /opt folder.(write permission required)

## Genymotion

The default android emulator is very slow, that's why [genymotion](http://www.genymotion.com) is needed.
And this package also exists in AUR.

Setup steps:

* user account
* add virual device(virtualbox)
* config android-sdk ADB
* start the virtual device and test it using DDMS in eclipse.

Like this:

![genymotion](/assets/images/article/genymotion.png)

<br />

![eclipse-ddms](/assets/images/article/eclipse-ddms.png)

The newer version(from 2.0.0) of genymotion has removed virtual devices with Gapps installed.

`Don't panic!`

* Download the old images from [here](https://mega.co.nz/#F!cBsTCLIJ!TjJyLkRawugorqbSKkdIGA).
* Import the downloaded ova file to virtualbox.
* restart genymotion and done!

## Eclim

[Eclim-git](https://github.com/ervandew/eclim) also exits in AUR.
But I need to modify the *PKGBUILD* script in order to use vim package manager plugins(neobundle in this case).
Just replace each occurance of '/usr/share/vim/vimfiles' with '/home/username/.vim/bundle/eclim'.
Actually I prefer build it from source:

* install apache-ant
* `sudo ant -Declipse.home=/usr/share/eclipse -Dvim.files=/home/username/.vim/bundle/eclim`
* generate helptags in vim
* start eclimd(window/Show_View/Other) in eclipse and test it using `:PingEclim` in vim.

Vim configuration:

{% highlight vim %}
NeoBundleLazy 'eclim', {'autoload':{'filetypes':['java']}}
...
let g:EclimCompletionMethod = 'omnifunc'
{% endhighlight %}

Explanation:

* The lazy way of loading prevents eclim from interfering vim configuration in other filetypes such as python/php.
* Using **omnifunc** instead of **completefunc** so that it works better with **neocomplete**.

Screenshots:

![eclim-completion](/assets/images/article/eclim-completion.png)

<del>The headless way of **eclimd** doesn't work in my case.</del>(wrong workspace configuration)
However I happen to prefer the headed way which allows me to control the progress more clearly.

## Test demo

Simple Hello world test app:

![android-helloworld](/assets/images/article/android-helloworld.png)

