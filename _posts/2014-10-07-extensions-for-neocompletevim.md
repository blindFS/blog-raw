---
layout: post
title: "Extensions for neocomplete.vim"
description: ""
category: cheatsheet
tags: vim vimwiki
---
{% include JB/setup %}

## Fix of vimwiki file completion

In a [previous post](/tweak/2014/07/20/vimwiki-file-completion), I've mentioned
a omnifunc way to achieve the goal.

Later, I found out that where was a critical flaw with that method. Something weird will
happen when the following situations are met:

* *context_filetype.vim* installed, say if the ft detected within the block is C.
* `let g:neocomplete#force_omni_input_patterns.c = 'pattern'`.
* The expression waiting for completion matches the given pattern.

`Don't panic!`

There's always another way. And it's a better way in this case.

### An extension for neocomplete.vim

First of all, the code:

{% highlight vim %}
let s:source = {
            \ 'name': 'vimwiki',
            \ 'kind': 'ftplugin',
            \ 'filetypes': {'vimwiki': 1},
            \ 'mark': '[image]',
            \ 'max_candidates': 15,
            \ 'is_volatile' : 1,
            \ }

function! s:source.gather_candidates(context)
    let line = getline('.')
    let start = match(line, '\v\{\{.{-}\/\zs') " god damn liquid exception
    if start == -1
        return []
    endif
    let line = line[start :]
    let prefix = matchstr(line, '.*\/')
    let end = match(line, '}}$')
    let a:context.complete_str = line[len(prefix): end-1]
    let a:context.complete_pos = start+len(prefix)
    let path = g:vimwiki_list[0].path_html . prefix
    let output = system('ls ' . path)
    if output =~ 'No such file or directory'
        return []
    endif
    let list = split(output, '\n')
    return list
endfunction

function! neocomplete#sources#vimwiki#define()
    return s:source
endfunction
{% endhighlight %}

* The structure of a neocomplete.vim plugin is much like one for unite.vim, and it's easy to imitate.
* The keys in s:source are self-explanatory
* The gather_candidates function acts like a complete_func but it's called only once.
    * The start position of the text to be completed are stored in `a:context.complete_pos`
    * `a:context.complete_str` is used to filter the resulting list automatically. (have to explicitly filter the result in a omnifunc)
    * Both of them are not exactly correct by default in this case, so I have to manually set their values.

## neco-look

* It is a recommended extension mentioned in the doc of neocomplete.vim.
* It helps typing in English by words completion.
* The Executable *look* with proper dictionaries is required for this plugin.
    * For Arch users, `community/words` might be useful.

There is a little trick to enable it with vimwiki.

* First of all, this bundle should be loaded with neocomplete.vim, lazily. In order to do so, I use the *depends* key of neobundle.vim
* Set `g:neocomplete#text_mode_filetypes.vimwiki` to 1, since neco-look only works when `neocomplete#is_text_mode()` or `neocomplete#within_comment()` returns 1
