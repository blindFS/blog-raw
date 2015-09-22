---
layout: post
title: "What the hell are Monads?"
description: ""
category: PLT
tags: Haskell
---
{% include JB/setup %}

## 书上是这样描述的...

在《Learn You a Haskell for Great Good!》这本书中是这么描述 Monads 的:
Monads 是强化版的 Applicative functors 就像 Applicative functors 是强化版的 functors 一样。

简单来说：

* functors 就是可以 fmap 的数据类型
* Applicative functors 这个玩意，不好描述啊... 我的理解是这玩意的功能其实跟 Monads 差不多，
数学形式不同，Monads 更灵活，于是这玩意显得比较鸡肋...

定义与功能：

{% highlight haskell %}
class Functor (f :: * -> *) where
  fmap :: (a -> b) -> f a -> f b

class Functor f => Applicative (f :: * -> *) where
  pure :: a -> f a
  (<*>) :: f (a -> b) -> f a -> f b
  (*>) :: f a -> f b -> f b
  (<*) :: f a -> f b -> f a)

(*) <$> Just 2 <*> Just 8 -- Just 16
(-) <$> [3, 4] <*> [1, 2, 3] -- [2, 1, 0, 3, 2, 1]
{% endhighlight %}

* Maybe 作为 Applicative 使用的目的显然是为了处理异常，即 Nothing
* [] 的目的则是为了取笛卡尔积，也顺便用[]处理了异常

不同的引入目的导致我不能很好地理解如何巧妙的来使用之，Monads 亦是如此。所以作为一个菜逼，
我姑且将书上的部分抄过来...

### Monads 的定义

{% highlight haskell %}
class Monad (m :: * -> *) where
  (>>=) :: m a -> (a -> m b) -> m b
  (>>) :: m a -> m b -> m b
  m >> n = m >>= \_ -> n
  return :: a -> m a
  fail :: String -> m a
{% endhighlight %}

* \>\> 类似于 \*>，相当于给定一个缺省值...
* return 类似于 pure
* fail 主要在类型匹配失败的时候使用，暂不考虑
* 于是两者的主要区别就是 \>\>= 与 <\*\> 的类型，我将其理解为，对数据类型的打包，拆包的方式不同

#### Maybe 作为 Monad
<br>
{% highlight haskell %}
instance Monads Maybe where
  return x = Just x
  Nothing >>= f = Nothing
  Just x >>= f = f x
  fail _ = Nothing


Nothing >>= (\x -> Just "!" >>= (\y -> Just (show x ++ y))) -- Nothing
Just 3 >>= (\x -> Nothing >>= (\y -> Just (show x ++ y))) -- Nothing
Just 3 >>= (\x -> Just "!" >>= (\y -> Nothing)) -- Nothing
Nothing >> Just 3 -- Nothing
Just 3 >> Just 4 -- Just 4
{% endhighlight %}

可以看出 Maybe 作为 Monad 来使用主要还是希望用 Nothing 来处理异常情况，貌似没有啥稀奇的。
巧的是，haskell 为这一类的情形设计了特殊的语法糖 --- do，于是我们可以用后一种写法来替代前一种：

{% highlight haskell %}
foo :: Maybe String
foo = Just 3 >>= (\x ->
      Just "!" >>= (\y ->
      Just (show x ++ y)))

foo :: Maybe String
foo = do
    x <- Just 3
    y <- Just "!"
    Just (show x ++ y)
{% endhighlight %}

这个造型就跟 IO 的写法很像了，事实上 IO 就是 Monad 的一种。
之前看好多人将 Monad 认作是处理副作用的方式，我认为不准确，Monad 只是碰巧被用来处理了
副作用，其本身只是一种数学定义，具体用来干啥得要根据具体的应用场景来确定。

* 其中每个 <- 就好像将一个包裹好的数据包拆封，然后将需要的数据提取出来并绑定名称。
* 不带 <- 的表达式就相当于用 >> 连接。
* 整个语法类似面向过程的写法，所以也有人把 Monad 理解为用纯函数的方式实现类似面向过程的效果。

#### List 作为 Monad
<br>
{% highlight haskell %}
instance Monad [] where
  return x = [x]
  xs >>= f = concat (map f xs)
  fail _ = []

[3, 4, 5] >>= \x -> [x, -x] -- [3, -3, 4, -4, 5, -5]
[5, 6, 7] >> [1] -- [1, 1, 1]
{% endhighlight %}

还是可以用来实现笛卡尔积...
值得一提的是 List Comprehension 例如 `[(n, ch) | n <- [1, 2], ch <- ['a', 'b']]`
其实就是 do 语法的又一个语法糖，他们最终都会被翻译成 \>\>= 的形式

为了实现 List Comprehension 中的条件过滤，需要引入 class MonadPlus 和 guard 函数。
MonadPlus 跟 Monoid 又有好多共同之处，细节不描述了，总之最后大概是这样的效果:

{% highlight haskell %}
sevensOnly :: [Int]
sevensOnly = do
  x <- [1..50]
  guard ('7' `elem` show x)
  return x

-- 等效于
[x | x <- [1..50], '7' `elem` show x]
{% endhighlight %}

### Monad Laws

Monad 的 instance 并不一定遵循以下的定律，但是真正的 Monad 必须...

{% highlight haskell %}
-- 以下等式恒成立
(return x >>= f) == f x
(m >>= return) == m
((m >>= f) >>= g) == m >>= (\x -> f x >>= g)
{% endhighlight %}

直觉上来看，这三个等式的成立都是很直观的，至少从给出的例子看来是符合定义的，至于符合这种数学规则的运算还有哪些，
Monads 还有哪些实际的用途? 且听下回分解...
