---
layout: post
title: "trailing whitespace marker segement on vim powerline"
description: ""
category: config
tags: vim powerline
---
{% include JB/setup %}

#### 国际惯例
![demo](/assets/images/whitespace_segement.png)

之前一直用的新版本的powerline，python实现，不光针对vim。但是后来发现跟vimscript的vim-powerline相比在vim下的功能差距太大，于是果断换回去。

虽然可能很无聊，但是我觉得提示trailing whitespace是个挺实用的功能，不明白为什么Lokaltog没有默认添加。
whatever，好歹人家提供了实现的方法。其实实现起来很简单，但是要符合powerline的那套声明语法并且不重不漏还是略费劲。
总之有 [现成的代码](https://github.com/Lokaltog/vim-powerline/commit/d885f900acfde8094f408b53ab61774bd0b83b13) 可以抄对我来说总是件好事。

但是其实以上的代码已经添加在最新的vim-powerline里了，但是却没有效果，细看发现需要在 **your-path/vim-powerline/autoload/Powerline/Themes/your-theme.vim** 中添加该segement到相应的位置，
就是所谓的'ws_marker',我喜欢把次要的东西放一边。

{% highlight vim linenos %}
let g:Powerline#Themes#solarized256#theme = Pl#Theme#Create(
    \ Pl#Theme#Buffer(''
        \ , 'paste_indicator'
        \ , 'fugitive:branch'
        \ , 'fileinfo'
        \ , 'flags.mod'
        \ , 'syntastic:errors'
        \ , Pl#Segment#Truncate()
        \ , Pl#Segment#Split()
        \ , 'sass:status'
        \ , 'rvm:string'
        \ , 'ws_marker'
    \ ),
    " ...
    )
{% endhighlight %}

神奇的是，这样之后还是没有效果，

**Don't panic!**

还需要一部操作就:PowerlineClearCache&lt;CR&gt;
ps:这个地方卡了俺好久，囧。
默认的ws_marker的配色跟paste_indicator是放在一起的，都是红色，我不喜欢红的，遂将其一并替换了。

发现white space之后就要trim。于是我添加了这样的东东

{% highlight vim linenos %}
command! TrimSpaces :call TrimSpaces()
    function! TrimSpaces()
        %s/\s\+$//gec
        normal ``
    endfunction
{% endhighlight %}

我觉得trim肯定是对全局，没必要加range所以就简单许多，另外我不喜欢替换完了之后光标移动到最后替换的地方。
于是用\`\`跳转到之前的地方。
anyway，能用就行。
