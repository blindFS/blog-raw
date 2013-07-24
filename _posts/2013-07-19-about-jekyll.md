---
layout: post
title:  "Sth about jekyll"
date:   19 Jul 2013
categories: jekyll
tags: liquid jekyll
---

本来打算用pelican的，但是我是个懒人，所以就用最简单的jekyll-bootrap了。
jekll用的是liquid template
其中最蛋疼的事情就是转义。
{{'{{"raw content"'}}}} 或者 {{"{{'raw content'"}}}}
而且content里不不能出现'}'
总之是很麻烦就对了。
_Don't panic!_
添加
{% highlight ruby linenos %}
module Jekyll
  class RawTag < Liquid::Block
    def parse(tokens)
      @nodelist ||= []
      @nodelist.clear
      
      while token = tokens.shift
        if token =~ FullToken
          if block_delimiter == $1
            end_tag
            return
          end
        end
        @nodelist << token if not token.empty?
      end
    end
  end
end
 
Liquid::Template.register_tag('raw', Jekyll::RawTag)
{% endhighlight %}
到_plugin下的raw_tag.rb
之后就可以使用
{{"{%raw%"}}}
{{"{%endraw%"}}}来转义了(看不懂ruby，以后再说)

<!--more-->

pelican有article summary的功能，jekyll没有找到啥现成的
搜索之后发现一个挺2的方法
{% highlight html linenos %}
{% raw %}
{% for post in site.posts limit:5 %}
<h2><a class="post_title" href="{{post.url}}">{{post.title}}</a></h2>
<div class="post-content">
    {% if post.content contains '<!--more-->' %}
        {{ post.content | split:'<!--more-->' | first }}
        <br/>
        <a href='{{post.url}}'>read more</a>
    {% else %}
        {{ post.content }}
        {% endif %}
</div>
<hr />
{% endfor %} 
{% endraw %}
{% endhighlight %}
( 当然为了显示以上的代码就用到了刚刚说的raw tag )
很好理解，但这么做需要在article里手动添加相应的more tag，虽然麻烦但是反倒显得自由
总之能用就行。

接下来添加相应的snippet到编辑器就ok了。
最后吐槽下css,各种宽度的布局我擦，蛋疼死俺了。
