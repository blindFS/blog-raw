---
layout: post
title: "boring stuffs"
description: ""
category: config
tags: vim regexp ruby jekyll liquid music 
---
{% include JB/setup %}

#### principles of blogging

Recently, I am learning how to build a personal blog(this one).And there are so many cool stuffs out there which has already made me
feel a bit lost.

I am supposed to record the knowledges I get throughout the process.
However,they are just too basic to be taken down.
I mean even if I forget some of them which generally speaking,are not commonly used,I just need to do some Google to recap.

* I feel that if something is really easy to get by searching or reading documents,it will be a totally waste of time for me to put it here.
* If it takes a bit of time to find while being very well stated elsewhere,I may put a link to help me redirect to the answer.
* those stuffs I try/customize/modify(that means boring and no use) will be uploaded.

#### add css and html support for vim tagbar

this is useless because it is really useless.
I tried this just because of my sickness.
when I happened to open the tagbar window(I set it to &lt;F1&gt;) while editing html/css files,it shows nothing and that annoys me.
Anyway,here is a section of my ~/.ctags file.It's just basic regexps which only suit my editing habit.

    --langdef=css
    --langmap=css:.css
    --regex-css=/^[ \t]*\.([ .:#A-Za-z0-9_-]+)[,{][ \t]*$/.\1/c,class/
    --regex-css=/^[ \t]*#([ .:#A-Za-z0-9_-]+)[,{][ \t]*$/#\1/i,id/
    --regex-css=/^[ \t]*([:A-Za-z0-9_-][ :#A-Za-z0-9_-]*)[,{][ \t]*$/\1/t,tag/
    --regex-css=/^[ \t]*@media\s+(.+)[,{][ \t]*$/\1/m,media/
    --regex-css=/^[ \t]*@font-face[ \t]*[,{][ \t]*$/font-face/f,font/
    --regex-css=/^[ \t]*@(-o-|-moz-|-webkit-){0,1}keyframes[ \t]*([A-Za-z0-9_-]+)[ \t]*[,{][ \t]*$/\1keyframes \2/k,keyframe/

    --regex-html=/<[ \t]*([A-Za-z]+[^\/>]*)[ \t]*>/\1/t,tag/

ctags version 5.9~svn20110310 does not support css filetype(there are patched ones which I thought are more useless),so I have to define it.Following are the regexps that I believe are not 100% correct.
but if you use comments carefully,there will be probably no big deal.
As for the font-face section I should use the font name as the item word.but I just failed to match newline symbol(not \n nor \r)

ctags does support html files but it will just generate tags for the inside js.
Ok.

now put these in .vimrc or whatever file loaded while initializing.

{% highlight vim linenos %}
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
        \ 't:tags'
    \ ]
\ }
{% endhighlight %}

actually I don't use tagbar ofen,but sometimes it is more efficient than simple search.

#### my first simple jekyll plugin ------ xiami tag for liquid template

I knew nothing about ruby,and I know almost nothing about ruby.But it doesn't bother to try something simple.
Use something like this ***{% raw %}{% xiami musicid %}{% endraw %}*** to generate the following embeded music player.

{% xiami 8137203_360063%}

It is also meaningless because when you get the music id,there is already a fully functioning embed tag in front of your eyes.
And it sucks because flash sucks.
the only adventage of this is to put your markdown file neat.
However,the song above is awesome!
Anyway,here's my xiami.rb:

{% highlight ruby linenos %}
class XiaMi < Liquid::Tag
    Syntax = /^\s*(\d+_\d+)\s*/
    def initialize(tagName, markup, tokens)
        super
        if markup =~ Syntax then
        @id = $1
        else
            raise "Illgeal ID presented."
        end
    end
    def render(context)
        "<embed src=\"http://www.xiami.com/widget/#{@id}/singlePlayer.swf\" type=\"application/x-shockwave-flash\" width=\"257\" height=\"33\" wmode=\"transparent\"></embed>"
    end
    Liquid::Template.register_tag "xiami", self
end
{% endhighlight %}
