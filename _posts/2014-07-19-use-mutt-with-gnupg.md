---
layout: post
title: "Use mutt with GnuPG"
description: ""
category: config
tags: shell encryption mutt ツッコミ
---
{% include JB/setup %}

## 据说逼格很高

mutt 我很久之前配置过，大概耍过一段时间。但是一直觉得这玩意不好用
不如直接上 web 来的直观，虽然说感觉逼格要高那么一点。当然用emacs的大神
们应该是对这种玩意不屑一顾的。

前不久我收到一个老外的邮件，附件里带了名为 signature.asc 的 gpg 的数字签名。
当时我非常的天真，觉得这玩意十分的高端大气。
今天我闲来无事，准备研究下这其中的奥秘。

## GPG

默认用的RSA算法。
密码学这么高端大气的东西，我这样的数学白痴是理解不能的。
RSA的原理什么的，我不敢瞎说，以免误人子弟，虽然估计也没几个人会看，哈哈。
不过基本的原理还是简单清晰的。作为一个使用者，我觉得记住以下两点就差不多了。

* 用接收者的公钥进行加密，用私钥进行解密
* 用私钥进行数字签名，用发送者的公钥进行认证

对于 GnuPG 这个工具的使用，可以参照[Archwiki](https://wiki.archlinux.org/index.php/GPG)
如果你的英文跟我一样捉鸡的话，还可以看看[这个](http://www.ruanyifeng.com/blog/2013/07/gpg.html)

## mutt 的配置

mutt的配置其实挺复杂的，不过常见需求都可以搜到，而且多数语句的含义不言自明。
我在这只是介绍几个我碰到的坑

### 将邮箱的密码写成密文的形式

[Archwiki](https://wiki.archlinux.org/index.php/Mutt#Passwords_management) 上介绍的这种方式
我尝试过，但是总是提示找不到指定的 variable。反正总归是要 source，我的做法是直接将

{% highlight vim %}
set imap_pass = *****
set smtp_pass = *****
{% endhighlight %}

进行了加密，不如wiki上介绍的那样美观，但是反正能用。用这样的方法我就可以直接将我的配置
放在git host server 上，不用担心安全问题了。

### 配合GPG使用

建议参考官方的 [wiki](http://dev.mutt.org/trac/wiki/MuttGuide/UseGPG)。
不过那篇介绍的有些过于详细。简单来说就是再 source 一个 mutt 的配置文件，
就可以做到自动加密，自动解密，自动attach签名，自动认证签名。

对与 Arch 用户来说，有个简单地多的方法，AUR 中有个包叫做 mutt-gpg-verbose-mime。
我安装的这个时候，mutt的ftp连接不上，而且版本比 extra 中的要低了一个小版本号。
我的做法是直接从 sourceforge 上下载最新的源码包，然后修改 PKGBUILD 中的 sha1sum，
patch 仍然是那个 patch，编译一切顺利。

安装完后提示需要 source /etc/Muttrc.gpg.dist，在这个基础上
添加 wiki 中提到的几个重要的选项，总之最后的长相应该跟
[这个](https://github.com/blindFS/dotfiles/blob/master/.mutt/.gpgrc)差不多。

AUR中那个patch的作用是可以指定以下两个选项:

{% highlight vim %}
set pgp_mime_signature_filename    = "signature.asc"
set pgp_mime_signature_description = "Digital signature"
{% endhighlight %}

不然，如果是采用 extra 中的包，自动attach的数字签名会被命名为 noname 或者其它，
看上去不像是好东西反正。另外一个要主意的是:

`pgp_getkeys_command` 选项是用来自动从 key server 上获取 public-key 用来认证的指令。对于
GnuPG 来说，至少我这个版本-2.0.25 `gpg --recv-keys` 只认 hash 值，不认邮箱。所以
只能是 `%a`

`set pgp_autoencrypt = yes` 不是好选择，因为不是谁都上传了 public-key 的，所以
wiki上提供了 send-hook 的方法来对某些特定的用户进行自动加密。我没有朋友能提供 public-key
让我测试，所以就先不鸟了。另外 mutt 提供的另外一套 crypt 的选项，貌似跟 pgp 的功能类似，
没怎么深究......

## 其它

* 我的邮箱是 blindFS@gmail.com，应该可以在 `gpg --search-keys` 中找到对应的 public-key
* 最近搞了个免费的163企业邮箱来提升逼格: admin@farseer.cn，这货的 key 我还没有生成

我本来是想搞 google 的企业级邮箱来的，结果我那个 dotcn 的域名被提示说不支持，尼玛。
我试了下 dottk 的免费域名，google提示说我这个域名有发垃圾邮件的嫌疑不让我注册，尼玛，名字虽然是
欠了点 --- page-404.tk

我的 gpg 中途出过一个 bug，每次 import public key 总是提示 Unknow system error。
无奈的我选择先将私钥导出，然后导入的方式修复了这个问题，至今表示迷茫...

{% highlight sh %}
gpg --output xxxx --armor --export-secret-key ABCDFE01
## 删除 .gnupg 的内容
gpg --allow-secret-key-import --import xxxx
gpg --edit-key you-pub-key trust quit
{% endhighlight %}

最后一句修改自己 pub-key 的置信度为5，否则 verify 的时候会有 warning.
更多关于 trust 的[描述](https://www.gnupg.org/gph/en/manual/x334.html)

好吧就这样，感叹下，装逼真是累啊...
