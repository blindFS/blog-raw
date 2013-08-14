---
layout: post
title: "my new jekyll tag plugin"
description: ""
category: jekyll
tags: vim linux jekyll liquid regexp shell ツッコミ
---
{% include JB/setup %}

### Annoying problems

#### I compiled the brand new ` vim 7.4 beta ` (just added 'better python interface' feature accordingly ) yesterday.

It crashes a lot,but I don't know why......Hopefully,they will find out and fix it.

#### vim plugin problem

I also updated my vim-startify.But it,in my opinion,just made downgrade instead of improvement.

`Don't panic!`<br/>
they will be OK sooner or later.

#### fucking GFW

I haven't met this before.Every gems I try to install just "couldn't be found in any repository"!
First of all,I checked **gem sources** and it showed [http://rubygems.org](http://rubygems.org) without any problem.
So,I thought there might be something wrong with my gem configuration(actually,I haven't changed anything).
I stupidly **rm ~/.gem -rf**, reinstall **rubygems** with any version combination(1.9.3,1.9.1,1.8) and of cause nothing changed.
Then I Unconsciously *ping rubygems.org*.Holy shit, 100% lost!I could even open the web page with direct connection.
Problem solved.`gem install xxx --http-proxy=http://127.0.0.1:8087`
"8087" is a nice port for *DiaoSi*.And I have to use it even if it has security problems.

#### my zsh plugin to update packages

I use [antigen](http://github.com/zsh-users/antigen) for zsh plugins management and [vundle](https://github.com/gmarik/vundle) for vim.
And I have a habit of putting source code that I download/clone/checkout in this folder:**~/src**.

In order to keep them up to date,I wrote a zsh function to help me.And I just added **npm,gem,pear** support to it.

{% highlight bash linenos %}
function src-update () {
    eval curpath=$(pwd)
    eval gitpath=$(realpath $1)
    for i in $(find $gitpath -maxdepth 1 -type d)
        do
            cd $i
            eval repo=$(echo $i | gawk -F "/" '{print $NF}')
            if [[ -d ".git" ]]; then
                print "\n\33[32m****************\33[34mpulling $repo\33[32m****************\33[0m\n"
                git pull
            elif [[ -d ".hg" ]]; then
                print "\n\33[32m****************\33[34mpulling $repo\33[32m****************\33[0m\n"
                hg pull
                print "\n\33[32m****************\33[34mupdating $repo\33[32m****************\33[0m\n"
                hg update
            elif [[ -d ".svn" ]]; then
                print "\n\33[32m****************\33[34mupdating $repo\33[32m****************\33[0m\n"
                svn update
            elif [[ -d "CVS" ]] ; then
                print "\n\33[32m****************\33[34mupdating $repo\33[32m****************\33[0m\n"
                cvs update
            fi
        done
        cd $curpath
}

function repo-update {
    print "\n\33[32m*************************\33[34mnpm\33[32m**********************************\33[0m\n"
    sudo npm update -g
    print "\n\33[32m*************************\33[34mgem\33[32m**********************************\33[0m\n"
    sudo gem update --http-proxy=http://127.0.0.1:8087
    print "\n\33[32m*************************\33[34mpear\33[32m*********************************\33[0m\n"
    sudo pear upgrade
    print "\n\33[32m**************************************************************\33[0m\n"
    antigen update
    antigen selfupdate
    if [[ -d "$HOME/src" ]]; then
        src-update $HOME/src
    else
        echo "$HOME/src not exist"
    fi
}
{% endhighlight %}

Strictly speaking,It should check if there is a executable named 'git/hg/...'.But I do not expect anybody except me would use that.No need.

### I think this one is of some help

The XiaMi tag plugin was totally a joke.But this one,I believe,will be useful.
When I was writing the article about [color scheme](/fun/2013/07/25/youtube-geek-week-easter-egg/),I found it really inconvenient to make colorful text in markdwon files.
So here comes this one.

{% highlight ruby linenos %}
module Jekyll
class ColoredTag< Liquid::Tag
    Syntax = /^\s*(#[0-9a-fA-F]{6}|#[0-9a-fA-F]{3}|rgb[a]{0,1}\([ .0-9,]{5,}\))\s*(#[0-9a-fA-F]{6}|#[0-9a-fA-F]{3}|rgb[a]{0,1}\([ .0-9,]{5,}\))?\s*"([^"]*)"\s*$/
    def initialize(tagName, markup, tokens)
        if markup =~ Syntax then
            @bg = $1
            if $3.nil? then
                @fg = "#ffffff"
                @text = $2
            else
                @fg = $2
                @text = $3
            end
        else
            raise "Invalid colors"
        end
    end
    def render(context)
        "<div style=\"display: inline;background-color:#{@bg};color:#{@fg}\">#{@text}</div>"
    end
    Liquid::Template.register_tag('colored', Jekyll::ColoredTag)
end
end
{% endhighlight %}

basic usage:`{{'{% colored BGcolor (FGcolor) "any text except quotation marks"'}} %}`
If no FG specified,#fff will be used.And Both FG and BG color can be in #16,#256,rgb() or rgba() format.For example,
{% colored #000b10 rgb(255,140,100) " 我爱北京天安门,天安门前太阳升......" %}Ok,that's it.
