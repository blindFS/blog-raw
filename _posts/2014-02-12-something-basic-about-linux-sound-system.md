---
layout: post
title: "Something basic about linux sound system"
description: ""
category: config
tags: audio linux
---
{% include JB/setup %}

### Advanced linux sound architecture(ALSA)

#### Roles played

* A linux kernel component
* Providing devices drivers for sound cards
* Providing higher level API for applications to access driver features

#### Basic configuration

* configuration files : `/etc/asound.conf`, `~/.asoundrc`
* pcm.!default : which card and device will be used for audio playback
* ctl.!default : which card is used  by control utilities like alsamixer

#### Advanced features

* [Select the default PCM via environment variable](https://wiki.archlinux.org/index.php/Advanced_Linux_Sound_Architecture#Select_the_default_PCM_via_environment_variable)
这个好鸡肋...
* [System-wide_equalizer](https://wiki.archlinux.org/index.php/Advanced_Linux_Sound_Architecture#System-wide_equalizer)
不喜欢用均衡器，从通信的角度来说，使用均衡器也许会改善听感，但是必然会增加jitter，降低音质。
* [High quality resampling](https://wiki.archlinux.org/index.php/Advanced_Linux_Sound_Architecture#High_quality_resampling)
这个对我来说没啥用，我反正用pulseaudio而不是alsa的dmixer，pulse的采样频率是在另外一个文件中配置的。
虽然Nyquist定理表示44.1khz的采样频率足够完全还原人耳感知频率范围内的声波，但是心理作用（俗称脑放）告诉我，高的一定是好的。相对的代价仅仅只是一点点cpu资源。19200khz时候的pulseaudio也不过1%而已。
* [Upmixing/downmixing](https://wiki.archlinux.org/index.php/Advanced_Linux_Sound_Architecture#Upmixing.2Fdownmixing)
上混针对的是7.1/5.1的音箱系统，穷屌买不起，即便是买得起，有那个设备谁还玩pc hifi啊?
下混其实也没啥用，多声道的音源非常少，别下载就是了。

#### Mixer

如果想要多个程序同时使用声卡，那么必须使用混音。
而且一般的集成声卡都不支持硬件混音，但是软件混音会严重降低音质。
alsa默认使用dmixer作为软混。但是pulseaudio作为gnome的依赖，默认会劫持声卡。虽然有方法让dmixer和pulseaudio和谐共处（wiki上被标记为“不推荐”）
但是既然dmixer的音质都不比pulseaudio强到哪去，那么破罐子破摔干脆全部走pulseaudio得了。

### PulseAudio

#### Roles played

* Serves as a proxy  to sound applications using existing kernel sound components, A.K.A ALSA in most circumstance.
* Operational flow chart:

![pulseaudio](/assets/images/article/pulseaudio.png)

#### Basic usage

* `pulseaudio --start`
* `pulseaudio --kill`

#### My setup

~/.asoundrc :
{% highlight text %}
pcm.!default {
  type pulse
  fallback "sysdefault"
  hint {
    show on
    description "Default ALSA Output (currently PulseAudio Sound Server)"
  }
}

ctl.!default {
  type pulse
  fallback "sysdefault"
}
{% endhighlight %}
这个应该就是pulseaudio安装之后的默认，从上图可以看到pulseaudio可以读ALSA source也可以输出到ALSA sink，现在pcm默认类型是pulse，于是ALSA不走dmixer而是通过pulseaudio了（mpd比较特殊，在下文讨论）。
pulseaudio经过混音，pulse的均衡器（如果有的话），重新采样之后再通过ALSA sink调用驱动层，然后最终输出。

### MPD

Music player daemon，神奇的存在，可以在/etc/mpd.conf中添加多个输出，如果是ALSA的话，尽管上面的设置已经让ALSA走pulseaudio了，但是mpd不会，依旧独占声卡。
估计是用户不同的问题(我原来的系统上mpd的ALSA输出和pulse输出是可以同时出声的，pulse有明显的delay)。
不过不要在意这些细节，反正现在我的原则是，音质神马的都是浮云，出声就好。于是可以在mpd中添加pulse的输出。像这样：

{% highlight text %}
audio_output {
  type "pulse"
  name        "My Pulse Output"
  mixer_type      "software"
  server          "127.0.0.1"
}
{% endhighlight %}

这样还是不够，因为我机子上跑mpd的用户是mpd而不是我自己。pulseaudio server默认对不同用户是分离的。需要添加：`load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1`
到 `~/.config/pulse/default.pa`。这样pulse就能接受上图中*TCP native protcols* 这个模块了。

于是到此为止，大家都用pulse，问题基本解决了。

### Reference

* https://wiki.archlinux.org/index.php/Advanced_Linux_Sound_Architecture
* https://wiki.archlinux.org/index.php/PulseAudio#Equalizer
* http://en.wikipedia.org/wiki/PulseAudio
* https://wiki.archlinux.org/index.php/MPD/Tips_and_Tricks
