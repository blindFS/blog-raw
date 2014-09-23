---
layout: post
title: "Scripts for music"
description: ""
category: tweak
tags: shell python music ツッコミ
---
{% include JB/setup %}

## 删除下残了的lyric

之前提过我用osdlyrics查看歌词，但是osdlyrics会概率性地把歌词下残，
下残之后并不能自动删除，因此，那些下残了的歌曲的歌词就不得不手动清除。
我本来是想通过修改osdlyrics的代码来添加自动删除重下的功能，无奈能力有限。
虽然无法实现完美的解决方案，撸个脚本来一键批量删除还是可以的。

{% highlight sh %}
#!/bin/bash

lyrics_dir=~/tmp/.lyrics

cd $lyrics_dir
IFS=$'\n'
files=$(grep -l 'xml version=' *)
notify-send $(printf "%s\n" "${files[@]}" | cut -d . -f 1)
for file in $files; do
    rm -f $file
done
{% endhighlight %}

很简单，但是文件名的转义包括换行符的处理把我恶心到了。
这里的 $file 不用作额外的转义处理，但是顺便提下 `printf '%q' "$string"` 会将
$string 进行转义，相当于vim的函数shellescape()的作用。

## 修改歌曲的id3 tags

网易云音乐的资源品质虽高，但是有个让人郁闷的问题:
id3 tag中只有performer，没有artist...
我认识的播放器多数是只看artist不看performer的，这个理解不能。

`Don't panic!`

撸了个改tags的脚本

{% highlight python %}
#!/usr/bin/env python3
from mutagenx.easyid3 import EasyID3
import platform
import sys
import argparse
import glob


def tag_fix(file):
    tag = EasyID3(file)
    try:
        tag['artist'] = tag.get('artist', tag.get('performer', 'Unknown'))
        tag.save()
        print('Added artist tag of %s to %s' % (tag['artist'], file))
    except:
        print('Failed for %s' % file)
        pass


if __name__ == '__main__':
    if len(sys.argv) == 1:
        sys.argv.append('--help')
    parser = argparse.ArgumentParser()
    parser.add_argument('directory', metavar=('DIR'),
                        help=('Directory'))
    args = parser.parse_args()

    path = str(args.directory)

    if platform.system == 'Windows':
        flist = glob.glob(path + '\\*.' + 'mp3')
    else:
        flist = glob.glob(path + '/*.' + 'mp3')
    for file in flist:
        tag_fix(file)
{% endhighlight %}

mutagenx这个包很强大，以后有其它需求可以再好好瞅瞅。

好吧，貌似没有啥其它好说的，吐槽下ncmpcpp更新之后改bindings这烦人的事情。
水文一篇，就这样吧...
