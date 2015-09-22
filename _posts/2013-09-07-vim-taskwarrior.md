---
layout: post
title: "Vim taskwarrior"
description: ""
category: tweak
tags: linux vim taskwarrior
---
{% include JB/setup %}

## Another vim plugin I wrote ##

It's a vim interface for [taskwarrior](http://taskwarrior.org) --- A powerful cli todo list manager.
The code is hosted on [github](https://github.com/blindFS/vim-taskwarrior).

Feel like this:

![vim-taskwarrior](/assets/images/article/vim-taskwarrior.png)

The reason that I write this plugin is that I can't got [vit](http://taskwarrior.org/projects/1/wiki/Vit) working on my computer.
Plus I dislike the way vit highlights tasks.

And my basic usage of this tool is simple,add/delete/set-done will be good to go.

## Accomplished functions ##

* create/modify a task
* set a task to be done
* clear completed task
* undo last change
* show task info
* show projects summary
* delete a specific task
* highlight properly according to personal configs.

## Tricky problems encountered during the procedure ##

* Taskwarrior provide an option called **defaultwidth** with the default value of 80 to wrap lines properly in terms.
However this will cause a problem while capturing the output as a string.And I haven't come up with an idea to deal with arbitrary value of this option.So
I just suggest the users should set it to be big enough......
* Taskwarrior's filter system provides a way to specify certain tasks.And the best way to get the exact same tasks is by UUIDs which by default,is not shown in
output.It is reasonable because the uuids basically mean nothing.However in order to delete,for example,a specific completed task while there is a task almost
the same(except uuid) as it,will be impossible.So again,I have to suppose that the users added that column in the *.taskrc*.But no error will occur if not.
* Interactive external call with gvim seems to be buggy.For example `task undo` will cause something like this:

    The last modification was made 9/7/2013

    Prior Values  Current Values
    depends                    bcd1535f-a5a4-4cd8-92b9-a7f6bc1cc02f
    description                165
    due                        9/8/2013
    entry                      9/7/2013
    priority                   L
    project                    test
    status                     pending
    tags                       test
    uuid                       0ea01ec5-7e3f-43eb-b70a-4b55fa5505d6

    The undo command is not reversible.  Are you sure you want to revert to the previous state? (yes/no)

If I call this by `!task undo` it will display only the first line and it will not take any movement no matter what you type.

* Syntax match containing '\zs','\ze' in the pattern string doesn't seem to work very well.
For example:

{% highlight vim %}
syn match match1 /^./ " the 1st char in every line.
syn match match2 /^.\zs./ " the 2nd char in every line.
{% endhighlight %}

It turns out that match1 and match2 are not 2 independent kinds which still confuses me.So I use this kind of structure:

{% highlight vim %}
syn match match1 /^./
syn match match2 /^.\{2}/ contains=match1 " the first two chars
{% endhighlight %}

## future work ##

* Bug fix
* Other functions maybe
* Add unite.vim support(Actually it can be totally ported to the unite structure but I prefer the pure vimscript way)
