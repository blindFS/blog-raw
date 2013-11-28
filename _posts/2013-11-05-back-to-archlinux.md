---
layout: post
title: "Back to Archlinux"
description: ""
category: config
tags: arch linux awesome ツッコミ
---
{% include JB/setup %}
## 一切不滚动更新的系统都是刷流氓

系统版本更新就只有那么蛋疼了，一堆bug，各种不work，尼玛突然觉得用mavericks的只有那么幸福了。
之前想要体验下unity，（主要是global-menu）失足从arch挪到ubuntu。
后来发现gnome和xfce也能配置global-menu......
用了快一年了，gtk3程序一直报一个dbus的warning（后来发现貌似是lightdm的问题）不提，13.04到13.10更是出了一堆问题。（输入法，evince闪退，鼠标主题啥的）

## 其实我很懒

其实我不能忍ubuntu很久了（压根没有在用unity），但是一直不愿重装。
主要问题在于awesomewm的版本。arch一般都会超前一点。
3.4到3.5只有那么蛋疼了，语法变了也就罢了，关键是一堆widget库跪了。反正我现在的awesome配置个人感觉还是没有之前的好用，不过凑合了。

其实我只有那么懒了，我他丫的也不想折腾，我他丫的要是土豪，我能不换mac？

## 各种蛋疼

这次装arch大概遇到的问题大致有以下几点

* 一开始`grub-mkconfig` 自动生成的cfg文件不能用，尼玛得手动改。升级了两次内核之后突然又能用了，理解不能。
* **xinitrc**不执行，尼玛到现在我还是把执行xinitrc的语句写在**gnome-session-properties**里头......尼玛坑爹的是kde能执行。
* 装了中文圆体之后，flashplayer的中文巨丑无比，只有那么恶心了，一半黑体，一半楷体。偷了别人的fontconfig，在此感谢starbrilliant同学。
* <del>**pulseaudio**一直跑不了，于是gnome默认的mixer就不能用。懒得理他，反正alsa能用就成，音质应该还更好些（虽然是渣渣声卡无所谓）。</del> 能用了...
* 以上问题跟awesome升级比起来都是小问题。虽然awesome升级也不是啥大问题（反正能用）。
* plymouth 包太out，必须用aur的plymouth-git，否则对不上wiki。
* swap分区还是尽量跟内存保持一样大，这样的话hibernate（估计也只有我真中电池会莫名熄火的渣渣才用吧）的时候可以快很多。

其实总体来说装个系统比我想象的要简单多了，由于有ustc源的存在，我不需要考虑网速的问题，只有那么给力了。
某些小问题要不就自己莫名其妙正常了，要不能有其他方法取代它，反正从我进入滚更的节奏之后，瞬间感觉轻松了好多。
<del>剩下就只有goldendict和weechat的配置没有完全恢复了，暂时用不着，以后再说......</del> 搞好了...
之前一些从源码编译的软件还要没事用脚本升级下，然后重新编译，只有那么烦了（比如vim，ubuntu源里头的vim只有那么傻逼了。）。AUR里头那些个-git的包解决了这些问题。
果然还是arch给力。

希望下次装系统是在我买新机器之后......

## awesome 3.4-3.5

[官方链接](http://awesome.naquadah.org/wiki/Awesome_3.4_to_3.5)

我用的几个主要的lua库的状况

* couth      ( 音量调节) 功能完好
* eminent    ( tag 管理) 功能完好
* vicious    ( 综合图表) 改动较大，但是功能基本完好
* blingbling ( 综合) 改动较大，但是功能基本完好
* lain       ( 综合) 3.5后添加的，功能基本完好
* revelation ( 缩略图) bug，尝试修改无果，遂抛弃

其他那些，比如自动生成menu的倒是功能完好（我嫌它卡，再说我用不着menu）。
blingbling和lain我都做了些小修改来配合我的使用习惯。

<del>revelation其实我真的挺喜欢的，但是无奈人太蠢，实在修不好。算了算了。</del>
[居然没好好看issue list](https://github.com/bioe007/awesome-revelation/issues/8), 三楼的评论对我来说管用。

其它问题

* 网速测试的widget在切换接口之后不能自动切换
* <del>floating的窗口莫名其妙地变大，我猜测这与awesome3.5试图修复那些默认留白的最大化程序（如gvim）有关。想法倒是不错，但是尼玛乱放大，还不如留白呢。</del> 这部分代码已经被我删除，少许的留白相比较无端的放大真的不是什么大问题。
* arch的gnome 3.10没有提供**gnome-settings-daemon**这个可执行文件，这导致awesome下无法使用gnome的某些配置。其实我用得到的就是chromium下的textbar/area使用emacs式的快捷键。[解决办法](http://awesome.naquadah.org/wiki/Quickly_Setting_up_Awesome_with_Gnome#Arch_Linux)
* **awesome-gnome** 需要执行`dconf write /org/gnome/settings-daemon/plugins/cursor/active false`，否则鼠标会消失。
* <del>mpd widget不大对。一开始是好的，不知道更新哪个玩意之后，没事就瞎刷新，测试发现根本问题是telnet之后老断，信息获取不全（基本看脸）。改了下代码，刷是不刷了，但是信息更新总是慢半拍，凑合用。</del> mpd的bug，升级后解决了。

