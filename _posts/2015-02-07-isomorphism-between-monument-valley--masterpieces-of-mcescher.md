---
layout: post
title: "Isomorphisms between Monument Valley & masterpieces of M.C.Escher"
description: ""
category: fun
tags: game art
---
{% include JB/setup %}


## Preface

博客写了1.5年左右的时间了，内容尽是些无足轻重的雕虫小技，与其说是博客，不如唤作笔记来的贴切。每当码字的时候，潜意识中总是明白光标下的东西不会被人关注，因此不论是标点、措辞、内容的逻辑性......都全然不顾，敲下的东西更像是当前的我和日后翻阅时的我之间的对话。它们的糟糕程度正好就反映了我的懒散程度。

每当我看到他人的博文中那种清新的排版，分明的层次，清晰的逻辑，文邹邹的字句时，总是由衷的佩服。我想这就是2B青年所模仿不来的文艺气质吧!

我想我需要在文字中间多注入一些情感，我知道也许这样做会有一种刻意模仿的痕迹，矫揉造作似的违和感，但至少我想做一次这样的尝试。

前段时间我正好阅读了GEB的中文译本，确实受到了震撼，也许是我读书不多的缘故吧。我希望在能这里留下一些我的感想，但是又不知从何谈起，毕竟GEB包罗万象，我对它的理解犹如沧海一粟。虽然这本书的重点是哥德尔(G)、数理逻辑、人工智能，但到处穿插着埃舍尔(E)的版画，同时每章的序都被冠以曲谱的名字，文字中也多次提到巴赫(B)的赋格曲，整本书散发着浓郁的艺术气息。我一向不通音律，书中除了对哥德尔定理的介绍和对心智的探讨之外，给我印象最深的自然是埃舍尔构建的奇妙空间了。

也就是前不久，我在室友的推荐下接触到了Monument Valley这款游戏，同样是艺术感很强的作品，熟悉的空间，熟悉的图案......下面我将细数我从纪念碑谷中看到的埃舍尔的身影，并借此表达我对两者的喜爱之情。

## Totems

先从散落在纪念碑谷中的零星的符号开始说起。

### Crow & Swan

游戏从第4关开始，会出现徘徊的黑乌鸦人，另外主角艾达会在最终章变身成白色乌鸦人。在我看来，乌鸦人在游戏中的语义为迷失，循环。

![crows](/assets/images/article/Escher/crows.jpg =500x)

黑与白、鸟类、循环，让我联想起这幅 Swans(1956)。

![swans](/assets/images/article/Escher/swans.jpg =500x)

