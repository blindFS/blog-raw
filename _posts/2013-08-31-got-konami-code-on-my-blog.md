---
layout: post
title: "Got konami code on my blog"
description: ""
category: fun
tags: konami Gintama music ツッコミ
---
{% include JB/setup %}

### Interesting stuff ###

Recently I got to know that konami code exists on many famous websites.Such as
google hangout,facebook......
So I decide to add my own to my personal blog.
At first I decided to write that function all by myself so I was busy
checking js documents.
Then I happened to find [ this ](http://snaptortoise.com/konami-js/).
It's cool and it also support mobile devices.

However in its code,it just names the function for mobile devices "iphone"...
Poor as I am,(I can not even afford a paid domain.)Iphone is untouchable.
But maybe it is just an advertisement for Apple.

### What will happen? ###

{% highlight js %}
var YouKnowTooMuch = function() {
    $('.kagura').show();
    $('.marvin').hide();
}
var konami = new Konami(YouKnowTooMuch);
{% endhighlight %}

Now,you know what you will see after typing the default konami code.
Yes,it's Kagura in Gintama.She is one of my favorite two female animé characters.
And the other one is Haibara in Conan.

No,I'm not a lolicon.

Have fun~

My favorite Gintama ED:

{% xiami 8137203_1770204424 %}

### buggy embeded html tag ###

At first my [xiami tag](/config/2013/07/28/boring-stuffs) was hidden.
After exclusion I found that this :`-webkit-backface-visibility: hidden;` is one of my css file.
What's unbelievable is that this line is in a class named .cd-dropdown which has nothing to do with the
embeded tag.However it just hides.
After I comment out that line.it shows up but whenever I trigger some certain animation,it will disappear for a while.
For now,I just leave it that way.Maybe I will search for the exact reason later.
