---
layout: post
title: "ctags &lt; cscope &lt; gtags"
description: ""
category: config
tags: vim linux
---
{% include JB/setup %}

## ctags

2 month ago, I thought ctags was totally enough for navigating through c codes.
There is a plugin called [unite-tags](https://github.com/tsukkee/unite-tag) which takes advantage of the power of Unite.vim.
Also the ctags is very handy in other programming languages.
You can even DIY your own rules of tags generating with the configuration file [.ctags](https://gist.github.com/farseer90718/6315911).

However, problems with ctags:

* unite-tag takes a noticeable while to initialize the tags file when it's really big.
* There is not a efficient enough way to search within a certain scope of tags.

## cscope

When I started to read some codes of the linux kernel project. I finally can't put up with the inefficiency of ctags.
Others suggest that I use **sourceinsight**. I don't like it because:

1. not free.
2. not cheap.
3. can't afford it.
4. I hate wine.

And I believe that kernel contributers don't use that <del>piece of shit</del> to build the Rome.
So I tried cscope.
Really satisfied in:

* speed.
* accuracy.
* querytype.

I made some mappings so that I don't have to type something as long as `:cscope find foo bar` from time to time.

{% highlight vim %}
nnoremap <leader>cg :execute 'cscope find g '.expand('<cword>')<CR>
nnoremap <leader>cs :execute 'cscope find s '.expand('<cword>')<CR>
nnoremap <leader>cc :execute 'cscope find c '.expand('<cword>')<CR>
nnoremap <leader>ct :execute 'cscope find t '.expand('<cword>')<CR>
nnoremap <leader>cf :execute 'cscope find f '.expand('<cword>')<CR>
nnoremap <leader>ci :execute 'cscope find i '.expand('<cword>')<CR>
vnoremap <leader>cg <ESC>:execute 'cscope find g '.GetVisualSelection()<CR>
vnoremap <leader>cs <ESC>:execute 'cscope find s '.GetVisualSelection()<CR>
vnoremap <leader>cc <ESC>:execute 'cscope find c '.GetVisualSelection()<CR>
vnoremap <leader>ct <ESC>:execute 'cscope find t '.GetVisualSelection()<CR>
vnoremap <leader>cf <ESC>:execute 'cscope find f '.GetVisualSelection()<CR>
vnoremap <leader>ci <ESC>:execute 'cscope find i '.GetVisualSelection()<CR>

...

function! GetVisualSelection()
    let [s:lnum1, s:col1] = getpos("'<")[1:2]
    let [s:lnum2, s:col2] = getpos("'>")[1:2]
    let s:lines = getline(s:lnum1, s:lnum2)
    let s:lines[-1] = s:lines[-1][: s:col2 - (&selection == 'inclusive' ? 1 : 2)]
    let s:lines[0] = s:lines[0][s:col1 - 1:]
    return join(s:lines, ' ')
endfunction
{% endhighlight %}

## global/gtags

I almost have given up searching for better solutions since cscope is so satisfying.
However there is one thing that annoys me.

When I search for the definition of something, sometimes there are dozens of them in the database.
It seems that cscope can't understand the concept of definition very well.
And it will be OK, if it just put that dozens of entries to quickfix list like what it does for symbols.
But it just shows a long long list in a vim pager/more-prompt.

I was looking for something that can integrate cscope with unite.vim or quickfix maybe before I discovered gtags/global.

I took a glimpse at the tutorial and tried it.
The features that appeal to me:

* work the same way across diverse environments: vim/emacs/bash/browser/doxygen
* fast & accurate(better than cscope)
* search not only in a source project but also in library projects
* various output format(for quickfix)
* customizable like ctags
* regular expression like cscope
* gtags-cscope (cscope compatible)

### basic setup

.profile

{% highlight sh %}
export GTAGSROOT=/foo/bar # project root
{% endhighlight %}

vim-plugin

[unite-gtags](https://github.com/hewes/unite-gtags)
[gtags.vim](https://github.com/vim-scripts/gtags.vim)

vim config

{% highlight vim %}
set csprg=gtags-cscope
cscope add /foo/bar/GTAGS

...

nnoremap <leader>gg :execute 'Unite gtags/def:'.expand('<cword>')<CR>
nnoremap <leader>gc :execute 'Unite gtags/context'<CR>
nnoremap <leader>gr :execute 'Unite gtags/ref'<CR>
nnoremap <leader>ge :execute 'Unite gtags/grep'<CR>
vnoremap <leader>gg <ESC>:execute 'Unite gtags/def:'.GetVisualSelection()<CR>
{% endhighlight %}
