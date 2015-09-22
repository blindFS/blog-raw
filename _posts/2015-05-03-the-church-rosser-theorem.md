---
layout: post
title: "The Church-Rosser Theorem"
description: ""
category: PLT
tags: logic lambda-calculus
---
{% include JB/setup %}

## 闲扯

最近写的尽是些有的没的，完全没有干货。怎么说，最近考虑在思考人生，价值观在改变，简而言之就是又退化到科学>>技术的中二阶段。一方面看到现阶段所谓“技术产物”的各种各样的问题，另一方面由于自身智力，能力，精力的限制，没有办法对其进行改进和提升，只能采取粗暴的、眼不见为净的鸵鸟政策。其实我知道自己是躲不掉的（当然我说的是找工作），但是还是想在不得不面对之前关心些别的，或者说补救些别的，能补多少是多少吧。年轻的时候有大把时间，却不想念书，现在老了，想念书了，却没有多少时间了（有时间也架不住嗜睡）。

Anyway, 我接下来准备翻译大段的关于无类型lambda-calculus中Church-Rosser定理的证明，为什么要做这么无聊的事情？因为我觉得有趣...为什么不先完善下之前对STLC的证明？1.不求甚解是我的一贯毛（feng）病（ge）；2.这个定理在它的证明中会有一丢丢的作用，Normalization证明的补充会在之后进行。

## beta-eta-reduction

* \\(\beta-reduction\\) 就不赘述了
* \\(\beta-equivalence\\) 为其自反，对称，传递闭包，记作 \\(=\_{\beta}\\)，描述的是这样的二元关系：两个表达式可以通过若干步正向或者反向的beta归约相互转化。
* \\(\eta-reduction\\) 规定如果两个表达式作用在任意相同的表达式上，得到的结果相同，则可以认为两个表达式相同，即函数相同的定义。于是有\\(\lambda x.Mx \rightarrow\_{\eta} M, where\ x \notin FV(M)\\)
* \\(\beta\eta-reduction\\) 就是两者的结合，记作 \\(\rightarrow\_{\beta\eta}\\)
* 结合后的多步操作，即其自反，传递闭包记作 \\(\twoheadrightarrow\_{\beta\eta}\\)，equivalence, normal form的概念也有相应的扩充

## Statement of Church-Rosser Theorem

* 用双箭头表示 \\(\twoheadrightarrow\_{\beta}\\) 或者 \\(\twoheadrightarrow\_{\beta\eta}\\)

如果某M, N, P满足 \\(M \twoheadrightarrow N \land M \twoheadrightarrow P\\)，则存在某个Z，使得 \\(N \twoheadrightarrow Z \land P \twoheadrightarrow Z\\)。
就是说，不论在beta或者是beta-eta的操作语义下，如果N和P对于M都是多步可达的，那么它们必定共享某个可达的表达式Z，如下图：

![cr](/assets/images/article/Church_Rosser.png =200x)

### What does that theorem imply?

**Corollary 1** : 如果 \\(M =\_{\beta} N\\)，则存在某表达式Z，使得\\(M,N \twoheadrightarrow\_{\beta} Z\\)，对beta-eta有同样结论。

**Proof** : 前提条件等价于如下描述：存在一个有限的表达式序列\\(M\_0, M\_1, ..., M\_n\\)，其中相邻的两个表达式满足关系\\(\leftarrow\_{\beta}\\)或者\\(\rightarrow\_{\beta}\\)，且头和尾分别是M和N。

对n进行归纳，当n为0时，M与N恒等，结论显然。若n-1时成立，归纳假设，存在Z'使得\\(M \twoheadrightarrow\_{\beta} Z' \land M\_{n-1} \twoheadrightarrow\_{\beta} Z'\\)。
N和\\(M\_n\\)之间的关系有两种情况：

