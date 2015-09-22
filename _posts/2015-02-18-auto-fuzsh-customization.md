---
layout: post
title: "Auto-fu.zsh customization"
description: ""
category: tweak
tags: zsh shell
---
{% include JB/setup %}

## 大概是这么一回事

放假闲的慌，于是开始折腾些有的没的，忘记是怎么看到[这个repo](https://github.com/hchbaw/auto-fu.zsh)的了...觉得很好玩的样子，就打算试试看。但是折腾的过程中发现，要让这个插件跟我原有的配置共洽，稍稍有点费劲，于是在此记录下我的无聊行径。

## 选择合适的branch

一开始发现它和zsh-syntax-highlighting闹矛盾，翻了下github的issue，发现有两个branch解决了这个问题，分别是pu和thb，没搞懂名字怎么来的...

pu比thb多了自动纠正，其实我对自动纠正挺反感的，无奈的是thb有些其它的bug，比如在按下tab补全路径的时候会多一个`/`，总之就是我选择了pu这个分支。

## 初始化配置

这个在文档里就有，不过github上的readme的格式比较糟糕。

{% highlight sh %}
# 需要oldlist
zstyle ':completion:*' completer _oldlist _complete
# 跳过rm的第一个参数
zstyle ':auto-fu:var' autoable-function/skiplbuffers \
    'rm -[![:blank:]]#'
# 使能auto-fu
zle-line-init () {
    auto-fu-init
}
zle -N zle-line-init
{% endhighlight %}

auto-fu的skip规则，比较复杂，具体参见文档，我还没有仔细探究。
这里最关键的步骤就是zle-line-init这个widget，每行初始化的时候都会调用auto-fu-init，i.e. 使能auto-fu。这样配置之后就能正常工作了。

## 外观

为了保持外观的统一，我做了如下调整。

{% highlight sh %}
# 原有的消息格式
zstyle ':completion:*:descriptions' format $' \e[30;42m %d \e[0m\e[32m\e[0m'
zstyle ':completion:*:messages' format $' \e[30;45m %d \e[0m\e[35m\e[0m'
zstyle ':completion:*:warnings' format $' \e[30;41m No Match Found \e[0m\e[31m\e[0m'
# 去掉多余的提示信息
zstyle ':auto-fu:var' postdisplay ''

# prompt中的vimod字段
function zle-keymap-select {
# afu所需
    afu-track-keymap "$@" afu-adjust-main-keymap
    if [[ $KEYMAP =~ "vicmd" ]]; then
        vimod=$vimodcmd
    else
        vimod=$vimodins
    fi
    zle reset-prompt
    zle -R
}
zle -N zle-keymap-select
{% endhighlight %}

我在prompt中添加了`$vimod`提示，具体[内容](https://github.com/blindFS/zsh-funcs/blob/master/powerline.zsh)见链接。这个函数在每次keymap发生变化时调用，注意这时的 keymap 的值可能是auto-fu提供的 *afu-viins* 和 *afu-vicmd* ，所以判断的时候采取 `=~`。
这样之后还有个问题，就是自动纠错时会产生不必要的消息，导致如下情况：

![afu](/assets/images/article/auto-fu.png)

解决办法：这里没有提供选项，只能通过修改源码了，去掉`_message ...`这句话就OK。补全的消息本身就带有correction提示，就不需要重复的提示了。

## 添加toggle

这个插件虽然在功能性上有一定的作用，但是我想大多数人会认为比较鸡肋，尤其是补全消息很多的情况下会发生卡顿，就得不偿失了，我觉得我需要开关它的机制。

自带的widget名为`auto-fu-toggle`只能开关正在处理的这行，而真正是否使能该插件的因素在于之前提到的zle-line-init，没有想到更好的解决方案的情况下，我添加了如下widget：

{% highlight sh %}
toggle-auto-fu() {
    if (( $+disable_auto_fu )); then
        zle-line-init () {
            auto-fu-init
        }
        zle -N zle-line-init
        unset disable_auto_fu
        auto-fu-init
    else
        zle -D zle-line-init
        auto-fu-deactivate
        disable_auto_fu=1
    fi
}
zle -N toggle-auto-fu
bindkey '^O' toggle-auto-fu
bindkey -M afu '^O' toggle-auto-fu
{% endhighlight %}

注意这里需要bind两次，因为在使能和非使能的情况下，keymap所属的组是不同的。这个toggle函数能在当前行以及之后的所有行产生作用，正是我想要的效果。另外，由于keymap发生变化，之前的widget需要重新复制一份，另外切换至afu-vicmd的默认快捷键略繁琐，改成ESC。

{% highlight sh %}
bindkey -M afu '^T' fzf-file-widget
bindkey -M afu '^L' fzf-cd-widget
bindkey -M afu '^H' fzf-history-widget
bindkey -M afu '\e' afu+vi-cmd-mode
bindkey -M afu-vicmd 'k' history-substring-search-up
bindkey -M afu-vicmd 'j' history-substring-search-down
bindkey -M afu-vicmd 'cc' vi-change-whole-line
{% endhighlight %}

顺便一提，fzf和history-substring-search确实能提高不少的效率，谁用谁知道。

我在折腾的过程中，无意搜到这个很有意思的玩意：

{% highlight sh %}
autoload -U tetris
zle -N tetris
bindkey '^T' tetris
{% endhighlight %}

有意思的地方是，如果直接执行tetris，会输出`Use M-x tetris RET to play tetris.`的提示;-)。

zsh的功能十分复杂，我也就是带着不求甚解的心态折腾着玩罢了。
