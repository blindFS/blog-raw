---
layout: post
title: "Org your notes"
description: ""
category: tweak
tags: emacs org vimwiki
---
{% include JB/setup %}

## Why not vimwiki?

There are people around me who use evernote/onenote/wiznote quite a lot.
I used to use vimwiki to take notes, though super efficient,
it lacks useful functions when comparing to those morden tools:

* can't preview pictures
* can't preview math equations
* only be able to export as html

## Why org-mode?

I don't want to use evernote/onenote/wiznote since:

* I have a lot of notes in vimwiki to convert, and I don't know the target format if I choose one of them.
* I just don't like to use mouse that much, I still need vi key bindings, otherwise I get mad.
* Still, I need the exported html version. So I won't be stuck to certain apps just for viewing my notes.

So, basically no other choices. Org-mode is very powerful, actually too powerful for me to learn it
efficiently.

### Basic setups

{% highlight lisp %}
;; directory
(setq org-directory "~/Dropbox/org")
(unless (file-exists-p org-directory)
    (make-directory org-directory))
(setq my-inbox-org-file (concat org-directory "/inbox.org"))
(setq org-default-notes-file my-inbox-org-file)
(setq org-log-done t)

;; to hide emphasis markers like ** __ ~~
(setq org-hide-emphasis-markers t)
;; to enable ~'xxx~ *"xx* =,xx= to be treated as emphasised expressions
(setcar (nthcdr 2 org-emphasis-regexp-components) " \t\n")
(custom-set-variables `(org-emphasis-alist ',org-emphasis-alist))

;; indented according to header level
(setq org-startup-indented t)
(setq org-indent-indentation-per-level 1)

;; auto enable preview for math equations
(setq org-startup-with-latex-preview t)
;; auto enable image preview
(setq org-startup-with-inline-images t)
;; enable highlight for code blocks
(setq org-src-fontify-natively t)
;; default apps to open links
(setq org-file-apps '((auto-mode . emacs)
                        ("\\.x?html?\\'" . default)
                        ("\\.pdf\\'" . "evince %s")))
;; use ido for better completions
(setq org-completion-use-ido t)
{% endhighlight %}

### CJK support

1. to enable the input method, typically fcitx, `Exec=env LC_CTYPE=zh_CN.UTF-8 emacs %F` in emacs.desktop
2. to change the CJK font and fix the fontsize so that tables will be neatly aligned.

{% highlight lisp %}
(set-fontset-font t 'unicode (font-spec :family "Source Han Sans" :size 16))
(setq face-font-rescale-alist '(("Source Han Sans" . 1.15) ("Source Han Sans" . 1.15)))
{% endhighlight %}

3. to enable latex export with CJK chars, btw with minted code blocks

{% highlight lisp %}
;; -shell-escape is for minted code block
(setq org-latex-pdf-process '("xelatex -shell-escape -interaction nonstopmode -output-directory %o %f"
                                "xelatex -shell-escape -interaction nonstopmode -output-directory %o %f"))
;; enable nice code highlighting
(setq org-latex-listings 'minted)
;; 3rd item to be nil so that latex preview will ignore this package
(add-to-list 'org-latex-packages-alist '("" "minted" nil))
(add-to-list 'org-latex-packages-alist '("" "zhfontcfg" nil))
{% endhighlight %}

where zhfontcfg.sty contains the following contents:

{% highlight tex %}
% xetex/xelatex 字体设定宏包

\ProvidesPackage{zhfontcfg}
\usepackage[utf8]{inputenc}
\usepackage{fontspec,xunicode}

\usepackage[slantfont, boldfont, CJKtextspaces, CJKmathspaces]{xeCJK} % 允许斜体和粗体
\setCJKmainfont{WenQuanYi Micro Hei} % 设置缺省中文字体
\setCJKmonofont{WenQuanYi Micro Hei Mono} % 设置等宽字体

\setmainfont{Times New Roman} % 英文衬线字体
\setsansfont{Arial} % 英文无衬线字体
\setmonofont{Monaco} % 英文等宽字体

\usepackage{indentfirst} % 首段缩进

\defaultfontfeatures{Mapping=tex-text} %如果没有它，会有一些 tex 特殊字符无法正常使用，比如连字符。

% 中文断行
\XeTeXlinebreaklocale "zh"
\XeTeXlinebreakskip = 0pt plus 1pt minus 0.1pt
{% endhighlight %}

### For more vi friendly key bindings

First of all, evil is evil.

{% highlight lisp %}
(evil-define-key 'normal org-mode-map
     (kbd "RET") 'org-open-at-point
     "o" (lambda ()
           (interactive)
           (end-of-line)
           (if (not (org-in-item-p))
               (insert "\n- ")
             (org-insert-item))
           (evil-append nil)
           )
     "O" (lambda ()
           (interactive)
           (end-of-line)
           (org-insert-heading)
           (evil-append nil)
           )
     "za" 'org-cycle
     "zA" 'org-shifttab
     "zm" 'hide-body
     "zr" 'show-all
     "zo" 'show-subtree
     "zO" 'show-all
     "zc" 'hide-subtree
     "zC" 'hide-all
     (kbd "<tab>") 'org-table-align
     (kbd "M-h") 'org-metaleft
     (kbd "M-j") 'org-metadown
     (kbd "M-k") 'org-metaup
     (kbd "M-l") 'org-metaright
     (kbd "M-H") 'org-shiftmetaleft
     (kbd "M-J") 'org-shiftmetadown
     (kbd "M-K") 'org-shiftmetaup
     (kbd "M-L") 'org-shiftmetaright)
{% endhighlight %}

### Advanced export options

{% highlight lisp %}
;; stop a_b a^b from being treated like $a_b$ $a^b$ while a_{b} a^{b} are
(setq org-export-with-sub-superscripts '{})
;; auto section numbers
(setq org-export-with-section-numbers t)
(require 'ox-publish)
;; publish all notes to html/pdf format
(setq org-publish-project-alist
        '(("html"
        :base-directory "~/Dropbox/org"
        :base-extension "org"
        :publishing-directory "~/Dropbox/Public/html"
        :publishing-function org-html-publish-to-html)
        ("pdf"
        :base-directory "~/Dropbox/org"
        :base-extension "org"
        :publishing-directory "~/Dropbox/org/pdf"
        :publishing-function org-latex-publish-to-pdf)
        ("all" :components ("html" "pdf"))))

;; change default css style in the exported html
(defun my-org-css-hook (exporter)
    (when (eq exporter 'html)
    (setq org-html-head-include-default-style nil)
    (setq org-html-head (concat "<link href=\"assets/css/navigator.css\" rel=\"stylesheet\" type=\"text/css\">\n"
                                "<link href=\"assets/css/style.css\" rel=\"stylesheet\" type=\"text/css\">\n"))))
(add-hook 'org-export-before-processing-hook 'my-org-css-hook)
{% endhighlight %}

## A vim function to convert all vimwiki to org

Finally I need to export all of my previous notes from vimwiki to org-mode.
I tried `pandoc --from=mediawiki --to=org xxx`, not much what I need.
Here's the [script](https://gist.github.com/farseer90718/a897fa23ce12b673b223) that works for me.

It works fine in general for:

* links/images
* code blocks
* recursive ordered/enumerate list
* inline code/tex expressions

As for other emphasis markers, it's a bit complicated to judge whether they're verbatim(in a inline code region or mathjax equation).
I'd like to just modify `org-emphasis-alist` so that they won't need convertion at all.

NOTE: I used to use unicode for greek letters in mathjax equations,(more readable in vimwiki).
However those unicode characters stop `org-preview-latex-fragment` to work correctly.

Be happy~
