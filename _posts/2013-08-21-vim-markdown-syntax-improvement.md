---
layout: post
title: "Vim markdown syntax improvement"
description: ""
category: config
tags: vim liquid
---
{% include JB/setup %}

### Requirements ###

* Liquid template code block highlight with specific syntax.
* The entire syntax process is silent and fast enough.
* Dynamic syntax when content changes.

### Accomplished ###

* Dynamic syntax region highlighting for markdown/vimwiki.
* Manual highlight selected block.
* Allow users to create new rules.

### Implement ###

[git repo](https://github.com/farseer90718/vim-regionsyntax)

Most of the job is done by the following single function.

{% highlight vim linenos %}
function! s:TextEnableCodeSnip(filetype,start,end,textSnipHl) abort
    let ft=toupper(a:filetype)
    let group='textGroup'.ft
    if exists('b:current_syntax')
        let s:current_syntax=b:current_syntax
        unlet b:current_syntax
    endif
    try
        execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
        execute 'syntax include @'.group.' after/syntax/'.a:filetype.'.vim'
    catch
    endtry
    if exists('s:current_syntax')
        let b:current_syntax=s:current_syntax
    else
        unlet b:current_syntax
    endif
    execute 'syntax region textSnip'.ft.'
                \ matchgroup='.a:textSnipHl.'
                \ start="'.a:start.'" end="'.a:end.'"
                \ contains=@'.group
endfunction
{% endhighlight %}

`:h syn-include` for the details.

### An annoying bug ###

The rainbow-parentheses plugin stops it to behave normally if the **start** is started by parentheses.
It took me a lot of time to find this confusing bug.
Solution:
{% highlight vim linenos %}
let g:rainbow_load_separately = [
\   [ '*' , [['(', ')'], ['\[', '\]'], ['{', '}']] ],
\   [ 'tex' , [['(', ')'], ['\[', '\]']] ],
\   [ 'html' , [] ],
\   [ 'css' , [] ],
\   [ 'mkd', [] ],
\   [ 'wiki', [] ]
\   ]
{% endhighlight %}

BTW,this plugin is really buggy,and it seems to be deprecated by far.So maybe there is sth better.

### future work ###

* bug fix.
* better performance.
* dynamic comment string according to cursor position.
* dynamic formatoption/foldmethod/omnifunc... maybe.
