---
layout: post
title: "Style mod for GoodReader with vimperator"
description: ""
category: tweak
tags: vimperator ツッコミ
---
{% include JB/setup %}

## The Pain Point

Like I've mentioned in other posts, most of my reading is done with digital materials. And the application that I use most often for that purpose is named GoodReader(IOS platform). There certainly are better alternatives, nevertheless, I'm too lazy(poor) to alter.

The old fashioned UI design of the app seems a little bit complicated and confusing, however the front-end page for file transfer via a WLAN is too simple to be satisfying.

* no design not all
* multi-file uploading not allowed
* progressing info is too inconspicuous

Well, the actual pain point for me is that the *submit* button is initially hidden, and is invoked visible with the onChange function of the *file* button, a glimpse at the source should be clear:

{% highlight html %}
<form style="font-size:9pt" name="upload" action="_______HTMLFORMFILEUPLOADVIAHTTP_______" method="POST" enctype="multipart/form-data">
Select file to upload:&nbsp;
<input type="file" name="filename" size="40" onChange="this.form.submit.style.visibility='visible'"><br>
<input type="submit" name="submit" value="Upload selected file" style="visibility: hidden">
</form>
{% endhighlight %}

That seems to be OK, however, it's a disaster if you use vimperator. Vimperator allows you to complete the operation of selecting files with a really nice built-in path completion interface looks like this:

![vimp-file](/assets/images/article/vimp-file.png)

All should be done with keyboard started by pressing **f** (which is exactly the *focus-element* shortcut) at the *file* button and ended by pressing **f** at the *submit* button. But the latter is kept hidden after the selection, and **f** won't make use of hidden objects. i.e. The problem is that the onChange function won't be called this way.

Since the perfect way seems not working, one might surrender to a mouse. As paranoid as I am, however, changes shall be made.

Once we've figured out what went wrong, solutions won't be far ahead. So `Don't panic!`

## Solutions

3 dirty ways that I can come up with.

### Changing the Source Code

The relative part of the vimperator src lies in `common/content/buffer.js`.

{% highlight js linenos %}
focusElement: function (elem) {
    if (elem instanceof HTMLFrameElement || elem instanceof HTMLIFrameElement)
        Buffer.focusedWindow = elem.contentWindow;
    else if (elem instanceof HTMLInputElement && elem.type == "file") {
        Buffer.openUploadPrompt(elem);
        buffer.lastInputField = elem;
    }
    else {
        ...
    }
},

...

openUploadPrompt: function openUploadPrompt(elem) {
    commandline.input("Upload file: ", function (path) {
        let file = io.File(path);
        liberator.assert(file.exists());

        elem.value = file.path;
    }, {
        completer: completion.file,
        default: elem.value
    });
}
{% endhighlight %}

Adding `elem.onchange();` to line 19, recompile, replace and restart, not elegant.

### Autocmd

Add 1 line to .vimperatorrc.

{% highlight vim %}
autocmd PageLoad 192\\.168\\.* js window.content.document.getElementsByTagName("input")[0].onchange()
{% endhighlight %}

Works well but may cause error messages when opening other local pages. Of cause, we can fix this by a js function with some checking inside, not elegant then.

### Override the Attribute

I prefer to change the visibility forcefully, it costs little and is probably bug free. 2 choices still, stylish or vimperator built-in? I chose the latter. So following lines are added to .vimperatorrc or the colorscheme file:

{% highlight vim %}
style -name goodreader-submit-visible http://* <<EOM
    @-moz-document regexp('http://192\\.168\\..*') {
        input[type="submit"] {
            visibility: visible !important;
        }
    }
EOM
{% endhighlight %}
