---
layout: post
title:  "Something about jekyll"
date:   19 Jul 2013
categories: jekyll
tags: liquid jekyll
---

本来打算用pelican的，但是我是个懒人，所以就用最简单的jekyll-bootrap了。
#### liquid template tag escape
jekll用的是liquid template，
其中最蛋疼的事情就是转义。
{{'{{"raw content"'}}}} 或者 {{"{{'raw content'"}}}}
而且content里不不能出现'}'
总之是很麻烦就对了。
`Don't panic!`
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
之后就可以使用{{"{% raw %"}}} {{"{% endraw %"}}}来转义了(看不懂ruby，以后再说)

另外因为liquid会把上接空行并且缩进的块当做highlight来处理。当这段代码块又存在于highlight tag内部的时候就很容易出问题。
原因很简单indent部分会将endhighlight部分包括在内从而导致最上边的highlight失配。
但是如果再嵌套一层raw tag在内部就没有这个问题了。
还有一点，如果不用highlight/raw tag包裹，那么html的[ special character ](http://www.w3schools.com/tags/ref_entities.asp)就需要处理。因为markdown本身就是允许html tag的。
处理办法嘛自然就是

    &lt;&gt;&nbsp;&quot;&apos;&amp;

之类的了。值得注意的是如果用raw tag包裹的话不论是特殊符号本身或者是对应的html代码，最终的显示结果都是特殊符号(因为raw会把liquid不能接受的东西转化成对应的能接受的内容，
同时保留所有liquid能接受的内容，这就很好理解了)。
ps:raw内双尖括号或者双单引号相连，这样：&lt;&lt;&gt;&gt;&apos;&apos;&apos;&apos;则会变为 {% raw %} <<>>'''' {% endraw %}(这个很好玩啊)

那么问题来了,如果highlight内嵌raw会怎样？

    {% raw %} {% highlight text %} {% endraw %}
        {{"{% raw %"}}} <<>>&lt;&gt;''""&apos;&quot; {{"{% endraw %"}}}
    {% raw %} {% endhighlight %} {% endraw %}
的结果如下，很明显是根据highlight的风格来处理的。

    {% raw %} <<>>&lt;&gt;''""&apos;&quot; {% endraw %}
反之如果是raw内嵌highlight的话，处理方式就是跟raw一样了。这是废话，应为highlight tag根本就不能生效。
还有一种可能是raw内嵌上接空格的缩进代码块，像这样：

    {{"{% raw %"}}} {% raw %}

        <<>>&lt;&gt;''""&apos;&quot;
    {% endraw %}{{"{% endraw %"}}}
结果会变成这样，意思就是说，还是按照highlight的那套来的。
{% raw %}

    <<>>&lt;&gt;''""&apos;&quot;
{% endraw %}
以上的这些看上去很绕，其实规则非常的简单，liquid对上接空格的缩进代码块的解析的优先级最高，然后是raw，最后是highlight。
这个结论当然是我猜测的，但是根据这个原则以上所有的现象就能解释通了。当然可以通过看源代码来验证，但是目测我看不懂,拉倒吧。

还有一点就是如果想在段落里头显示这样的字符&amp;lt;&amp;gt;&amp;nbsp;&amp;amp;这样的字符，那么就只需要对&amp;进行转义就行了。像这样：

    &amp;lt;&amp;gt;&amp;nbsp;&amp;amp;


#### index summary

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
{% endfor %}
{% endraw %}
{% endhighlight %}
( 当然为了显示以上的代码就用到了刚刚说的raw tag )
很好理解，但这么做需要在article里手动添加相应的more tag，虽然麻烦但是反倒显得自由
总之能用就行。

接下来添加相应的snippet到编辑器就ok了。
最后吐槽下css,各种宽度的布局我擦，蛋疼死俺了。