这是一幅很有意思的作品，给我的第一感觉是[莫比乌斯带](http://en.wikipedia.org/wiki/Möbius_strip)，但是第二眼便否定了这个感觉，更像是一个镂空的环带，中间部分被胶水粘在了一起，黑和白，确实是两面。但是再转念一想，如果将中间黑白镶嵌的部分看做是一个面，只是被染上了颜色，然后将这个图的左右部分分开，那么每个部分确实分别是一个莫比乌斯带！另外这个作品蕴含了[镶嵌画](http://www.wikiart.org/en/m-c-escher/mosaic-ii)的理念，这无疑是埃舍尔最擅长的手法之一。

### Polyhedron Combo

有人说，艾达之前偷走了许多几何图形，而这个游戏剧情的主线是艾达归还失物，寻求救赎的过程。不论怎样，每一关的最后，艾达都会从自己的帽子中掏出一个规则的几何图形。下图是资料片Forgotten Shores的图形集合。

![mvstar](/assets/images/article/Escher/mv_stars.png =500x)

与之对应的是埃舍尔的作品 Stars(1948)

![star](/assets/images/article/Escher/stars.jpg =500x)

对于这个作品，信息量很大，对于它的解读也非常之多，我们且关注画面中出现的图形。这些图形都有个共性：一个或多个正多面体的组合。

* 正中的空心图形，是由[3个正八面体组合](http://mathworld.wolfram.com/Octahedron3-Compound.html)而来，对应的实心图形在它的右下角。
* 七点钟位置的空心图形，是由[2个正方体组合](http://mathworld.wolfram.com/Cube2-Compound.html)而来，对应的实心图形在五点钟位置。
* 一点钟位置的空心图形，是由[2个正四面体组合](http://mathworld.wolfram.com/Tetrahedron2-Compound.html)而来，对应的实心图形在左下角。
* 十一点的实心图形，是由一个正方体和一个正八面体组成。

上面描述到的第二种图形始终给我一种强烈的违和感，我总觉得它的美感要逊色于其它图形，但是从对称性上来说，它的确是中心对称的，这点上甚至强过正四面体，那么我意识中的美感欠缺到底来自何处呢？

于此相关的一个有趣的词条叫做[Uniform polyhedron compound](http://en.wikipedia.org/wiki/Uniform_polyhedron_compound)，不过里面的图形的约束条件要强很多："The symmetry group of the compound acts transitively on the compound's vertices."，跟踪链接后发现此处的"transitively"指的是对于任意的两个顶点A、B，存在一个图形顶点的置换，在其作用下，A被置换为B。那么一个简单的推论就是：每个点的度必须相同。

### Impossible Objects

"Those who stole our sacred geometry have forgotten their true selves.
 Cursed to walk these monuments are they."

上面这句话源自纪念碑谷中的NPC。从这句话来说，上面提到的那种对游戏剧情的解读或许是说的通的。而这句话出现的地方，正是下文中将要提到的彭罗思三角形出现的地方。

那么造成这种[不可能出现的图形](http://en.wikipedia.org/wiki/Impossible_object)的原因是什么？我想本质上，这与之后我们会看到的各种错觉现象一样，来自三维物体在二维投影中的信息缺失。我们没有办法从二维的图像中还原三维物体的全部空间信息，换句话说，为了还原物体，我们需要对我们所见到的信息用想象进行补全。而这个想象，恰恰是不靠谱的......

#### Penrose Triangle

![pt](/assets/images/article/Escher/mv_triangle.png =500x)

这个图形就是著名的[彭罗思三角形](http://en.wikipedia.org/wiki/Penrose_triangle)。而这个图形的创作者彭罗思[父](http://en.wikipedia.org/wiki/Lionel_Penrose)[子](http://en.wikipedia.org/wiki/Roger_Penrose)，也是十分了得的人物。那么这和埃舍尔又有什么关系呢？

答案在维基词条中一目了然，让我们来欣赏下埃舍尔的作品 Ascending and Descending(1960)中的[彭罗思阶梯](http://en.wikipedia.org/wiki/Penrose_stairs)。

![a&d](/assets/images/article/Escher/ascending-descending.jpg =500x)

其实看到这个三角形时，我第一个联想到的是 Relativity(1953)，现在看起来还有一些神似，但确实不是同构的。

![rela](/assets/images/article/Escher/relativity.jpg =500x)

除了这些联系之外，[彭罗思平铺](http://en.wikipedia.org/wiki/Penrose_tiling) 是不是又与镶嵌画惊人的类似呢？

#### Impossible Cube

纪念碑谷中出现的正方体，它与埃舍尔发明的[不可能立方体](http://en.wikipedia.org/wiki/Impossible_cube)是什么关系呢？乍一看两者并无关联。

![mc](/assets/images/article/Escher/mv_cube.jpg =500x)

![ic](/assets/images/article/Escher/impossible_cube.png =300x)

参考维基词条，下图中的图形通过转动之后，可以得到不可能立方体。而游戏中的立方体，恰好是有缺口的。我多次尝试转动，却也没有发现合适的角度，而截图中却展示出了另一种不可能性。我认为这是为了游戏性所做出的调整，这不妨碍我们把它们联系在一起。

![ic2](/assets/images/article/Escher/impossible_cube2.png =300x)

## Illusory & Impossible

视觉错觉是这两者共同的主题，具体的表现形式如下。

### Height & Depth

![mvwf](/assets/images/article/Escher/mv_waterfall.jpg =500x)

通过物体高度和深度的相互转化来造成错觉，是纪念碑谷的核心玩法，贯穿始终，它的魅力通过上面提到过的 Ascending and Descending 就能领会， Waterfall(1961)所表达的是同样的理念。

![wf](/assets/images/article/Escher/waterfall.jpg =500x)

然而这幅杰作还有其它的两点，注意图中两个柱子上的图形。第一个图形恰似Stars中的图形一般，是由[3个正方体组成](http://mathworld.wolfram.com/Cube3-Compound.html)的。

![3c](/assets/images/article/Escher/3cubes.png =300x)

而另一个则被命名为[Escher's Solid](http://mathworld.wolfram.com/EschersSolid.html)，自然是埃舍尔原创了。

![es](/assets/images/article/Escher/es_solid.png =300x)

它具有以下性质:

* 可以用8个相同的小八面体粘合而成
* 可以用3个相同的大八面体组合而成
* 用它可以既无重复又无遗漏地填满整个空间!

我对这两幅破布做如下解读：水流从深度低的地方流向深度高的地方，正是这样的深度差转化为高度差，从而推动水轮机永动。

那么有没有高度换深度的呢？我们来看下面这一组图。

![ch](/assets/images/article/Escher/chasm.png =500x)

![bel](/assets/images/article/Escher/belvedere.jpg =500x)

这幅作品名叫 Belvedere(1958)，中文名瞭望塔。相信很容易看出这两幅图的同构性：两个本该相互垂直的斜线段被一群平行的垂线给......我认为这就是一种高度换深度(当然反过来理解为深度换高度也未尝不可)，画面提供了不同高度的垂线段，导致线段两端出现深度差，造成了图形的扭曲感。

有趣的是Belvedere中底部坐在长椅上的男子，手里拿的正是impossible cube！

### Concave & Convex

凹凸的模糊性自然不会被两者放过。

![mvcc](/assets/images/article/Escher/mv_cc.png =500x)

Convex and Concave(1955)

![c&c](/assets/images/article/Escher/convex\&concave.jpg =500x)

有趣的是游戏中居然出现了Escher's Solid！

## Postscript

两者的同构之处也许远多于我的描述，这款游戏我玩了两次，包括Original和Forgotten Shores，遗憾的是红丝带特别关(限时购买)我再无法体验了。我相信我还会再玩第三遍，第四遍(如果它不出新的资料片的话)......如果我有新的发现，会添加到这里。

埃舍尔的作品确实像GEB作者侯世达所说的那样是一块瑰宝。其中不乏极具思想性的作品，如：画手、画廊、拿着反光球的手。这些都没有在本文中出现，仅仅是因为我还没有在MV这款游戏中找到它们的身影。顺便提一下，MV中的音乐也很不错，虽然跟赋格是两码事。

## References

* [http://www.guokr.com/article/19538/](http://www.guokr.com/article/19538/)
* [http://en.wikipedia.org/wiki/Impossible_cube](http://en.wikipedia.org/wiki/Impossible_cube)
* [http://en.wikipedia.org/wiki/Penrose_triangle](http://en.wikipedia.org/wiki/Penrose_triangle)
* [http://en.wikipedia.org/wiki/Impossible_object](http://en.wikipedia.org/wiki/Impossible_object)
* [http://en.wikipedia.org/wiki/M.\_C.\_Escher](http://en.wikipedia.org/wiki/M._C._Escher)
* [http://en.wikipedia.org/wiki/Stars\_(M.\_C.\_Escher)](http://en.wikipedia.org/wiki/Stars_(M._C._Escher)
* [http://en.wikipedia.org/wiki/Lionel_Penrose](http://en.wikipedia.org/wiki/Lionel_Penrose)
* [http://en.wikipedia.org/wiki/Roger_Penrose](http://en.wikipedia.org/wiki/Roger_Penrose)
* [http://en.wikipedia.org/wiki/Penrose_tiling](http://en.wikipedia.org/wiki/Penrose_tiling)
* [http://en.wikipedia.org/wiki/Uniform_polyhedron_compound](http://en.wikipedia.org/wiki/Uniform_polyhedron_compound)
* [http://mathworld.wolfram.com/topics/PolyhedronCompounds.html](http://mathworld.wolfram.com/topics/PolyhedronCompounds.html)
