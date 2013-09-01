---
layout: post
title: "Use pygments with vimwiki"
description: ""
category: tweak
tags: vim python vimwiki
---
{% include JB/setup %}

## Why not using syntaxhighlighter ##

vimwiki 官方推荐的高亮方式是通过[ 这个玩意 ](https://code.google.com/p/syntaxhighlighter/)。
这玩意无比蛋疼。首先，不同的语言要引用不一样的js。如果要把全部的js引入模板就显得很傻逼。
虽然貌似可以用Autoload来动态加载，但是还是[ 很麻烦 ](http://yysfire.github.io/vim/%E5%9C%A8VimWiki%E4%B8%AD%E4%BD%BF%E7%94%A8SyntaxHighlighter%E5%AE%9E%E7%8E%B0%E4%BB%A3%E7%A0%81%E8%AF%AD%E6%B3%95%E9%AB%98%E4%BA%AE.html)。
而且提供的语言还只有那么几种。
相比之下jekyll使用的pygments就好处多多了。别的不提，光是改配色就方便（全是css）。
不明白为啥vimwiki不采用pygments来处理代码块。

`Don't panic!`

既然pygments提供了方便的[ 命令行工具 ](http://pygments.org/docs/cmdline/)。
那么我想，通过修改vimwiki的代码来试用它应该不困难。于是我尝试了一下。

## Solution ##

[ Gist ](https://gist.github.com/farseer90718/6363367). BTW，gist这个玩意还真好用，gist.vim这个插件也非常牛叉。之前都没察觉...
通过修改`autoload/vimwiki/html.vim` 下的**process_tag_pre**函数来达到效果。
该文件中的函数主要用于将wiki转成html。由于不想改变这个函数的调用方式(逐行)，新的函数显得有些2，当读到非头非尾的行时，只是将其加到一个全局变量，而返回空的list。只有遇到结束标记
的时候才调用pygmentize。这样看上去很不环保，但是这整个过程的速度还是非常的快，所以也没啥说的。至于为啥非得用一个临时文件来存放代码块的内容，我感觉用其他的方法不太安全，毕竟代码块内部
有各种乱七八糟的符号。万不得已，虽然恶心了点，但是安全。
不贴代码的话文章貌似有点短...

ps：为了配合我写的[这个插件](/config/2013/08/21/vim-markdown-syntax-improvement)，由于pygments里头的lexer名称跟vim下的syntax的名称不一定相同只好用一个字典来转换（11-13行）。

{% highlight vim linenos %}
{% raw %}
function! s:process_tag_pre_pygments(line, pre)
  if !executable('pygmentize')
    return s:process_tag_pre(a:line, a:pre)
  endif
  let lines = []
  let pre = a:pre
  let processed = 0
  if !pre[0] && a:line =~ '^\s*{{{'
    let s:syntax = matchstr(a:line, 'class="\zs\w\+')
    let s:syntax = matchstr(a:line, 'class=.\zs\w\+')
    let s:syntax = s:syntax == "" ? "text" : s:syntax
    if exists("g:vimwiki_code_syntax_map['".s:syntax."']")
      let s:syntax = g:vimwiki_code_syntax_map[s:syntax]
    endif
    let s:lines_pre = ""
    let pre = [1, len(matchstr(a:line, '^\s*\ze{{{'))]
    let processed = 1
  elseif pre[0] && a:line =~ '^\s*}}}\s*$'
    let pre = [0, 0]
    let processed = 1
    redir! > ~/tmp/.pretemp
    silent! echo s:lines_pre
    redir END
    let lines = split(system("pygmentize -l ".s:syntax." -f html ~/tmp/.pretemp"),'\n')
  elseif pre[0]
    let processed = 1
    let s:lines_pre .= a:line."\n"
  endif
  return [processed, lines, pre]
endfunction
{% endraw %}
{% endhighlight %}
