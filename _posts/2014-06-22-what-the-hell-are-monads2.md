---
layout: post
title: "Useful instances of Monad"
description: ""
category: notes
tags: Haskell
---
{% include JB/setup %}

## 煮些栗子

### Writer

用于添加附加信息，如日志...

{% highlight haskell %}
newtype Writer w a = Writer {runWriter :: (a, w)}
{% endhighlight %}

* 在 Control.Monad.Writer 包中
* w 是附加信息，必须是 monoid
* 如果 w 是 Int 这种有多重 monoid 定义的类型的话，可以用 newtype 来创建相应的实例以便区分
* a 就是 想要获取的数据，于是可以看成是把 a 放进了一个附加了 w 的包装盒

{% highlight haskell %}
instance (Monoid w) => Monad (Writer w) where
    return x = Writer (x, mempty)
    m >>= k = Writer $ let
            (a, w)  = runWriter m
            (b, w') = runWriter (k a)
            in (b, w `mappend` w')
{% endhighlight %}

这货我在最新的 mtl 2.2.1 中发现改动较大，Writer 改为通过 WriterT 来定义了，
WriterT 是一种 Monad transformer，关于这些内容以后再加以讨论，主要是我还不太懂...
这里姑且就参照 1.1.0.2 版本的源码来理解。

\>\>=的步骤:

1. 得到历史值a，历史附加值w
2. 用a作参数调用k，得到新值b和新附加信息w'
3. 用b与w,w'的合体作为返回值

#### MonadWriter

Writer 和 MonadWriter 有密切联系，MonadWriter 是这么一回事:

{% highlight haskell %}
class (Monoid w, Monad m) => MonadWriter w m | m -> w where
    -- | @'tell' w@ is an action that produces the output @w@.
    tell   :: w -> m ()
    -- | @'listen' m@ is an action that executes the action @m@ and adds
    -- its output to the value of the computation.
    listen :: m a -> m (a, w)
    -- | @'pass' m@ is an action that executes the action @m@, which
    -- returns a value and a function, and returns the value, applying
    -- the function to the output.
    pass   :: m (a, w -> w) -> m a

instance (Monoid w) => MonadWriter w (Writer w) where
    tell   w = Writer ((), w)
    listen m = Writer $ let (a, w) = runWriter m in ((a, w), w)
    pass   m = Writer $ let ((a, f), w) = runWriter m in (a, f w)
{% endhighlight %}

* 这里w的kind 为 `* -> Constraint`, 而m的kind则是 `(* -> *) -> Constraint`

煮个栗子:

{% highlight haskell %}
import Control.Monad.Writer

gcd' :: Int -> Int -> Writer [String] Int
gcd' a b
    | b == 0 = do
        tell ["Finished with " ++ show a]
        return a
    | otherwise = do
        tell [show a ++ " mod " ++ show b ++ " = " ++ show (a `mod` b)]
        gcd' b (a `mod` b)

gcdReverse :: Int -> Int -> Writer [String] Int
gcdReverse a b
    | b == 0 = do
        tell ["Finished with " ++ show a]
        return a
    | otherwise = do
        result <- gcdReverse b (a `mod` b)
        tell [show a ++ " mod " ++ show b ++ " = " ++ show (a `mod` b)]
        return result
{% endhighlight %}

这里的 tell 为啥能 work 我想了很久...
把 gcdReverse 的后面部分写成这样或许好懂些:

{% highlight haskell %}
| otherwise = gcdReverse b (a `mod` b) >>= (\result ->
        tell [show a ++ " mod " ++ show b ++ " = " ++ show (a `mod` b)]
        >> return result)
{% endhighlight %}

事实上这里 Writer 的用法是和副作用有关的，纯函数需要满足每次以相同参数调用时都获得
相同的结果，而这类以附加信息为目的的 Monad 中，所附加的信息可以看作是全局变量，
即函数本身不关心它的初始状态。那么在引入 do 语法之后，只有那些特定的函数(如 tell)具有
副作用(如mappend)，那么如果我们将这些语句从 do 中去除，剩下的函数就相当于只是关于
我们关心的主值的纯函数。
<br/>
至于为啥是这个道理，把 do 完全展开之后把 tell 代入便能看出来。
那么用同样的方式来理解，

* listen，就是用全局变量来影响局部变量
* pass，就是用给定的函数来修改全局变量，摆脱了 mappend 的局限性

### Reader

Reader monad 就是 function monad，就是拿一堆单参数，且参数类型相同的函数来生成另一个这样的函数。
我觉得这玩意的逻辑价值大于实用价值...

{% highlight haskell %}
instance Monad ((->) r) where
    return x = \_ -> x
    h >>= f = \w -> f (h w) w
{% endhighlight %}

根据定义，有:

{% highlight haskell %}
import Control.Monad.Instances

addStuff :: Int -> Int

addStuff = do
    a <- (*2)
    b <- (+10)
    return (a+b)

-- =
addStuff = (*2) >>= (\a ->
           (+10) >>= (\b ->
           \_ -> (a+b))
-- =
addStuff = (*2) >>= (\a ->
           \w -> (\b -> \_ -> (a+b)) ((+10) w) w)
-- =
addStuff = (*2) >>= (\a ->
           \w -> (\_ -> (a+10+w)) w)
-- =
addStuff = (*2) >>= (\a -> \w -> a+10+w)
-- =
addStuff = \w2 -> (\a -> \w -> a+10+w) (w2*2) w2
-- =
addStuff = \w2 -> (\w -> w2*2+10+w) w2
-- =
addStuff = \w -> w*2+10+w
-- =
addStuff w = w*2+10+w
{% endhighlight %}

从直观上理解，上例中的 a，b 在 do 中都可以当作是已然算得的 Int，虽然它们
都缺少一个参数... 相当于这样的效果:

{% highlight haskell %}
addStuff :: Int -> Int
addStuff x = let
    a = (*2) x
    b = (+10) x
    in a+b
{% endhighlight %}

### State

想象用 StdGen 生成随机数的场景，State 就是根据旧状态生成一个值以及新状态的过程:

{% highlight haskell %}
newtype State s a = State { runState :: s -> (a, s) }

instance Monad (State s) where
    return x = State $ \s -> (x, s)
    (State h) >>= f = State $ \s -> let (a, newState) = h s
                                        (State g) = f a
                                    in g newState
{% endhighlight %}

* 注意这里s的 kind 为 Constraint
* 一个 State Monad 是一个转化函数，即 h 是一个 s -\> (a, s) 的函数
* State s 是个 `* -> *` 的类型构造器，而 State h 则是一个类型为 State s a 的变量，这点上我第一眼看的时候被绕晕了，这点上我第一眼看的时候被绕晕了...
* 这里被封装了的数据类型其实是 a，f 根据一个特定的 a 可以生成一个 State Monad，即一个转化函数
* bind 完成之后得到的转化函数的执行过程如下:
    1. 根据参数s和转换函数h 算得a和newState
    2. 通过f和a得到新的转化函数g
    3. 将g作用于newState
    4. 返回所计算得的(b, newState')
* \>\> 连接两个转化过程，即不论第一个转化过程返回何值a，第二个过程继续操作

用 State 来实现栈操作:

{% highlight haskell %}
import Control.Monad.State

type Stack = [Int]

pop :: State Stack Int
pop = state $ \(x:xs) -> (x, xs)

push :: Int -> State Stack ()
push a = state $ \xs -> ((), a:xs)

stackManip :: State Stack Int
stackManip = do
    push 3
    a <- pop
    pop
{% endhighlight %}

看上去很美好...

#### MonadState

还有个相关的 type class 叫做 MonadState，长这样:

{% highlight haskell %}
class Monad m => MonadState s (m :: * -> *) | m -> s where
    get :: m s
    put :: s -> m ()
    state :: (s -> (a, s)) -> m a

instance MonadState s (State s) where
    get   = State $ \s -> (s, s)
    put s = State $ \_ -> ((), s)
{% endhighlight %}

State 作为 MonadState 的 instance，get 和 put s 都返回一个 State，get 是一个获得 s 的转化过程，
put s 则是修改的转化过程
state 则是将一个转化函数封装为 Monad

### Error

Error 仅仅是用 Either 对 Maybe 作了简单的扩展。

{% highlight haskell %}
instance (Error e) => Monad (Either e) where
    return x = Right x
    Right x >>= f = f x
    Left err >>= f = Left err
    fail msg = Left (strMsg msg)

strMsg :: (Error a) => String -> a
{% endhighlight %}

这个定义跟 Maybe 太像了，没啥好说的，但是如果要在 ghci 中显示结果需要显式指定 Either 的类型，
如 `Right 3 >>= \x -> return (x + 100) :: Either String Int`

好吧先就这样，后面这段时间可能要忙些别的烂事儿，关于 haskell 和 Monad 的后续更新没准就tj了。
不过在那之前我应该会先把那本入门级教材咔嚓掉。总之先把坑挖好，以后有时间再慢慢填。
