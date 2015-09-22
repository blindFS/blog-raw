---
layout: post
title: "Vimperator tips 2"
description: ""
category: tips
tags: vimperator javascript
---
{% include JB/setup %}

## Ver 3.8.3 (release) gi触发错误

按键gi的作用是focus到当前页面的input/textarea/iframe，即进入类似vim中的input模式。
在该版本中概率出错(xpath相关，具体记不得了)。
解决办法很简单，安装[git版本](https://github.com/vimperator/vimperator-labs)就可以了。
刚开始看vimperator的源码，尚且不熟悉架构，但是buffer相关的默认按键执行的操作可以在
`/common/content/buffer.js`中找到。概述信息可以通过mappings module获取，通过
`:echo mappings.get(0, 'gi', '.*')`

## 快速复制markdown格式的url

方法来自g+ vimperator中文社区的owner 陈三，稍作改动:

{% highlight vim %}
javascript << EOM
function markdown_url() {
  var mdurl = '[' + buffer.title + '](' + buffer.URL + ')';
  util.copyToClipboard(mdurl);
  liberator.echo('copied:' + mdurl);
}
EOM

nnoremap <C-Y> :js markdown_url()<CR>
{% endhighlight %}

## proxy解决方案

在学校用openvpn十分无脑，到了家中觉得速度不理想，于是想到之前github送的
student pack包括DO的100刀，就架了个SS server。SS当然要配合
[pac](https://github.com/clowwindy/gfwlist2pac)使用。

那么浏览器用什么插件呢？选择不要太多，我之前是foxy proxy，但是界面复杂，不方便切换。
于是准备用vimp插件进行替换。其实完全可以自己写，只要改 `network.proxy.autoconfig_url`
和 `network.proxy.type` 两个option即可。但是已经有[现成的解决方案](https://gist.github.com/eagletmt/814452)，
直接拿来用。

### 在statusline显示proxy状态

一个自然的需求，另外因为轻微强迫症的关系，蛋疼地把statusline
改成了powerline风格了，代码过于丑陋就不贴了，
可以在[这里](https://github.com/blindFS/dotfiles/blob/master/.vimperatorrc)找到它们。

截个图展示一下:

![vimp-pl](/assets/images/article/vimpower.png)


## plugins

除了上一篇中提到的一些插件外，又发现了如下的玩意儿:

* smooziee : 使jk滚动时更加平滑
* caret-hint : caret-mode 相关
* imageextender : 图片快捷操作
* plugin_loader : 插件管理器

下面挑几个具体说明用法。

### plugin_loader

用的插件多了之后，每个都source一下显得比较多余，可能需要一个插件管理器。
使用方法:

1. 设置 `g:plugin_loader_roots` 为插件文件所在目录
2. 设置 `g:plugin_loader_plugins` 为所需插件，字符串，逗号分割
3. source libly.js 和 plugin_loader.js

### caret mode

比较难以描述，具体请看 `:h caret-mode`。
总之在我看来主要是用来快速选择文字的，比如说你要选择页面上的某段 "select" 开头的文字
并且将其复制到剪贴板，如果不借助鼠标，那么一般的流程是:

1. /select搜索页面
2. normal模式下按c进入caret模式
3. 按v进入visual模式，通过wel等vi快捷键到达文字结尾
4. 按y复制

这么做有明显的不足:

* 多个matcher的时候经常搞不清光标位置
* 不利于处理各种unicode，比如中文

caret-hint就是解决这个问题的插件，为文字片段提供了类似link的hint模式，谁用谁知道。

### feedSomeKeys & ignorekeys

首先说我目前用到的feedSomeKeys的功能均可以通过自带的`:h :ignorekeys`命令替换。
顺便一提，normal模式下按i将ignore掉下一个按键，&lt;S-ESC&gt;则ignore all。
但是feedSomeKeys的强大不仅于此，它能够用于替换网页前端的按键，具体用法见文档。
