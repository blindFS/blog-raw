---
layout: post
title: "A peek into phantomjs"
description: ""
category: tweak
tags: ツッコミ javascript
---
{% include JB/setup %}

## Phantomjs

I have heard this project for quite a long time.
However, I haven't got time to read the documents until today, May day.

According to the readme, "phantomjs is an optimal solution for":

1. headless website testing
2. screen capture
3. page automation
4. network monitoring

I think the No.2 and No.3 attract me more.
I have to say that the document is a little too abstracted to be understood for me
(a rookie in javascript).

After struggling quite a bit however, I managed to build a very simple script.
{% highlight js%}
#!/usr/bin/phantomjs

var system = require('system');
var page = require('webpage').create();

if (system.args.length !== 3) {
  console.log('Usage: xiami.js email passwd');
  phantom.exit(1);
} else {
  page.open('https://login.xiami.com/member/login?spm=a1z1s.6843761.226669510.8.pfanSN', function() {
      page.evaluate(function (system) {
        document.querySelector('input[name="email"]').value = system.args[1];
        document.querySelector('input[name="password"]').value = system.args[2];
        document.querySelector('input[name="submit"]').click();
      }, system);
      var page2 = require('webpage').create();
      window.setTimeout(
        function () {
          page2.open('http://xiami.com/', function() {
            page.evaluate(function () {
              document.querySelector('b[class="icon tosign"]').click();
            });
            window.setTimeout(function () {
              console.log(page.url);
              page.render( 'xiami.png' );
              phantom.exit(0);
            }, 3000);
            })
        },
        5000);
});
}
{% endhighlight %}

* This script takes 2 arguments, xiami account email and passwd.
* Using the page automation feature to simulate the login actions.
* Wait for several seconds before the final click action takes effect, then takes a screenshot of the homepage.

话说一旦用淘宝帐号登录之后，就无法使用xiami原有帐号登录了，我就阿里强奸
虾米事件对阿里提出强烈谴责。
好吧，差不多就这样。
