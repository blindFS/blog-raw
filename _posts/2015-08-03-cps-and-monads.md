---
layout: post
title: "CPS and Monads"
description: ""
category: PLT
tags: haskell
---
{% include JB/setup %}


## Aha

最近搬了个地儿，离开了生活了近6年的合肥。呆在合肥的时候不觉得她有什么不好，现在想想空气质量是真不照；呆在合肥的时候不觉得她有什么好，现在想想吃饭是真便宜。

总之就是这段时间一堆烂事，导致前边挖下的坑没能及时填上。另外，随着研究方向的逐渐明确，也许不能再写这些“不务正业”的玩意了，也许会写点跟方向相关的内容，虽然我觉得这个方向上的工作纯忽悠，完全不值一提。我就是一个始终觉得别人研究的东西无比高大上，自己手上的东西都是crap的人。

## Useful Monads with Interpretor

上一篇结尾提到的那篇论文总算是看完了。既然不能完全消化，吸收，然后拉出屎来；那么我就简单粗暴地吞下去，嚼一嚼，吐出来好了（美其名曰翻译+注释）。

论文很长，肯定不能逐字翻，我主要关心的是第三章，但是直接跳过前边又不行，所以先简单节选些第二章的内容。

### An Interpretor in A Monad

先贴一段基础代码，方便后续查看。

{% highlight haskell %}
type Name = String

data Term = Var Name
          | Con Int
          | Add Term Term
          | Lam Name Term
          | App Term Term

data Value = Wrong
           | Num Int
           | Fun (Value -> M Value)

type Environment = [(Name, Value)]

showval :: Value -> String
showval Wrong   = "<wrong>"
showval (Num i) = showint i
showval (Fun f) = "<function>"

interp :: Term -> Environment -> M Value
interp (Var x) e   = lookup x e
interp (Con i) e   = unitM (Num i)
interp (Add u v) e = interp u e `bindM` (\a ->
                      interp v e `bindM` (\b ->
                      add a b))
interp (Lam x v) e = unitM (Fun (\a -> interp v ((x, a):e)))
interp (App t u) e = interp t e `bindM` (\f ->
                     interp u e `bindM` (\a ->
                     apply f a))

lookup :: Name -> Environment -> M Value
lookup x []         = unitM Wrong
lookup x ((y, b):e) = if x == y then unitM b else lookup x e

add :: Value -> Value -> M Value
add (Num i) (Num j) = unitM (Num (i + j))
add a b             = unitM Wrong

apply :: Value -> Value -> M Value
apply (Fun k) a = k a
apply f a       = unitM Wrong

test :: Term -> String
test t = showM (interp t [])
{% endhighlight %}

简单的几点说明：

* Value 以自身形态存储于 Environment，只不过每次读取的时候，我们用 unitM 将其转换为对应的 M Value，这样比直接存 M Value 肯定是要节省空间的
* 所有的函数返回值都是 M Value，M 取不同的 Monad，这个解释器就会扩充得到相应的功能
* 参数传递通过 call-by-value，因为:
    * 函数的参数类型是 Value 而不是 M Value
    * interp的最后一行是先 `interp u e` 再将值传递给 apply 的，这边的 bindM 可以想象成数据处理单元之间的管道

### Standard Interpretor

如果我们不想给这个解释器添加任何功能，我们可以将 M 定义为啥也不干，结合上篇文章里提到的概念，所谓啥也不干，是说 M 为一个 Cat -> Cat 的 identity endofunctor，写成 haskell 就是：

{% highlight haskell %}
type M a    = a

unitM a     = a
a `bindM` k = k a
showM a     = showval a
{% endhighlight %}

### Error Messages

为了给解释器添加类似 exception 的功能，我们只需要将上边的 M 替换为下面的 Monad E，先上代码：

{% highlight haskell %}
data E a              = Success a | Error String

unitE a               = Success a
errorE s              = Error s

(Success a) `bindE` k = k a
(Error s) `bindE` k   = Error s

showE (Success a)     = "Success: " ++ showval a
showE (Error s)       = "Error: " ++ s
{% endhighlight %}

思想很简单，如果每次计算是成功的，那么传递成功的结果进行后续的计算；否则，不论后边进行了什么样的操作，都返回最初的错误信息。论文中还给出了带出错位置信息的版本 P，这边就不赘述了。

### State

M 可以用于记录各种状态信息，文中给出了用于记录归约操作次数的版本 S：

{% highlight haskell %}
-- general state

type S a    = State -> (a, State)

unitS a     = \s0 -> (a, s0)
m `bindS` k = \s0 -> let (a, s1) = m s0
                         (b, s2) = k a s1
                     in (b, s2)

-- reduction count specific

type State = Int
showS m = let (a, s1) = m 0
          in "Value: " ++ showval a ++ "; " ++
             "Count: " ++ showint s1

tickS :: S ()
tickS = \s -> ((), s + 1)

apply (Fun k) a     = tickS `bindS` (\() -> k a)
add (Num i) (Num j) = tickS `bindS` (\() -> unitS (Num (i + j)))
{% endhighlight %}