1. \\(N \rightarrow\_{\beta} M\_{n-1}\\) : 于是有 \\(N \twoheadrightarrow\_{\beta} Z'\\)，于是Z'即满足
2. \\(N \leftarrow\_{\beta} M\_{n-1}\\) : 我们将Church-Rosser定理作用于\\(M\_{n-1}, Z', N\\)，于是存在Z使得 \\(Z' \twoheadrightarrow\_{\beta} Z \land N \twoheadrightarrow\_{\beta} Z\\)，于是 \\(M \twoheadrightarrow\_{\beta} Z' \twoheadrightarrow\_{\beta} Z\\)，得证。

对于beta-eta有类似证明。

**Corollary 2** : 如果N是一个normal form(无法继续归约)，\\(N =\_{\beta} M\\)，则 \\(M \twoheadrightarrow\_{\beta} N\\), beta-eta类似。

**Proof** : **1**的简单推论，Z只能是N

**Corollary 3** : 如果\\(M =\_{\beta} N\\)，则其中一者的normal form也是另一者的normal form, beta-eta类似。

**Proof** : 不妨设M有normal form Z，于是有\\(M =\_{\beta} Z =\_{\beta} N\\)，于是根据**2**有 \\(N \twoheadrightarrow\_{\beta} Z\\)，得证。

可以看出**3**是一个很有意义的推论，有助于后续性质的推导。

### Why is that hard to proof?

对下图中的a, b, c作与该定理的描述相似的解读。

![cr-abc](/assets/images/article/Church_Rosser_abc.png =600x)

* a等价于Church-Rosser定理
* 容易证明c蕴含a，但是\\(\beta\eta-reduction\\)不满足c(又叫Diamond property)
* a蕴含b，反之不然（反例见下图），于是我们无法通过证明b来证明a

![cr-ba](/assets/images/article/Church_Rosser_ba.png =300x)

定理的证明过程通过寻找一个满足如下性质的归约关系 \\(\triangleright\\) 来克服上述困难：

* \\(\triangleright\\) 满足c
* 其自反，传递闭包即为\\(\twoheadrightarrow\_{\beta\eta}\\)

假设能够找到这样的关系，那么根据其c性质推出其a性质，又在a中，其多步的闭包与beta-eta相同，便能证明beta-eta满足a性质

## Proof of the Theorem

\\(\triangleright\\) 定义如下：

1. \\(\overline{M \triangleright M}\\)
2. \\(\dfrac{P \triangleright P' \ \ N \triangleright N'}{PN \triangleright P'N'}\\)
3. \\(\dfrac{N \triangleright N'}{\lambda x.N \triangleright \lambda x.N'}\\)
4. \\(\dfrac{Q \triangleright Q' \ \ N \triangleright N'}{(\lambda x.Q)N \triangleright Q'[N'/x]}\\)
5. \\(\dfrac{P \triangleright P', where\ x \notin FV(P)}{\lambda x.Px \triangleright P'}\\)

### Lemma1

**Lemma1** :

1. 如果\\(M \rightarrow\_{\beta} M'\\) 则 \\(M \triangleright M'\\)
2. 如果\\(M \triangleright M'\\) 则 \\(M \twoheadrightarrow\_{\beta\eta} M'\\)
3. \\(\twoheadrightarrow\_{\triangleright} = \twoheadrightarrow\_{\beta\eta}\\)

**Proof** :

1和2类似，通过对前提中的关系进行归纳便容易得证，这里就不展开冗长的过程了。事实上这个新的关系又叫作**parallel one-step reduction**，它的每步归约可以比beta-eta多做一些事情，相当于把多步并作一步进行（也可以不选择并行，根据1），这么理解之后1和2的结论便是显然成立的。

至于3，根据1可得，若beta-eta多步归约可达，则parallel one-step多步归约可达，即\\(\twoheadrightarrow\_{\triangleright} \subseteq \twoheadrightarrow\_{\beta\eta}\\)；根据2，反之，即\\(\twoheadrightarrow\_{\beta\eta} \subseteq \twoheadrightarrow\_{\triangleright}\\)。

### Lemma2

至此，我们只需证明parallel one-step满足性质c。为此，我们还需要若干引理。

**Lemma2** : 若 \\(M \triangleright M' \land U \triangleright U'\\)，则 \\(M[U/y] \triangleright M'[U'/y]\\)

