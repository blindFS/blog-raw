---
layout: post
title: "Side effects of python"
description: ""
category: cheatsheet
tags: python
---
{% include JB/setup %}

## blablabla

今天debug一个python脚本，费了很大的功夫，最后发现是由于一个函数的副作用导致的。
于是稍微查阅了下相关资料。
最简单的例子如下:
{% highlight python %}
a = []
b = a
a.append(1)
print b
print id(a) == id(b)
{% endhighlight %}
修改了a，b就会跟着改，因为b只是a的一个索引。如果不对a或者b进行重新赋值，a和b就会一直
共享一个id。所以append函数带有副作用(修改了对象)。
在lisp里，带有副作用的函数通常都是n打头，很好辨识。python里不同，所以通常带有副作用的函数
没有返回值，否则不利于debug。我觉得user defined functions最好都别带副作用。

## copy() and deepcopy()

这两个函数在copy这个包中，有助于消除函数的副作用。
说起这两个函数，我最早看见它们是在viml里。python里的这两个函数的作用跟viml里的如出一辙。

文档里的描述如下:
{% highlight text %}
The difference between shallow and deep copying is only relevant for
compound objects (objects that contain other objects, like lists or
class instances).

- A shallow copy constructs a new compound object and then (to the
    extent possible) inserts *the same objects* into it that the
    original contains.

- A deep copy constructs a new compound object and then, recursively,
    inserts *copies* into it of the objects found in the original.
{% endhighlight %}

简单来说就是如果B是A的浅拷贝，那么修改A并不会修改B，但是修改了A中的某个元素(比如用append修改了A中的某个list)
则B中的对应元素同样被修改。如果为深拷贝，不论如何修改A或其中元素，B都不发生改变。

## Functional programming in python

从文档里摘抄python函数式编程的一些摘要。
函数式的有点:

* 易于证明
* 模块化
* 容易调试
* 降低耦合

### Iterators

* iter() .... 必须通过next()调用获得返回值
* `tuple(iter([1, 2, 3]))`
* `a, b = iter([1, 2])`
* 支持iter的数据结构，list， tuple， dict，set

### List comprehensions

python的listcomps和genexps是从haskell借鉴的。
语法如下:

{% highlight python %}
( expression for expr in sequence1
             if condition1
             for expr2 in sequence2
             if condition2
             for expr3 in sequence3 ...
             if condition3
             for exprN in sequenceN
             if conditionN )
{% endhighlight %}

### Generators

generators函数返回一个iterator，当调用next()时继续计算，类似haskell的惰性求值。

{% highlight python%}
def generate_ints(N):
    for i in range(N):
        yield i
{% endhighlight %}

python2.5 之后的版本允许修改generator的值。具体参照[文档](https://docs.python.org/2/howto/functional.html#passing-values-into-a-generator)

### Built-in functions

* `map(f, iterA, iterB, ...) -> [f(iterA[0], iterB[0], ...), ...]`
* `filter(predict, iter)`

这两个函数太常见，viml里都有，其它函数式语言就更别提了

* `reduce(func, iter[, init_val])` 类似于haskell的foldl
* `enumerate(iter)` 返回值为 [(index, elem)]
* `sorted(iterable, [cmp=None], [key=None], [reverse=False])`
* `any(iter)` or `all(iter)` 组合判断语句 any([0, 1, 0]) -> True

### Lambda expression

python中lambda表达式的语法: `lambda para1, para2, ... : expression`
好像没啥好说的...

### The itertools module

* `itertools.imap(...)`
* `itertools.ifilter(...)`
* `itertools.count(1)` -> 1, 2, 3 ...
* `itertools.cycle([1, 2, 3])` -> 1, 2, 3, 1, 2, 3 ...
* `itertools.chain(['a', 'b', 'c'], [1, 2, 3], ...)` -> 'a', 'b', 'c', 1, 2, 3 ...
* `itertools.izip(['a', 'b', 'c'], [1, 2, 3], ...)` -> ('a', 1, ...), ('b', 2, ...), ('c', 3, ...) 内置函数zip()的惰性版本
* `itertools.islice(iter, [start], stop, [step])` 生成等差index的子列
* `itertools.takewhile(predict, iter)` haskell中的takeWhile ...
* `itertools.dropwhile(predict, iter)` haskell中的dropWhile ...
* `itertools.groupby(iter, key_func=None)` 不太描述的清楚...抄个例子

{% highlight python %}
city_list = [('Decatur', 'AL'), ('Huntsville', 'AL'), ('Selma', 'AL'),
             ('Anchorage', 'AK'), ('Nome', 'AK'),
             ('Flagstaff', 'AZ'), ('Phoenix', 'AZ'), ('Tucson', 'AZ'),
             ...
            ]

def get_state ((city, state)):
    return state

itertools.groupby(city_list, get_state) =>
  ('AL', iterator-1),
  ('AK', iterator-2),
  ('AZ', iterator-3), ...

where
iterator-1 =>
  ('Decatur', 'AL'), ('Huntsville', 'AL'), ('Selma', 'AL')
iterator-2 =>
  ('Anchorage', 'AK'), ('Nome', 'AK')
iterator-3 =>
  ('Flagstaff', 'AZ'), ('Phoenix', 'AZ'), ('Tucson', 'AZ')
{% endhighlight %}
iter 必须按照key的某种方式排序好了才行

### The functools module

* `functions.partial(function, arg1, arg2, ... kwarg1=value1, kwarg2=value2)` 跟haskell中的部分函数一个意思