注释：

* 函数的返回值类型读作：“给我一个初始状态，我给你返回一个值和一个终止状态”
  * 函数仍然是 pure 的，跟状态有关的所有信息都被包在返回值中，返回值本身以函数的形式记录了对所有不同的初始状态所要作出的应答
  * unitS 对 Value 进行封装，很好理解
  * bindS 也很明确，给定初始状态 s0，先通过 m 得到一个值 a 和一个新状态 s1，再将 a 传递给函数 k，将其返回值作用在状态 s1 上...
* tickS 设计得较为巧妙
  * apply 和 add 两个函数的执行都要将状态中记录的归约次数加1，如果每个都分开写，例如将 apply 写成 `\s -> k a (s + 1)`，就会很麻烦
  * 用 tickS 抽取出它们共同的加1操作部分，通过 bindS 拼接，那么后续只需要关注自身的逻辑就好
  * () 表示一个我们不关心的 Value

如果想要添加输出当前 count 的原语，可以这么做：

{% highlight haskell %}
fetchS :: S State
fetchS = \s -> (s, s)

data Term = ... | Count

interp Count e = fetchS `bindS` (\i -> unitS (Num i))
{% endhighlight %}

### Output

一种自然的想法是，用上边的 State 来实现输出，但是这样会导致计算的过程之中无法输出，所有的输出都积攒到了最后。正确的做法：

{% highlight haskell %}
type O a = (String, a)

unitO a = ("", a)
m `bindO` k = let (r, a = m); (s, b) = k a in (r ++ s, b)
showO (s, a) = "Output: " ++ s ++ "Value: " ++ showval a
{% endhighlight %}

通过将每个值和产生这个值过程中产生的输出字符串捆绑，通过字符串拼接进行传递。接下来添加实际输出所需的原语：

{% highlight haskell %}
outO :: Value -> O ()
outO a = (showval a ++ "; ", ())

data Term = ... | Out Term

interp (Out u) e = interp u e `bindO` (\a ->
                   outO a `bindO` (\() ->
                   unitO a))
{% endhighlight %}

Out 的实际执行过程中，调用了 outO，后者通过 showval 产生实际效果，由于 lazy evaluation，这使得在执行过程中就可以产生输出。

没想明白这样的做法怎么就 Pure 了...

## CPS Interpretor

经过前面这么长的铺垫，终于要进入正题了...

### What is CPS/Continuation ?

具体解释参见文末的引用链接。我认为 Continuation 就是一种语言本身可见的程序执行控制的抽象，比如说，它可以表示为一个函数，类型：`A -> Answer`，蕴含了对A类型的数据的操作。这样的抽象通常用于添加一些控制机制，如 exceptions, generators, coroutines...

对于 CPS，个人理解就是每个函数除了接收原来的参数之外，还需要一个 continuation 用于表示得到该函数的返回值之后还需要进行的操作，对于 CPS 的好处，参见下方 wikipedia 的链接。由于递归函数在改写为 CPS 风格之后会自动变为 tail call （详情参见维基百科中的例子），所以很久以前我一直以为它跟 TCO 是一回事...

### A Monad of Continuation

简单介绍了概念之后，我们构建这样的 Monad K:

{% highlight haskell %}
type K a = (a -> Answer) -> Answer

unitK a = \c -> c a
m `bindM` k = \c -> m (\a -> k a c)
{% endhighlight %}

在 CPS 中，函数需要传递额外的 continuation，通过 Currying，我们可以将函数返回值设置成一个接收 continuation 的函数来实现，即上面的 K a 对应的类型，读作“给我一个 continuation，还你一个结果”。

* unitK 就是将普通的 a 类型的值转化为 CPS 中对应的函数返回值的操作
* bindM 的两个参数，m 具有类型 `K a`， k 具有类型 `a -> K b`，那么根据 Monad 的类型，等号右边应该具有类型 `K b`；也就是说，`m (\a -> k a c)` 应该具有类型 Answer；`\a -> k a c` 应该具有类型 continuation，即 `a -> Answer`；...；于是类型是OK的
  * 什么意思呢？如果把 continuation 理解成“之后需要进行的操作”，那么可以作如下解释：“m 将之后需要进行的操作丢给了 k”，也就是说，不论如何，下一步执行的是 k，至于再之后，交给 k 来处理... 如此继续下去，便能够得到一个非常精确的执行流程。

将上述定义的 unit 和 bind 带入一开始的解释器中，归约后得到：

{% highlight haskell %}
interp :: Term -> Environment -> (Value -> Answer) -> Answer
interp (Var x) e   = \c -> lookup x e c
interp (Con i) e   = \c -> c (Num i)
interp (Add u v) e = \c -> interp u e (\a ->
                           interp v e (\b ->
                           add a b c))
interp (Lam x v) e = \c -> c (Fun (\a -> interp v ((x, a):e)))
interp (App t u) e = \c -> interp t e (\f ->
                           interp u e (\a ->
                           apply f a c))
{% endhighlight %}

