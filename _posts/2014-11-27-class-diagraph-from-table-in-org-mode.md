---
layout: post
title: "Class diagraph from table in org mode"
description: ""
category: tweak
tags: emacs org graphviz elisp
---
{% include JB/setup %}

## 需求来源

作为一个懒得不行的人，数据结构关系图/类图这种东西，我从来都是截的。
不久前，sadhen同学，向我展示了在TeXmacs下，利用树状结构输入，快速生成关系图的方法。
具体的内容可以参照[这篇博客](http://sadhen.com/2014/11/09/texmacs-graphics-struct)。
虽然不得不承认TeXmacs的各种功能很赞，但是我最近才重新上手emacs，TeXmacs肯定不是我TODO list内的存在。
看了他的演示，我的第一反应是，`Don't panic!`, 类似的东西，org-mode一定可以有。

## 丑陋的 Ver1.0

### 输入?

由于到没有那种树状结构的输入，我能想到的最便捷的信息载体形式就是table。
table的便捷性也许不如tree，但是语义要更加完备。

### 输出?

解决了输入的问题，接下来就是输出了。我能想到的最方便的形式便是dot，或者叫graphviz(我不懂这两个名词是啥关系...)。
其实还有个选项: plantUML，一个基于dot的UML图生成语言。但是相比较dot没有什么特别的优势。

### 过程

* 添加如下函数至emacs配置

{% highlight lisp %}
(defun dia-from-table (table)
  (cl-flet ((struct-name (x) (save-match-data
                          (and (string-match "\\(struct\\|class\\) \\([^ ]*\\)" x)
                               (match-string 2 x)))))
   (let ((all-structs (mapcar 'car table)))
     (mapcar #'(lambda (x)
                 (let ((lhead (car x))
                       (ltail (cdr x)))
                   (princ (concat lhead " [label=\"<head> "
                                  lhead " |"
                                  (mapconcat (lambda (y)
                                               (concat " <" (replace-regexp-in-string
                                                             "\\W" "_" y) "> " y))
                                             (delq "" ltail) " | ") "\", shape=\"record\"];\n"))
                   (mapcar (lambda (y)
                             (let ((sname (struct-name y)))
                               (and (member sname all-structs)
                                    (princ (format "%s:%s -> %s:head\n"
                                                   lhead (replace-regexp-in-string
                                                          "\\W" "_" y) sname)))))
                           ltail))) table))))
{% endhighlight %}

* 在某个.org文件中加入如下的snippet

{% highlight text %}
#+name: dot-eg-table
| task_struct    | struct signal_struct *signal | struct sighand_struct *sighand   | blocked  | real_blocked | saved_sigmask | struct sigpending pending |
| signal_struct  | count                        | struct sigpending shared_pending | live     |              |               |                           |
| sighand_struct | count                        | struct k_sigaction action[_NSIG] | siglock  | signalfd_wqh |               |                           |
| sigpending     | struct list_head list        | sigset_t signal                  |          |              |               |                           |
| k_sigaction    | struct sigaction sa          |                                  |          |              |               |                           |
| sigaction      | __sighandler_t _sa_sigaction | sa_mask                          | sa_flags | sa_restorer  |               |                           |

#+name: make-dot
#+BEGIN_SRC emacs-lisp :var table=dot-eg-table :results output :exports none
(dia-from-table table)
#+END_SRC

#+BEGIN_SRC dot :file ~/test-dot.png :var input=make-dot :exports results
digraph {
    graph [rankdir = "LR"];
    $input
}
#+END_SRC
{% endhighlight %}

* 执行dot代码块之后便可以在org文件中插入一个如下的关系图

![test-dot](/assets/images/article/test-dot.png)

* 为yasnippet添加类似2中的片段

{% highlight text %}
# -*- mode: snippet -*-
# name: diag
# key: diag
# --

#+name: ${1:dot-input}
#+BEGIN_SRC emacs-lisp :var table=${2:class-table} :results output :exports none
(dia-from-table table)
#+END_SRC

#+BEGIN_SRC dot :file ${3:./assets/image/}${4:xxx}.png :var input=$1 :exports results
digraph {
    graph [rankdir = "LR"];
    $input
}
#+END_SRC
{% endhighlight %}

说这个实现方式丑陋的主要原因:

* 输出的图像没有任何的美化
* 对输入的表格格式有严格的要求，否则可能得不到想要的结果
* 需要在org文件中添加11行的相关代码，这还不包括所需的表格，当然可以做到在生成图片之后自动删除这些，
但是为了方便之后修改，这是不可避免的
* 刚开始学习elisp，还不是很熟悉内置函数，函数写的应该是丑陋的，虽然我自己还看不出来...

其实对我来说，之后也许很少会用到这个功能了，我还是会优先选择截图...，我只是把实现这个功能作为我
的第一个elisp练习题看待，所以它也许会这么一直丑陋下去也说不定，但是它多少维护了些emacs在我心中
至高无上的地位(用不用是另一回事...)。
