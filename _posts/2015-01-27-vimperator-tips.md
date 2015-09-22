---
layout: post
title: "Vimperator tips"
description: ""
category: tips
tags: vimperator javascript vim
---
{% include JB/setup %}

## vimperator是什么鬼？

对于找到这的人来说，这是个无聊的问题，没办法，好久没写东西了，缺乏基本的文字内容组织能力，
只好遵循渐进的法则...

vimperator 是一个firefox扩展，有很强的可定制性，很好玩，神器，以上。
类似的东西有[Pentadactyl](http://5digits.org/pentadactyl/)(不支持最新的ff),[VimFx](https://github.com/akhodakivskiy/VimFx)(功能比较简单)。

好吧，接下来我分享一些vimperator的[配置](https://github.com/blindFS/dotfiles/blob/master/.vimperatorrc)。

## 个人偏好options设置

以下配置都写入.vimperatorrc文件，这个应该都知道...

{% highlight vim %}
set hintchars=abcdefghijklmnopqrstuvwxyz " 默认使用数字，不如字母好按
set suggestengines=''                    " 不使用google等搜索引擎进行页面推荐，为了加快速度
set gui=nonavigation                     " 隐藏nav-bar
set focuscontent                         " 打开页面之后默认进入normal-mode
set wildmode=list:full                   " 补全选项
set noscrollbars                         " 隐藏scrollbar，因为底部已经有百分比了
set animations                           " vimperator自己的动画效果
colorscheme indigo                       " 网上找的配色，默认的略丑
{% endhighlight %}

## 禁止Ctrl+Q直接退出firefox

浏览器一般会打开好几十个页面，万一按错键导致退出，要重启的话需要等待相当长的时间。
另外我把Ctrl-Q设置成了tmux的prefix(其实这是个非常2的决定，按习惯了，懒得改)。
vimperator除了类似vi的默认快捷键之外，支持自定义几乎所有按键，语句与vim非常类似，包括nmap,imap,cmap。

那么要实现这个功能就非常的简单，`nnoremap <C-Q> <C-W>`，设置成了关闭tab的功能。
同时，vimperator提供了退出firefox的默认按键ZZ，极大的降低了误操作的可能。

## 添加pin-tab和unpin-tab的功能

除了按键之外，作为一个神器，当然支持自定义ex命令了。当然你也可以把它绑定到某个按键上...

{% highlight vim %}
command! pin :set apptab
command! unpin :set noapptab
{% endhighlight %}

## 进入hint模式后自动禁用中文输入法

按f或者F进入，这是一个非常核心的功能，主要就是靠它解放鼠标，
因此如果因为输入法问题需要进行多余操作的话会非常痛苦。如下解决方案适用于fcitx。

{% highlight vim %}
nnoremap <silent> f :silent !fcitx-remote -c<CR>f
nnoremap <silent> F :silent !fcitx-remote -c<CR>F
nnoremap <silent> : :silent !fcitx-remote -c<CR>:
{% endhighlight %}

## 通过gui选项实现类似The-fox-only-better的效果

The-fox-only-better是一个很赞的ff扩展，在twitter上看到有人推荐之后使用了一段时间，
这个扩展和vimperator可以非常完美的共存，之所以把它去掉，是因为我在修改tab-bar的样式之后，如果
不禁用它会导致tab-bar下方一直有一条2px左右的白线，轻微强迫症，不太能接受...
另外其实鼠标hover呼出nav-bar的功能我也不太需要，最近崇尚极简主义，所以...

{% highlight vim %}
nnoremap <C-L> :set gui=navigation<CR><C-L>
nnoremap <Esc> <Esc>:set gui=nonavigation<CR>
{% endhighlight %}

## 类似stylish的功能

vimperator提供了一系列跟stylish类似的功能，具体可以参见 `:h :style`

创建一个style的基本格式如下:

{% highlight vim %}
style -name style_name chrome://url-pattern <<EOM
    some-css-snippet
EOM
{% endhighlight %}

之后可以使用如下命令进行控制:

* styledisable
* styleenable
* styletoggle

原本我打算删除stylish，全部通过这样的方式进行管理，但是不久我发现这样不太靠谱，因为自己写的style毕竟少，
多数是通过 userstyles.org 安装的，好在[vimperator-plugins](https://github.com/vimpr/vimperator-plugins)中
提供了一个stylish的管理插件，只要在.vimperatorrc中source它就行了。

BTW，我通过stylish安装了一些网站的dark主题，而vimperator自带的功能则用来管理浏览器的界面样式，分工明确~
我抄了[这个](https://userstyles.org/styles/102262/twily-s-powerline-firefox-css)的一段css，把tab-bar改成了powerline的风格，
跟awesome wm的powerline很搭~~

![ff-pl](/assets/images/article/firefox-powerline.png)

## 通过vimperator的接口实现Open With的功能

对我来说使用Open With主要是为了用you-get，bilidan之类的工具来播放视频，我需要将这个功能
绑定到一个按键(之后介绍通过autocmd实现自动化)，现有的Open With不能满足我的需求。

`Don't panic!`，在MDN手册和google的帮助下，我写了一个vimperator-plugins: open-with.js ，代码如下:

{% highlight javascript %}
commands.addUserCommand(
    ['openwith'],
    'Open current url with external commands',
    function(args){
      var URL = buffer.URL;
      var Cc = Components.classes;
      var Ci = Components.interfaces;
      var file = Cc["@mozilla.org/file/local;1"]
        .createInstance(Ci.nsILocalFile);
      var environment = Cc["@mozilla.org/process/environment;1"]
        .getService(Ci.nsIEnvironment);
      var path = environment.get("PATH").split(':');
      for (var i=0; i < path.length; ++i) {
        file.initWithPath(path[i]+'/'+args[0]);
        if (file.exists())
          break;
      }
      liberator.echo('Opening with '+args.shift());
      args = args.concat([URL]);
      var process = Cc["@mozilla.org/process/util;1"]
        .createInstance(Ci.nsIProcess);
      process.init(file);
      process.run(false, args, args.length);
    },
    {
      completer: function (context) completion.shellCommand(context)
    },
    true
    );
{% endhighlight %}

使用方法也是先在.vimperatorrc里source，然后`:openwith shellcommand`。

## 一键开关flash-player

恼人的flash有的时候不得不使用，因此你需要如下配置：

{% highlight vim %}
javascript <<EOM
function toggle_flash() {
  var oldvar = options.getPref('plugin.state.flash');
  if (oldvar > 0)
    liberator.echo('flash-plugin disabled.');
  else
    liberator.echo('flash-plugin enabled.');
  options.setPref('plugin.state.flash', 2-oldvar);
}
EOM

command! flashtoggle :js toggle_flash()
nnoremap <C-F> :flashtoggle<CR>
{% endhighlight %}

Note:Ctrl-F默认是page-down，但是有j了，无所谓就覆盖掉吧。

## 通过autocmd解决google inbox的访问

参考[这个](https://gist.github.com/VictorBjelkholm/1d0f4ee6dc5ec0d6646e)。
实现:

{% highlight vim %}
javascript <<EOM
function inbox_enable() {
  options.setPref('general.useragent.override',
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 ' +
    '(KHTML, like Gecko) Chrome/39.0.2171.99 Safari/537.36');
  options.setPref('security.csp.enable', false);
}

function restore_from_inbox() {
 options.resetPref('general.useragent.override');
 options.setPref('security.csp.enable', true);
}
EOM

autocmd LocationChange .* js restore_from_inbox()
autocmd LocationChange inbox\\.google\\.com js inbox_enable()
{% endhighlight %}

## 通过autocmd在flash禁用的情况下实现自动播放

{% highlight vim %}
javascript <<EOM
function execute_if_no_flash(command) {
  if (options.getPref('plugin.state.flash') == 0)
    liberator.execute(command);
}
EOM

command! youplayer :openwith youplayer
command! bilidan :openwith bilidan
autocmd PageLoad v\\.youku\\.com js execute_if_no_flash('youplayer')
autocmd PageLoad www\\.bilibili\\.com/video/av js execute_if_no_flash('bilidan')
{% endhighlight %}

只是举个简单的例子，需要用到上文提到过的open-with.js，其实也可以在toggle_flash函数中添加/删除autocmd来处理，
不过那样不够灵活。

## 一些有用的plugin

上边提到过[vimperator-plugins](https://github.com/vimpr/vimperator-plugins)这个repo，里面的插件数不胜数，
我目前用到的有:

* stylish 上文已经提及
* tabsort 给tab排序
* feedSomeKeys 必须，在某些页面上禁用某些快捷键
* goo.gl url 压缩
