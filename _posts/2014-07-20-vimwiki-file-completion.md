---
layout: post
title: "Vimwiki file completion"
description: ""
category: tweak
tags: vimwiki vim regexp
---
{% include JB/setup %}

## What for?

We all know that vim provides us with a perfect filename completion
mechanism, aka `:h compl-filename`.

However, while editing vimwiki(or html maybe) files, the path specified
in a link is always a relative path to the project root, thus `CTRL-X CTRL-F`
stops working as expected.

`Don't panic!`

## Solution

First of all, we need a new completion function.

{% highlight vim %}
function vimwiki#OmniComplete(findstart, base)
    if a:findstart
        let line = getline('.')
        if line =~ '{'.'{local:.*'
            return searchpos('local:', 'bn', line('.'))[1] + 5
        endif
        return -3
    else
        let prefix = matchstr(a:base, '.*\/')
        let suffix = a:base[len(prefix):]
        let path = g:vimwiki_list[0].path . prefix
        let output = system('ls ' . path)
        if output =~ 'No such file or directory'
            return []
        endif
        let list = filter(split(output, '\n'), 'v:val =~ suffix')
        let list = map(list, 'prefix . v:val')
        return list
    endif

endfunction
{% endhighlight %}

The trick is we can get the vimwiki root path by referring to
the global variable `g:vimwiki_list`, which is a list of dicts representing
multiple vimwiki environments. In my case, only one root path, so I just
took the first element. Otherwise, maybe an iteration through all those paths is required.

As for what **findstart** and **base** mean, `:h complete-functions`.

Now, it's time to get it working with omnifunc and neocomplete.vim:

{% highlight vim %}
setlocal omnifunc=vimwiki#OmniComplete
if exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns.vimwiki = '{'.'{local:.*\/'
endif
{% endhighlight %}

* `'{'.'{xxx'` is just for escaping from liquid template, you know I won't write that to my config.

## Create a image viewing command

{% highlight vim %}
command! Feh :call ViewImage()
function! ViewImage()
    execute 'normal BvEy'
    let path = matchstr(@0, '\v((file|local):[/\\]*)=\zs[.~/].*\.(jpg|png|gif|bmp)')
    try
        if path != ''
            let path = &filetype == 'vimwiki' ? g:vimwiki_list[0].path . path : path
            silent! execute '!feh '.path.' &' | redraw!
        else
            let url = matchstr(@0, '[a-z]*:\/\/[^ >,;]*')
            silent! execute '!feh '.url.' &' | redraw!
        endif
    endtry
endfunction
{% endhighlight %}

* The pattern shown above works generally for many circumstances including markdown, vimwiki, plain text, url...
* I use feh as my default image viewer application. It's nice and neat, I like it.

## Demo

With proper snippet for vimwiki, it finally looks this, pretty cool, heh?

![demo](/assets/images/article/vimwiki.gif)
