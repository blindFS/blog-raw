---
layout: post
title: "replace deprecated vim plugins with modern alternatives"
description: ""
category: config
tags: linux vim powerline
---
{% include JB/setup %}

### replacement list

* taglist             - tagbar
* conqueTerm          - vimshell
* fuzzyfilefinder/mru - CtrlP/unite
* snipmate            - neosnippet
* neocomplecache      - neocomplete
* powerline           - airline
* csscolor            - colorizer

#### window to view tags

No matter which perspective are we in,'tagbar' is just much better than 'taglist'.
Along with 'Taghighlight' just makes 'tagbar' looks fantastic.
What's more,it is easy to customize for all filetypes and works perfect with the .ctags configuration.

**tagbar config**

{% highlight vim linenos %}
noremap <F1> :TagbarToggle<CR>
inoremap <F1> <ESC>:TagbarToggle<CR>
let g:tagbar_type_vimwiki = {
            \ 'ctagstype' : 'wiki',
            \ 'kinds'     : [
            \ 'h:headers'
            \ ]
            \ }
let g:tagbar_type_mkd= {
            \ 'ctagstype' : 'md',
            \ 'kinds' : [
            \ 'h:headings'
            \ ],
            \ 'sort' : 0,
            \ }
let g:tagbar_type_css= {
            \ 'ctagstype' : 'css',
            \ 'kinds' : [
            \ 'c:classes',
            \ 'i:ids',
            \ 't:tags',
            \ 'm:media',
            \ 'f:fonts',
            \ 'k:keyframes'
            \ ],
            \ 'sort' : 0,
            \ }
let g:tagbar_type_html= {
            \ 'ctagstype' : 'html',
            \ 'kinds'     : [
            \ 'i:ids',
            \ 'c:classes',
            \ ]
            \ }
let g:tagbar_type_vhdl = {
            \ 'ctagstype': 'vhdl',
            \ 'kinds' : [
            \'d:prototypes',
            \'b:package bodies',
            \'e:entities',
            \'a:architectures',
            \'t:types',
            \'p:processes',
            \'f:functions',
            \'r:procedures',
            \'c:constants',
            \'T:subtypes',
            \'r:records',
            \'C:components',
            \'P:packages',
            \'l:locals'
            \]
            \}
{% endhighlight %}

#### term with vim

I don't use gvim much,So this one is not necessary for me,but it's cool to have.
Compared to 'conqueTerm','VimShell' is much faster,less buggy and better integrated with vim itself.
For example,when you type `vim filename` inside 'VimShell',it just open/create another buffer.
And when you type `exit`,nothing else happens but current shell buffer closes.
What's more,it uses vim popup for shell complete.

**VimShell config**

{% highlight vim linenos %}
let g:vimshell_enable_smart_case   = 1
let g:vimshell_prompt              = '➤  '
let g:vimshell_user_prompt         = 'fnamemodify(getcwd(), ":~")'
let g:vimshell_right_prompt        = 'system("date")'
let g:vimshell_temporary_directory = "~/tmp/vimshell"
{% endhighlight %}

#### fast file access

