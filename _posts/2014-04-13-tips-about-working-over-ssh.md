---
layout: post
title: "Tips about working over ssh"
description: ""
category: tweak
tags: shell tmux
---
{% include JB/setup %}

## Share the clipboard

It is a general request to share the clipboard between a ssh client and a ssh server.
Execpt for web copy-paste service like vpaste, pastebin, paste.ubuntu, There are
two ways that I know to achieve the goal.

* Use the X11 forwarding and xclip
    There are two steps:
    1. Enable the X11 -- which I will talk about later.
    2. `ssh [remote-machine] "cat sth.txt" | xclip -selection clipboard`  or something similar.
    You may also find another cli tool called *xsel* useful.
* Use the tmux way
I prefer this way simply because it needs less key strokes. Once you have everything
setup, pretty much the same as copy-paste locally.
First of all, add these lines in your local `~/.tmux.conf`:

{% highlight text %}
set-window-option -g mode-keys vi
bind-key -t vi-copy 'v' begin-selection
bind -t vi-copy 'y' copy-pipe "xclip -selection clipboard"
{% endhighlight %}

I prefer the vi keybindings, so 'v' for visual selection, 'y' for yanking the selection.
The copy-pipe option may not be available for older versions of tmux. There is a more
complicated script to do the same thing, but in my case, a newer version will be good enough.

### More about tmux

As for the very necessary tool -- tmux, I'd like to mention other tips.

* Once you have changed the configuration file of tmux, you only need one tmux command: `source-file ~/.tmux.conf`
to reload it.
* `source-file` may be the mostly useful command to me, but still tmux provides plenty of commands which you can peek
through one of them: `list-commands`
* There is a great ruby gem called tmuxinator(also exists in AUR).
Basically it helps to manage the windows and panes in your tmux session.
And your can quickly restore a certain layout for your project after some event such as reboot.
    1. `mux -h` for more info
    2. Describe the layout with a yaml file like this:

{% highlight yaml %}
name: hehe
root: ~
windows:
    - shell:
        layout: main-vertical
        panes:
            - cd dir1 && clear
            - cd dir2 && clear
    - editor:
        layout: main-vertical
        panes:
            - vim file1
            - cd dir3 && clear
            - ipython2
            - octave
    - ssh: ssh user@remote "commands"
    - rtorrent: rtorrent
    - weechat: weechat
{% endhighlight %}

## Feedback notifications

You may want the server to send you a notification when the job assigned to it is done successfully or quit with error.
The way I managed to do that is as the following:

1. Run `ssh-copy-id user@local-device` on your server to make sure you can access your
local device from the server without entering passwd. Seems to be not that safe......
2. Enable X11-forwarding in your local sshd service by following [these instructions](https://wiki.archlinux.org/index.php/Ssh#X11_forwarding)
3. `task ; ssh -X user@local-device"DISPLAY=:0 notify-send Task finished!"`

Notify-send in awesomewm is captured by a module called naughty. It seems that naughty stops
remote notifications from displaying.
I have to choose zenity over notify-send, a little uglier, but works.
