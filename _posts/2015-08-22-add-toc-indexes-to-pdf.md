---
layout: post
title: "Add TOC indexes to PDF"
description: ""
category: tweaks
tags: vim EVA 中二病
---
{% include JB/setup %}

## PDF books without Indexes are like Planets with Individuals

I prefer e-books to paper books, actually I may have read only 1-2 paper books in recent 3 years, while e-books of a much larger amount. The pros of e-books are really obvious:

1. portability
2. context can be copied
3. easy to manage
4. easy to navigate

I don't want to argue about the superiorities here. I just wanna to convey that the 4th feature is a crucial one, and it is mainly achieved via indexes, bookmarks, reference links, etc. There's no doubt that among those approaches, indexes play the most significant role. So I say that e-books without indexes are like planets with individuals, i.e. huge gaps among separated pieces of text.

## Indexes Instrumentality Project

Well, if you encounter such planets, `Don't Panic!` Please pick up the holy weapons, smash the individuals and reunite them as a strongly connected conglomerate. You may need to carry these handy weapons:

1. vim
2. pdftk

### First Impact

1. Dissect the "[Black Moon](http://wiki.evageeks.org/Black_Moon)" to get the seed of life [Lilith](http://wiki.evageeks.org/Lilith), `pdftk earth.pdf dump_data > Lilith`
2. Next, form the [A.T. Field](http://wiki.evageeks.org/A.T._Field), simply copy the catalog from the file. If it's a scanned version, some kind of OCR weapon will help
3. Use vim to reshape (macros shall be helpful) the A.T. Field into the form of human egos, A.K.A. 心の壁:

{% highlight text %}
1 Chap1:title                 1
1.1 Chap1-Sec1:title          4
1.1.1 Chap1-Sec1-Para1:title  9
1.1.2 xxxx                    10
2 Chap2:title                 20
...
{% endhighlight %}

### Destroy the A.T. Field of egos

Piercing human egos with the [Spear of Longinus](http://wiki.evageeks.org/Spear_of_Longinus) (vimscript):

{% highlight vim %}
:'<,'>s#\v(\s*)([0-9.]+ )(.* )(\d+)#\="BookmarkBegin\rBookmarkTitle: ".submatch(2).submatch(3)."\rBookmarkLevel: ".len(split(submatch(2), '\.'))."\rBookmarkPageNumber: ".(submatch(4)+offset)
{% endhighlight %}

After that, souls of the following form will occur:

{% highlight text %}
BookmarkBegin
BookmarkTitle: 1 Chap1:title
BookmarkLevel: 1
BookmarkPageNumber: 16
BookmarkBegin
BookmarkTitle: 1.1 Chap1-Sec1:title
BookmarkLevel: 2
BookmarkPageNumber: 19
BookmarkBegin
BookmarkTitle: 1.1.1 Chap1-Sec1-Para1:title
BookmarkLevel: 3
BookmarkPageNumber: 24
BookmarkBegin
BookmarkTitle: 1.1.2 xxxx
BookmarkLevel: 3
BookmarkPageNumber: 25
BookmarkBegin
BookmarkTitle: 2 Chap2:title
BookmarkLevel: 1
BookmarkPageNumber: 35
...
{% endhighlight %}

* Here the "offset" is taken as 15, which means the very first page of the book lies in the 16th page of the PDF file due to the tedious bullshit at the beginning.
* If no section numbers provided, indentations will be good indicators of the bookmark levels

### Third Impact

1. Souls shall be gathered into Lilith's egg, `cat souls >> Lilith`.
2. Unite as a single existence, `pdftk earth.pdf update_info Lilith output reborn.pdf`.

Done.

## References

* [vimdoc sub-replace-expression](http://vimdoc.sourceforge.net/htmldoc/change.html#sub-replace-expression)
* [pdftk-man-page](https://www.pdflabs.com/docs/pdftk-man-page/)
* [新世紀エヴァンゲリオン](http://www.evangelion.co.jp/)
