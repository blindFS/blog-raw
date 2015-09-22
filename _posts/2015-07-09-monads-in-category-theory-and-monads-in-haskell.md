---
layout: post
title: "Monads in Category Theory and Monads in Haskell"
description: ""
category: PLT
tags: haskell
---
{% include JB/setup %}

## Aha

最近尝试学习一些基础的范畴论，无奈资质愚钝，浅尝则止了。不过还是想通过这篇文章来加深一下对某些东西的粗浅认识。

我在看monads的定义的时候，总是无法将范畴论中的那套东西联系到haskell中的定义上，为此，我查阅了一些资料，花了很多时间去思考（所谓勤能补拙），总算是让自己相信了。

## Monads in Category Theory

从什么地方写起，这是个问题，想了想决定跳过category的定义，直接从functor说起，因为cat的定义比较简单，一搜一看就能理解，而functor在我之前的文章中对它的描述有偏差，这边顺便就纠正了。

### Functors

functors用于联系多个cat，假设C和D为两个cat，一个functor \\(F: C \to D\\) 可以看作是从C到D的映射，对应关系如下：

1. 对C中任意的object A，\\(\exists F(A) \in D\\)
2. 对C中任意的morphism \\(f: A \to B\\), \\(\exists F(f): F(A) \to F(B)\\)

需要满足如下条件：

1. \\(F(id\_A) = id\_{F(A)}\\)
2. \\(F(f \circ g) = F(f) \circ F(g)\\) 先复合再映射与先映射再复合等效

一图流：

![functor](/assets/images/article/Functor.png)

对应到haskell中的定义

{% highlight haskell %}
class Functor (f :: * -> *) where
  fmap :: (a -> b) -> f a -> f b
{% endhighlight %}

fmap对应了上述定义中从C中的morphism到D中的morphism之间的映射。那么C和D究竟是什么呢？

C这个范畴被称为Hask，它的objects为haskell中的所有类型，morphisms为所有haskell函数，haskell中的函数满足结合律，所以它是一个cat。这里haskell中的类型不仅仅包括集合，还有一些高阶的类型，故Hask和Set这个cat是不等价的。

至于D嘛，就要看你的functor是做什么的了，比如对应的是list，那么D就是由所有list类型组成的category。此时的fmap就是我们熟知的lisp中的map函数。

我对functor的理解就是，从D中找到C中对应的东西之后，套上F的标签即可。

### Definition of Monad

首先，一个monad是一个functor，它从cat C映射到C自身，即 \\(T: C \to C\\)，这样的functor被叫做endofunctor。光是这样还不足够，需要有两个natural transformations:

1. \\(\eta: 1\_C \to T\\) 从C上的identity functor(所有的部件映射到自身)到T的映射
2. \\(\mu: T \circ T \to T\\) 从两个T的复合所形成的endofunctor到T的映射

这里我就不展开关于natural transformation的定义了，简单来说就是functors之间的映射，所以这里的抽象层级又高了，这也就是范畴论绕人的地方。

它们要满足的游戏规则很简单，一图流：

![monad](/assets/images/article/monad_laws1.png)

或者，为了避免使用natural transformation，这样来简化定义：

1. T是C上的endofunctor，这点没变
2. 对于C中的任意object X，有如下两个morphisms(这和C中的morphisms有层次上的差异，不过并不需要理会)
    1. \\(\eta\_X: X \to T(X)\\)
    2. \\(\mu\_X: T(T(X)) \to T(X)\\)

规则变为：

![monad](/assets/images/article/monad_laws2.png)

### A monad in X is just a monoid in the category of endofunctors of X

首先，X是一个cat，"the category of endofunctors" 是这样的一个cat，其中的objects是从X到X的endofunctor，morphisms是它们之间的natural transformations.

这些endofunctors中，可以被称作monad的那些，必须满足上一节描述的条件，而这些条件正是称为上述范畴中的一个monoid object的条件。这里的monoid object，或者简称monoid，也是范畴论中的概念，是群论中“么半群”的扩展，Set(集合这个范畴)中的monoid object就是群论中的monoid。

我不想被monoid object这个概念再绕进去了，我们直接跟么半群进行比较吧，一个monoid就是一个缺少逆的群，包括：

1. 一个集合S
2. 一个S上的二元运算 \\(S \cdot S \to S\\)
3. 一个S上的么元 \\(e: S\\)