这里的 Answer 类型可以有多种取法，最简单的，取作 Value。

### Callcc

熟悉 scheme 的应该知道 call/cc，即 call with current continuation. 下面我们会看到，这个操作可以很容易地被定义。

在谈具体的实现之前，先扯点别的。我们知道 STLC 通过 Curry-Howard isomorphism 对应到的是 intuitionistic logic，不包括排中律。如果想要将其扩充称为 classical logic，我们需要添加额外的表达式。由于排中律与 Pierce's Law 逻辑等价，我们可以通过添加一个具有类型 `((A -> B) -> A) -> A` 的表达式（对任意A，B）来实现。

这样的表达式被称作 Felleisen's \\(\mathfrak{C}\\)，而 call/cc 正是这样的表达式。

{% highlight haskell %}
callccK :: ((a -> K b) -> K a) -> K a
callccK h = \c -> let k a = \d -> c a in h k c
{% endhighlight %}

* 首先来看类型，这里 h 具有类型 `(a -> K b) -> K a`，于是 `k :: a -> K b`，等号右边的表达式具有类型 `K a`，即 `h k c :: Answer`，亦即 `K a c :: Answer`，于是类型是正确的
* 下面分析语义，这里唯一需要注意的就是对 k 的定义，说的是，如果 k 以参数 a 被调用，则忽略调用时的 continuation，直接以 c 作为 continuation 继续执行。这么描述可能还是无法和 call/cc 完全对应上，下面加入如下的原语:

{% highlight haskell %}
data Term = ... | Callcc Name Term

interp (Callcc x v) e = callccK (\k -> interp v ((x, Fun k):e))
                      = (\c -> let k a = \d -> c a in (interp v ((x, Fun k):e) c))
{% endhighlight %}

* 第二个等号是我为了阅读进行的一步替换操作
* 此处将参数 x 绑定到了函数 k，相当于起个名字，当 `interp v e'` 真正执行到对应于 k 的 apply 时，就会触发上文提到的 continuation 的切换。当然如果 v 中不包含 k 的调用，它只是将 v 进行求值。

不难验证表达式 `(Add (Con 1) (Callcc "k" (Add (Con 2) (App (Var "k") (Con 4)))))` 通过解释之后的值为 5，正如 call/cc.

## CPS to Monads

上边的例子说明了：通过选取特殊的 Monad K，我们将一个 Monad 解释器改造成了一个 CPS 解释器（通过替换掉全部的 unit 和 bind 操作）。
下面说明其相反的操作（即用 CPS 实现 Monad）也是可行的，方法是通过修改 Answer 的类型。

{% highlight haskell %}
type Answer = M Value

showK n = showM (n unitM)

promoteK :: M a -> K a
promoteK m = \c -> m `bindM` c
{% endhighlight %}

* promte 中 continuation `c :: a -> M Value`, `m :: M a`，于是类型OK
* promte 将 M Value 类型转换为 K Value 类型，从而可以传入 CPS 解释器

于是上面提到的几种 Monad 分别对应如下的 CPS 版本：

{% highlight haskell %}
errorK :: String -> (a -> E Value) -> E Value
errorK s = promoteK (errorE s)
         = \c -> (errorE s) `bindE` c
         = \c -> Error s `bindE` c
         = \c -> Error s

tickK :: (() -> S Value) -> S Value
tickK = promoteK tickS
      = \c -> tickS `bindS` c
      = \c -> (\s -> ((), s + 1)) `bindS` c
      = \c -> \s -> c () (s + 1)

outK :: Value -> (Value -> O Value) -> O Value
outK a = promoteK (outO a)
       = \c -> (outO a) `bindO` c
       = \c -> (showval a ++ "; ", ()) `bindO` c
       = \c -> let (s, b) = c () in (showval a ++ "; " ++ s, b)
{% endhighlight %}

过程已经足够详细，这里就不展开具体的分析了。

## Monads vs. CPS

根据 Wadler 的分析，Monads 提供了比 CPS 更为精细的表达能力的控制。

例如对于 Monad S (上文提到过的 State Monad) 中的类型 `S a`，它在 CPS 中对应的类型为 `(a -> S Value) -> S Value`，它包括这样的表达式 `\c -> \s -> (Wrong, s)`（此处原文中写成了 `\c -> \s -> (Wrong, c)`，我认为这是个 typo），在 Monad 中，我们可以控制这样的表达式是否能够被创建；但是 CPS 不具备这样的能力。

## References

* [Continuation-passing style](https://en.wikipedia.org/wiki/Continuation-passing_style)
* [Continuation](https://en.wikipedia.org/wiki/Continuation)
* [Tail call](https://en.wikipedia.org/wiki/Tail_call)
* [Matthias Felleisen](https://en.wikipedia.org/wiki/Matthias_Felleisen)
* Wadler, Philip. "The essence of functional programming." Proceedings of the 19th ACM SIGPLAN-SIGACT symposium on Principles of programming languages. ACM, 1992.