**Proof** : 对 \\(M \triangleright M'\\) 进行归纳，共5种情况，对于标号1, 2, 3, 5的情况，结论显然，不再赘述，针对4：

* 有\\(M = (\lambda x.Q)N \land M' = Q'[N'/x] \land Q \triangleright Q' \land N \triangleright N'\\)
* 归纳假设，有\\(Q[U/y] \triangleright Q'[U'/y] \land N[U/y] \triangleright N'[U'/y]\\)
* 根据规则4，有\\((\lambda x.Q[U/y]) N[U/y] \triangleright Q'[U'/y][N'[U'/y]/x] = Q'[N'/x][U'/y]\\) 即 \\(M[U/y] \triangleright M'[U'/y]\\)，得证

### Lemma3

引入最终形态（maximal parallel one-step reduct）M\*的概念，形式化定义如下：

1. \\(x^\* = x\\), for variable x
2. \\((PN)^\* = P^\*N^\*\\), if PN is not a \\(\beta-redex\\)
3. \\((\lambda x.N)^\* = \lambda x.N^\*\\), if \\(\lambda x.N\\) is not a \\(\eta-redex\\)
4. \\(((\lambda x.Q) N)^\* = Q^\*[N^\*/x]\\)
5. \\((\lambda x.P x)^\* = P^\*\\), if \\(x \notin FV(P)\\)

**Lemma3** : 若 \\(M \triangleright M'\\)，则 \\(M' \triangleright M^\*\\)

**Proof** : 对M的大小进行归纳，首先，按照惯例，将前提分成5种情况：

1. M = M' = x, 又 M\* = x, 成立
2. M = PN，M' = P'N', \\(P \triangleright P' \land N \triangleright N'\\). 归纳假设，得到 \\(P' \triangleright P^\* \land N' \triangleright N^\*\\)，再分为两种情况：
    1. PN不是个beta可约式，根据终极形态的定义2，\\(M' = P' N' \triangleright P^\*N^\* = M^\*\\)，得证
    2. PN beta可约，则P为一个lambda函数，设\\(P = \lambda x.Q\\)，则根据终极心态定义4 \\(M^\* = Q^\*[N^\*/x]\\)，对\\(P \triangleright P'\\)再分情况，只能是1, 3, 5：
        1. 若为1，\\(M' = PN' = Q[N'/x]\\)，由于Q为M的一部分，大小小于M，归纳假设，有\\(Q \triangleright Q \triangleright Q^\*\\)，于是根据**Lemma2**, \\(M' = Q[N'/x] \triangleright Q^\*[N^\*/x] = M^\*\\)
        2. 若为3，\\(P' = \lambda x.Q' \land Q \triangleright Q'\\)，同理，Q的大小小于M，归纳假设有\\(Q' \triangleright Q^\*\\)，于是根据归约条件4，\\(M' = (\lambda x.Q')N' \triangleright Q^\*[N^\*/x] = M^\*\\)
        3. 若为5，\\(P = \lambda x.R'x \land P' = R' \land R \triangleright R'\\) 且x不是P'的自由变量，Rx是M的子式，归纳假设，\\(Rx \triangleright R'x \triangleright (Rx)^\*\\)，根据**Lemma2**，有\\(M' = R'N' = (R'x)[N'/x] \triangleright (Rx)^\*[N^\*/x] = M^\*\\)
3. \\(M = \lambda x.N \land M' = \lambda x.N' \land N \triangleright N'\\)，分两种情况
    1. M eta不可约，则根据终极形态定义3，\\(M^\* = \lambda x.N^\*\\)，根据归约定义3，\\(M' = \lambda x.N' \triangleright \lambda x.N^\* = M^\*\\)
    2. M eta可约，则\\(M = \lambda x.Px \land N=Px \land x \notin FV(P)\\)，根据终极形态定义5，M\* = P\*, 对\\(N \triangleright N'\\)再分情况，只能是1, 2, 4：
        1. 若为1，N=N'=Px, P为M的子式，归纳假设，根据归约条件5，\\(P \triangleright P \triangleright P^\*, M' = \lambda x.Px \triangleright P^\* = M^\*\\)
        2. 若为2，\\(N' = P'x \land P \triangleright P'\\)，同理，归纳假设，根据归约条件5， \\(P' \triangleright P^\*, M' = \lambda x.P'x \triangleright P^\* = M^\*\\)
        3. 若为4，\\(P = \lambda y.Q \land N' = Q'[x/y] \land Q \triangleright Q'\\)，P为M子式，有\\(P \triangleright \lambda y.Q' \triangleright P^\*\\)，于是\\(M' = \lambda x.Q'[x/y] = \lambda y.Q' \triangleright P^\*\\)，右边最后一个等号是因为x不是Q'的自由变量
4. \\(M = (\lambda x.Q)N \land M' = Q'[N'/x] \land Q \triangleright Q' \land N \triangleright N'\\)，根据终极形态定义4，\\(M^\* = Q^\*[N^\*/x]\\)，根据**Lemma2**，得证
5. \\(M = \lambda x.Px \land M'=P' \land P \triangleright P'\\)，同上，归纳假设，\\(M' = P' \triangleright P^\* = M^\*\\)

Q.E.D

### Diamond Property

终于，可以通过Lemma3来证明parallel one-step满足c属性，i.e. Diamond Property了。

回忆下c属性的描述： 若\\(M \triangleright N \land M \triangleright P\\)，则存在Z满足 \\(N \triangleright Z \land P \triangleright Z\\)。

这里只需要使 Z = M\* ，根据**Lemma3**，结论显然。至此，结合前文的铺垫，Church-Rosser定理便得到了证明。

对于beta-reduction，只需要调整构造，将对应的规则5都删去即可。

## 叹为观止

如此神奇的证明，我虽然能理解它是有道理的，但是完全无法想象出这样奇妙的证明是怎么构造出来的，尤其是其中parallel one-step和maximal reduct的构造。
相比与糟糕的应用，糟糕的工具，糟糕的OS（尤其是IOS），糟糕的服务，糟糕的设备......数学是如此的美好~~

## References

* [Lecture Notes on the Lambda Calculus](http://www.mathstat.dal.ca/~selinger/papers/lambdanotes.pdf)
