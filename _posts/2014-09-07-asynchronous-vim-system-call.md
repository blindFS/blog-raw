---
layout: post
title: "Asynchronous vim system call"
description: ""
category: tweak
tags: vim
---
{% include JB/setup %}

## 利用扩展语言的线程库

这种方法在上篇文章中已经介绍过了，由于vim自身的限制，
这其实并不是一种好的方法。

## 利用 vimproc

调用案例:

{% highlight vim %}
let s:vimproc = vimproc#pgroup_open("sleep 10 | echo 'hello'")
call s:vimproc.stdin.close()
let s:result = ""

augroup vimproc_async_test
    autocmd! CursorHold,CursorHoldI * call s:receive_vimproc_result()
augroup END

function! s:receive_vimproc_result()
    if !has_key(s:, "vimproc")
        return
    endif

    let vimproc = s:vimproc

    try
        if !vimproc.stdout.eof
            let s:result .= vimproc.stdout.read(1000, 0)
        endif

        if !vimproc.stderr.eof
            let s:result .= vimproc.stderr.read(1000, 0)
        endif

        if !(vimproc.stdout.eof && vimproc.stderr.eof)
            return 0
        endif
    catch
        echom v:throwpoint
    endtry

    augroup vimproc_async_test
        autocmd!
    augroup END

    call vimproc.stdout.close()
    call vimproc.stderr.close()
    call vimproc.waitpid()
    echom s:result
    unlet s:vimproc
    unlet s:result
endfunction
{% endhighlight %}

简单说明:

* 使用 vimproc#pgroup_open 创建进程，详情参见 vimproc 文档。
* 使用单次的 autocmd 来实现交互。触发条件是 CursorHold，因此需要额外等待
上至 &updatetime 的时间。

## 利用 clientserver

这是一种简单的方法，但是由于对 vim servier 的强制需求，并不能在插件中使用。
使用方法:

1. 启动 server `vim --servername VIM`
2. 执行 remote-send `sleep 3; vim --remote-send ':echom 3<CR>'`

## unite.vim source 中的 async_gather_candidates

unite.vim 提供了一个异步机制，简单来说，当 context 中的
is_async 值为1时，每隔 &updatetime 执行一次 async_gather_candidates 函数。
因此，通常采用如下的使用方式。

1. 使用 vimproc 创建进程对象。
2. 在 async_gather_candidates 函数中，检测进程对象的 stdout，并将结果添加入 candidates 并返回。
3. 在 async_gather_candidates 中需检测进程的结束状态，如果结束，则将 context 中的 is_async 置0。
