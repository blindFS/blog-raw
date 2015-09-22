---
layout: post
title: "Proof of weak normalization property in STLC"
description: ""
category: PLT
tags: Coq logic lambda-calculus
---
{% include JB/setup %}

## 动机

十多天前我在software fundation的练习中过了一遍有关STLC的weak normalization性质的[证明](https://github.com/blindFS/Software-Foundations-Solutions/blob/master/Norm.v)。
当时有些任务心态，想着把上面留的坑填完就完事了，好多大段的引理证明不仅没仔细看，也没有细想引理的用处。

前几天无意中翻到了王垠的[一篇老文](http://www.yinwang.org/blog-cn/2013/04/26/reason-and-proof/)，于是试图回忆这个定理的证明过程，却发现脑中是空白的，无奈翻出之前的形式化证明从头屡一屡。

由于我的表述能力的限制，以及我对此证明本质的粗浅认识，这将很难成为一篇好的科普文。另外此文只涉及到关于此性质的核心证明(very informal)，其中可能涉及到许多前文已经证明过的引理，如果想了解完整的证明，请参照software fundation或相关文献。

## 准备工作

### 什么是weak normalization ?

简单来说，在STLC中的良构(指的是well-typed)表达式，在\\(\beta-reduction\\)的操作语义下，能够停机(halts)。
此处停机指的是无法继续reduction，那么根据STLC的progress特性，即：任何非value的良构表达式都能够继续执行reduction，可以得到normalization特性的另一个描述。

任何STLC中的well-typed-term，可以经过有限步骤的reduction操作，得到一个value。此处略去关于value的解释若干...

举个简单的例子，\\((\lambda x. (x x))(\lambda x. (x x))\\) 这个表达式在不带类型的lambda calculus中是良构的，它执行一步reduction之后得到它本身，于是它不会停机。然而在STLC中，我们无法给它加上合适的类型，于是在STLC中，我们找不到对应的良构的表达式。至于为什么无法加上合适类型，此处省略STLC的类型推导规则若干...

如果使用Coq来描述，就是这样:

{% highlight coq %}
Definition halts  (t:tm) : Prop :=  exists t', t ==>* t' /\  value t'.
Theorem normalization : forall t T, has_type empty t T -> halts t.
{% endhighlight %}

### 关于良构表达式的一个加强性质

我们现在只关心最简单的STLC，不包含任何不必要的语法，如if，pair... 这些扩充的语法并不会影响证明的本质。
看过上文提到的形式化证明的同志应该知道，Coq中对此定理证明的最关键步骤就是构造一个比has_type更强的有关表达式和类型的关系R。

要证明一个表达式t和一个类型T之间具有关系R，我们需要如下条件

1. t是closed，即没有自由变量, 这很自然，应为具有自由变量的表达式是不完整的，我们并不关心
2. 根据原有的类型推导系统，我们可以得出t具有类型T, 这正是之前我们关于良构的定义(has_type)，后面我们将证明，仅通过良构的假设，我们就能得到对应的R关系的证明
3. t halts
4. R关系不会被函数作用操作所破坏
    1. 如果T是STLC语言中定义的基本类型，则没有任何多余的约束
    2. 如果T是一种函数类型，不妨设为 `T1 -> T2` 则t作用在任何与T1满足关系R的表达式t'上之后所得到的表达式t t'将与T2具有关系R

在Coq中，这种关系在通过inductive definition声明的时候会遇到问题(strict positivity requirement)，但是可以通过一个递归函数来处理，这是很有意思的一种方式，但是跟证明本身没有太大的联系。

{% highlight coq %}
Fixpoint R (T:ty) (t:tm) {struct T} : Prop :=
  has_type empty t T /\ halts t /\
    (match T with
       | TBool  => True
       | TArrow T1 T2 => (forall s, R T1 s -> R T2 (tapp t s))
{% endhighlight %}

前三个条件可以综合理解为t在有限步骤的归约之后可以得到一个具有类型T的value

### Context & Env

* context 是一组id(变量)与类型的映射, [(id, type)]，用于类型推导
* env 则是一组id与value的映射，[(id, term)], 用于归约操作，将表达式中的变量替换为value，替换操作从左往右进行

如果一个env e和一个context c满足：

1. 每一组对应位置的id相同
2. 在每一组对应位置上，e中的term v和c中的type T具有关系R

就说e是c的一个实例。

* msubst env t操作，通过从左往右的顺序(有重复id时以最左边的value替换)，依次以env中的value替换表达式t中对应的自由变量
* mextend empty context操作，通过从右往左的顺序(重复id时，最左边的类型将其它覆盖)扩增

{% highlight coq %}
Fixpoint msubst (ss:env) (t:tm) {struct ss} : tm :=
match ss with
| nil => t
| ((x,s)::ss') => msubst ss' ([x:=s]t)
end.
{% endhighlight %}

## Proof

有了以上的概念，下面我们通过top-down的方式来寻找Norm性质的证明。

1. 要证明Norm，我们需要证明对于任意具有类型T的闭合表达式t终止
2. 因为如果t和T具有关系R，则t终止(R蕴含的性质之一)，于是我们可以通过证明“任意具有类型T的闭合表达式t满足t和T具有关系R”来证明原命题
3. 于是我们需要一个引理，它以良构(has_type)作为前提，以关系R作为结论

### Lemma msubst_R

如果根据某context c(此时不要求t为closed)我们可以得出t具有类型T，并且env e为c的一个实例，则(msubst e t)和T具有关系R。

`Lemma msubst_R : forall c e t T, has_type (mextend empty c) t T -> instantiation c e -> R T (msubst e t).`

要证明上述引理，我们对第一个条件作归纳，要得到 `has_type (mextend empty c) t T`, 根据has_type的归纳定义有如下3种情况：

1. t是一个变量，设为x，x在c中有定义，且c给x定义的最新的类型为T
    1. 根据e是c的一个实例，那么x在e中必然也有定义，考虑x在e中最靠左的出现时对应的value v，根据替换的顺序，有 `msubst e t = v`
    2. 那么剩下来只需证明 `R T v`，由于c给x定义的最新的类型T取决于x在c中最靠左的出现(根据mextend覆盖的顺序)
    3. e是c的实例，于是x在e中最左出现的位置与x在c中最左出现的位置是相同的(根据实例的性质1)，于是v与T是位置对应的，于是有 `R T v` (根据实例的性质2)，于是第一种情况成立
2. t是一个lambda函数，设为\\(\lambda x:T1. t'\\), 根据c和x具有T1，得出t'具有类型T2，`T = T1 -> T2`
    1. 令e'为e中去掉所有关于x的项后得到的env，则 t'' = \\(\lambda x:T1. (msubst\ e'\ t')\\)与T具有关系R (待证明)
    2. 推论1 :: t'' 是closed
        1. 因为所有t'中的自由变量都在c中出现，否则无法得出类型T2，进而所有自由变量在e中出现
        2. e是c的实例，e中的value都是closed，否则无法对其进行类型推导，没有类型就得不到R关系，与实例的性质2矛盾
        3. 于是将t'中的所有自由变量替换为closed value之后得到的还是closed-term
    3. 推论2 :: t''具有类型T
        1. 由于所有替换操作都是在对应的类型假设下进行的，于是替换操作不会更改整个表达式的类型，具体证明细节自行脑补...
    4. 要证明1，根据R所需的4个条件，我们只剩3和4
        1. 3是不言自明的，所有的lambda函数都视作value，value都是终止的
        2. 条件4是说，对于任意满足`R T1 s`的s，`R T2 (t'' s)`
    5. 证明最后一个条件
        1. 根据R的1-3有，s经过有限步的归约后得到一个具有类型T1的value v，显然`R T1 v`成立
        2. 令`t1 = (msubst e' [x := v]t')`，即t'中先将x替换成v，再进行e'(不含x)中的替换，通过归纳假设(对类型推导进行的归纳，于是可以在T2上应用msubst_R)，容易证明`R T2 t1`
        3. 由于s归约得到v，则容易得到(t'' s)归约得到(t'' v)，进而归约得到t1
        4. 根据R的条件4，直觉上可以感觉到归约操作的前后R的性质保持不变，假设这个性质满足(稍后通过step_preserves_R'/multistep_preserves_R'加以说明)。那么根据`R T2 t1`可以得到`R T2 (t'' s)`，这样第二种情况的证明就完成了
3. t是一个函数调用，t = t1 t2, t1具有类型 T1 -> T2, t2具有类型T1，
    1. 推论1 :: `msubst e t = (msubst e t1) (msubst e t2)`，根据替换操作的语义和自由变量的定义很容易脑补
    2. 根据两个归纳假设容易得到`R (T1 -> T2) (msubst e t1)`, `R T1 (msubst e t2)`
    3. 根据R的条件4，有`R T2 (msubst e t1) (msubst e t2)`，即`R T2 (msubst e t)`，亦即结论，于是第三种情况成立

至此，要得到引理msubst_R，唯一需要继续证明的就是：归约前后R关系的一致性，即下一条引理。

### Lemma preserves_R'

如果t具有类型T，且t单步归约到t'，t'与T具有关系R，则t与T具有关系R

`Lemma step_preserves_R' : forall T t t', has_type empty t T -> (t ==> t') -> R T t' -> R T t.`

对T作归纳，得到如下几种情况：

1. T是基本类型，R的条件4不作附加约束，于是只需证明t终止，应为t'与T具有关系R，于是t'终止，从而t也终止(步骤+1)
2. T是函数类型，`T = T1 -> T2`，终止属性同样得到满足，只需对条件4加以证明，即对于任意的s满足`R T1 s`， 有`R T2 (t s)`
    1. 根据`R T t'`的条件4得到对于任意s满足`R T1 s`，有`R T2 (t' s)`
    2. 又(t s)单步归约至(t' s), 通过归纳假设(在类型T2上)容易得到，`R T1 s` -> `R T2 (t' s)` -> `R T2 (t s)`

得到了单步的属性之后，很容易结合preservation属性(归约后的类型不变)脑补出下面的多步引理：

`Lemma multistep_preserves_R' : forall T t t', has_type empty t T -> (t ==>* t') -> R T t' -> R T t.`

根据这个引理，便可以证明msubst_R (见证明步骤2.5.4)

### Finally

有了msubst_R之后，通过取c和e为空list，便能得出“任意具有类型T的闭合表达式t满足`R T t`”这个结论，
从而，STLC的Norm属性得到了最终的证明。

证明的思路是围绕对类型作归纳展开的，整个思路是将初始的类型T一层层地剥开，直到基础类型。

事实上STLC更强的性质，即strong normalization，说的是任何良构表达式必定停机，它的证明留到以后有时间再读吧...

写困了，就这样吧...

## Referrence

* [http://www.seas.upenn.edu/~bcpierce/sf/current/Norm.html](http://www.seas.upenn.edu/~bcpierce/sf/current/Norm.html)
* Tait, William W. "Intensional interpretations of functionals of finite type I." The Journal of Symbolic Logic 32.02 (1967): 198-212.