I have to say All of these 4 plugins are awesome,but the old ones are just as good as 'sublime' builtins.
However,'CtrlP' and 'unite' are much more powerful and extensible,especially 'unite'.
You can find a bunch of extensions for 'unite' [here](https://github.com/Shougo/unite.vim/wiki/unite-plugins).
What I see is that 'unite' is a really promising framework for vim plugin development.Maybe someday,when I come up with
an idea beyond existing plugins,I will probably try something based on it.
And I have a overview look of maybe less than 5% of its power,yet,I find 3 unique things really useful.

* \:Unite output
    This one is awesome because it allow you to search through basically all of the info of your vim environment
     such as variables/mappings/highlights/settings.
    Without it,you will have to redir those info to a register,end that redir and then paste it in somewhere in a buffer.It's painful.

* \:Unite snippet
    This is really useful for someone poor in memory like me.I often forget the syntax of a certain language.
    This is like a cheatsheet.It will show you all of the snippet of current filetype.
    So,even if you've never heard a language before,you could try to program with it.It works perfect with 'neosnippet'.
    'VimShell','unite','neosnippet' are from a single great vimer [Shougo](http://vinarian.blogspot.com/).
    That maybe why I choose 'neosnippet' over 'snipmate'.

* \:Unite locate
    This function comes from a extension,it uses the shell command 'locate' to fast find any file in the file system.

Currently,I have not totally replace 'CtrlP' with 'unite' yet.Because I am used to search file/tag/function with 'CtrlP'.
But I believe,someday in the future when I get used to the unite way,I'll remove 'CtrlP' as well.

**CtrlP/unite config**

{% highlight vim linenos %}
let g:ctrlp_map                 = '<C-space>'
let g:ctrlp_cmd                 = 'CtrlP'
let g:ctrlp_show_hidden         = 1
let g:ctrlp_use_caching         = 1
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_cache_dir           = $HOME.'/tmp/ctrlp'
let g:ctrlp_extensions          = ['funky']
nnoremap <F5> :CtrlPFunky<CR>
nnoremap <F6> :CtrlPChange<CR>
nnoremap <F7> :CtrlPTag<CR>
set wildignore+=*/.cache/*,*/tmp/*,*/.git/*,*/.neocon/*,*.log,*.so,*.swp,*.zip,*.gz,*.bz2,*.bmp,*.ppt
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe,*.dll

let g:unite_enable_ignore_case  = 1
let g:unite_enable_smart_case   = 1
let g:unite_enable_start_insert = 1
let g:unite_winheight           = 10
let g:unite_split_rule          = 'botright'
let g:unite_prompt              = '➤ '
let g:unite_data_directory      = $HOME.'/tmp/unite'
command!  Mru :Unite file_mru
command!  Uhelp :Unite help
nnoremap <leader><space>b :Unite -quick-match buffer<CR>
nnoremap <leader><space>f :Unite file<CR>
nnoremap <leader><space>l :Unite locate<CR>
nnoremap <leader><space>u :Unite source<CR>
{% endhighlight %}

#### modern complete engine

Shouge says 'If you use Vim 7.3.885 or above with if_lua feature, you should use neocomplete. It is faster than neocomplcache.'
And I've migrated to 'neocomplete' without pain.It use cache to accomplish key word completion and it just take full advantage of the builtin omnicomplete.
I dislike 'youcompleteme',both because of its stupid name and the fact that it only support c family.
I choose 'neocomplete' along with 'clang-complete',and they beats 'youcompleteme' in any aspect.

**neo config**

{% highlight vim linenos %}
let g:neocomplete#enable_at_startup       = 1
let g:neocomplete#disable_auto_complete   = 1
let g:neocomplete#enable_ignore_case      = 1
let g:neocomplete#enable_fuzzy_completion = 1
let g:neocomplete#data_directory          = '~/tmp/.neocomplete'

" let g:neosnippet#enable_preview = 0
" set completeopt+=preview
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)"
            \: pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)"
            \: "\<TAB>"

if has('conceal')
    set conceallevel=2 concealcursor=i
endif
{% endhighlight %}

#### just abandon the vim-powerline

I found vim-airline a week ago.At first,I hate it because its default theme is really ugly.And I thought it was useless to reinvent the wheel.
But after a detailed glimpse,I realized that it's much better that the old deprecated 'vim-powerline'.Its code is elegant.There are many amazing themes as well(really not don't know
 why the author don't change the default one).And it is much easier to create a theme and apply it.Most of all,it is much much faster than 'vim-powerline' while accomplishing every single function of 'vim-powerline' and plus.

If you have read [this article](/config/2013/07/25/trailing-whitespace-marker-segement-on-vim-powerline/),you may remember how much it bothers to just add a single additional section to 'vim-powerline'.
However,with vim-airline,you only need 2 more lines in `bundle-path/vim-airline/autoload/airline.vim` ----- the last 2 lines in the following code block.

{% highlight vim linenos %}
if !s:getwinvar(a:winnr, 'airline_left_only', 0)
let sl.='%='.g:airline_externals_tagbar
let sl.=' '.s:get_section(a:winnr, 'x').' '
let sl.=l:info_sep_color
let sl.=a:active ? g:airline_right_sep : g:airline_right_alt_sep
let sl.=l:info_color
let sl.=' '.s:get_section(a:winnr, 'y').' '
let sl.=l:mode_sep_color
let sl.=a:active ? g:airline_right_sep : g:airline_right_alt_sep
let sl.=l:mode_color
let sl.=' '.s:get_section(a:winnr, 'z').' '
let sl.="%#Al3#"
let sl.='%{g:airline_detect_white_space && search(" $","nw") ? " ✹ " : ""}'
{% endhighlight %}

The first one only indicate the color to use,so it's alternative which means just 1 line will be good to go.No need to autocmd,so it interacts synchronously(there is delay in 'vim-powerline').
It is also easy if you want that to become a entire section in order to insert the separator with a different color which in my opinion,is stupid.
BTW,airline has an well specified version for 'unite' which is the initial inspiration for me to try it.