它需要满足：

1. 结合律 \\(a \cdot (b \cdot c) = (a \cdot b) \cdot c\\) 对应上图中的左侧，等式左边对应路径：右->下，右边对应：下->右
2. 单位元 \\(a \cdot e = e \cdot a = a\\)，对应上图中的右侧

所以，我觉得严格地说，这句话的中文翻译“Monad就是自函子范畴上的么半群”是不对的，因为：

1. 并不是所有范畴上的自函子构成的范畴，（我不知道所有范畴的所有自函子是否能构成范畴，总感觉这包含自指的定义有些问题）
2. 并不是么半群，而是范畴论中的monoid object，（不知道怎么翻译，我觉得至少不能跟群混起来吧）

### From Category Theory To Haskell

Haskell中的定义如下：

{% highlight haskell %}
class Functor m => Monad m where
  return :: a -> m a
  (>>=)  :: m a -> (a -> m b) -> m b
{% endhighlight %}

需要满足：

1. Left unit: `(return a) >>= k = k a`
2. Right unit: `m >>= return = m`
3. Associative: `m >>= (\a -> (k a) >>= (\b -> h b)) = (m >>= (\a -> k a)) >>= (\b -> h b)`

首先，haskell中的monad都是haskell中的functor，所以它们的C都是Hask这个范畴，那么问题来了，之前说了functor是从Hask到它的子范畴的映射，怎么还能是endofunctor呢？事实上对于任意的functor，我们可以任意扩展它的目标范畴，因为根据定义，所有的限定词都是存在，干脆扩充到Hask算了，于是haskell中的所有monad都是Hask到自身的endofunctor.

上面的return对应的自然是\\(\eta\\)，这个很好理解，但是下面的这个bind是什么鬼？规则又和上面的图片有何关联？

首先，我们需要一个与上边的\\(\mu\\)对应的操作join，并且它的表示能力是与bind完全等价的。

{% highlight haskell %}
join :: Monad m => m (m a) -> m a
join x = x >>= id

(>>=) :: Monad m => m a -> (a -> m b) -> m b
x >>= f = join(fmap f x)
{% endhighlight %}

有了定义之后，通过简单地代换不难验证，上边的三条规则与下述规则是等价的：

1. `join . fmap join = join . join`
2. `join . fmap return = join . return = id`
3. `return . f = fmap f . return`
4. `join . fmap (fmap f) = fmap f . join`
5. `fmap id = id`
6. `fmap (f . g) = fmap f . fmap g`

事实上，可以这样从这六条规则推出上述三条：

1. Left unit: `(return a) >>= k = join(fmap k (return a)) = join(return(k a)) = (k a)` 用到了规则2和3
2. Right unit: `m >>= return = join(fmap return m) = m` 用到了规则2
3. Associative: 将bind替换为join后利用规则6直接得到

又，将join替换成\\(\mu\\), return替换成\\(\eta\\)，容易得到：

* 后六条规则中的5和6来自functor的约束，无需多加说明
* 对于规则1，对应上图左侧，等式左边对应路径：右->下，右边对应路径：下->右
* 对于规则2，对应上图右侧，等式左边对应路径：下->右，等式中间对应路径：右->下
* 对于3-4，可以通过下面的示意图说明，假设f为C上的morphism \\(f: A \to B\\)，A和B均为C中的Objects

![monad](/assets/images/article/monad_law3.png)

至此，两种monad的定义得到了统一，happy ending.

## The essence of FP

"The essence of functional programming" 这篇文章中给出了多个利用monad来灵活地扩展解释器的例子，让人能够直观地体会到monad的好处。

另外，该文章还指出了monad和CPS的微妙联系，如果我能邻会精神的话，也许会有后文...

## References

* [Monoid (category theory)](https://en.wikipedia.org/wiki/Monoid_(category_theory\))
* [Monad (category theory)](https://en.wikipedia.org/wiki/Monad_(category_theory\))
* [Natural transformation](https://en.wikipedia.org/wiki/Natural_transformation)
* [Haskell/Category theory](https://en.wikibooks.org/wiki/Haskell/Category_theory)
* Wadler, Philip. "The essence of functional programming." Proceedings of the 19th ACM SIGPLAN-SIGACT symposium on Principles of programming languages. ACM, 1992.
