---
layout: post
title: "Coprime probabilities"
description: ""
category: fun
tags: math
---
{% include JB/setup %}

## A Conclusion

听说了一个有趣的结论：两个随机的正整数互质的概率为 \\(\frac{6}{\pi ^2}\\)，对它的推导过程感到好奇，于是通过wikipedia学习了一些数学知识...

## Basic Analysis

何为“两个随机正整数”？正整数集合的度是无穷大，所以要使得所有整数对出现的概率相同是无法达到的。

问题需要如此描述：我们用 \\(Z\_2(t)\\) 表示互质整数对的个数，其中每个整数对中的两个整数都不大于t，于是所要求的概率即为 \\(limit\_{t \to \infty} \frac{Z\_2(t)}{t ^2} \\)。

我们忽略这个定义，直接考虑无穷的情形，两个整数互质，说明对任意的质数p，它们不能同时被p整除；一个随机正整数被p整除的概率为\\(1/p\\)，于是它们不同时被p整除的概率为\\(1-1/p ^2\\)，对于不同的质数p，相互独立；于是所求即为：

\\[
\prod\limits\_{prime\ p} (1-1/p ^2)\tag{1}\label{eq1}
\\].

更加严密地，我们有 \\(t ^k = \sum\limits\_{d | t} Z\_k(t/d)\\)，等式左边为k元正整数向量的个数（所有成员不大于t），右边为所有k个正整数最大公约数为d时的个数（gcd为d时，若将所有整数除以d，得到的向量正是\\(Z\_k(t/d)中的一员，即每个数不大于t/d，且gcd为1。这是一个同构关系\\)）。

对上式进行 Möbius 反演变换，得到 \\(Z\_k(t) = \sum\limits\_{d | t} \mu(d)(t/d) ^k\\)，于是\\(\frac{Z\_k(t)}{t ^k} = \sum\limits\_{d | t} \frac{\mu(d)}{d ^k}\\)，于是当 \\(t \to \infty\\) 时，所求为：

\\[
\sum\limits\_{d = 1} ^{\infty} \frac{\mu(d)}{d ^k} = \frac{1}{\zeta(k)}\tag{2}\label{eq2}
\\]

zeta函数的定义以及该等式的证明见下文。

## Riemann Zeta Function

黎曼Zeta函数是一个知名函数，在数论，物理等多个领域有广泛的应用。
定义如下 \\(\zeta(s) = \sum\limits\_{n=1} ^{\infty} \frac{1}{n ^s}\\)，接下来我们证明：

\\[
\zeta(s) = \prod\limits\_{prime\ p} \frac{1}{1-p ^{-s}}\tag{3}\label{eq3}
\\]

从而可以推出，`随机k个正整数的gcd为1的概率为` \\(1/\zeta(k)\\).（通过类似于\\(\eqref{eq1}\\)的分析过程）

该结论称为 "Euler product formula for the Riemann zeta function". 事实它对复数域上的s，在满足s的实部大于1的时候均成立，我在这不求甚解，只关心s为整数的情况。先来看下欧拉给出的符合直觉的证明，该证明只用到了初等数学的知识，非常的直接。

\\[
\zeta(s) = 1 + 1/2 ^s + 1/3 ^s + 1/4 ^s \cdots \\\\
\zeta(s)/2 ^s = 1/2 ^s + 1/4 ^s + 1/6 ^s + 1/8 ^s \cdots \\\\
(1-1/2 ^s)\zeta(s) = 1 + 1/3 ^s + 1/5 ^s + 1/7 ^s \cdots \\\\
(1-1/2 ^s)/3 ^s \zeta(s) = 1/3 ^s + 1/9 ^s + 1/15 ^s \cdots \\\\
(1-1/2 ^s)(1-1/3 ^s) \zeta(s) = 1 + 1/5 ^s + 1/7 ^s + 1/11 ^s \cdots \\\\
\vdots \\\\
\prod\limits\_{prime\ p} (1-p ^s) \zeta(s) = 1
\\]

## Dirichlet Series

狄力克雷级数与黎曼Zeta函数有密切的联系，我们可以通过它的相关理论证明一些重要的结论。
其定义如下：

\\[
\mathfrak{D}^{A}\_w(s) = \sum\limits\_{a \in A} \frac{1}{w(a) ^s} = \sum\limits\_{n=1} ^{\infty} \frac{a\_n}{n ^s}.
\\]

其中A为一个集合，w为一个\\(A \to \mathbb{N}\\)的函数，它满足如下的运算规则：

\\[
A \cap B = \varnothing \rightarrow \\\\
\mathfrak{D}^{A \uplus B}\_w(s) = \mathfrak{D}^{A}\_w(s) + \mathfrak{D}^{B}\_w(s) \\\\
\forall (a, b) \in A \times B, w(a,b) = u(a)v(b) \rightarrow \\\\
\mathfrak{D}^{A \times B}\_w(s) = \mathfrak{D}^{A}\_u(s) \cdot \mathfrak{D}^{B}\_v(s)
\\]

这两个运算规则也很符合直觉，类似多项式展开... 利用这两个定理， "Euler product formula for the Riemann zeta function" 可以这样证明：

\\[
\zeta(s) = \mathfrak{D}^{\mathbb{N}}\_{\mathrm{id}}(s) = \prod\limits\_{prime\ p}
\mathfrak{D}^{\\{p ^n : n \in \mathbb{N}\\}}\_{\mathrm{id}}(s) = \prod\_{prime\ p} \sum\_{n \in \mathbb{N}} \mathfrak{D}^{\\{p ^n\\}}\_{\mathrm{id}}(s) \\\\
= \prod\limits\_{prime\ p} \sum\limits\_{n \in \mathbb{N}} \frac{1}{(p ^n) ^s}
= \prod\limits\_{prime\ p} \sum\limits\_{n \in \mathbb{N}} \left(\frac{1}{p ^s}\right) ^n
= \prod\_{prime\ p} \frac{1}{1-p ^{-s}}
\\]

就是说将所有的正整进行质因数分解，于是得到正整数到一个质因数指数向量的一一映射，正整数集合便可以表示成无穷个质数幂次集合的笛卡尔积...

### Dirichlet Convolution

我们可以通过狄力克雷卷积证明结论\\(\eqref{eq2}\\)。

可以用另一种方式表示狄力克雷级数：\\(DG(f, s) = \sum\limits\_{n=1}^{\infty} \frac{f(n)}{n ^s}\\).
定义卷积如下 \\((f \* g)(n) = \sum\limits\_{d|n}f(d)g(n/d)\\)，可以得到卷积公式如下：

\\[
DG(f, s) \cdot DG(g, s) = DG(f \* g, s)\tag{4}
\\]

将定义直接带入，展开，右边的每一项在左边出现且仅出现一次。
根据这条定理我们有：

\\[
\zeta(s) \cdot \sum\limits\_{n=1}^{\infty}\frac{\mu(n)}{n ^s} =
DG(1, s) \cdot DG(\mu, s) = DG(1 \* \mu, s) =
\sum\limits\_{n=1}^{\infty}\frac{\sum\limits\_{d|n}\mu(d)}{n ^s} = 1
\\]

注意到上式右边的通项分子满足：

\\[
\sum\limits\_{d|n}\mu(d) =
 \begin{cases}
    1 &\mbox{n = 1} \\\\
    0 &\mbox{n > 1}
\end{cases}
\\]

## Basel Problem

事实上要求原问题的解，根据公式\\(\eqref{eq3}\\)以及其推论，我们只需要计算\\(\zeta(2)\\)即可，之所以用Möbius反演绕了一圈，其实只是为了将几个著名的结论串在一起，以揭示其内在联系。最终我们还是无法避免地需要求这个级数和。

### Euler's Approach

这个问题最早由欧拉解决，考虑sin(x)的泰勒展开，得到：

\\[
\frac{sin(x)}{x} = 1 - x ^2/3! + x ^4/5! - x ^6/7! + \cdots \tag{5}\label{eq5}
\\]

又，根据 "Weierstrass factorization theorem", 有：

\\[
\frac{sin(x)}{x} = (1-\frac{x}{\pi})(1+\frac{x}{\pi})(1-\frac{x}{2\pi})(1+\frac{x}{2\pi})(1-\frac{x}{3\pi})(1+\frac{x}{3\pi})\cdots \\\\
= (1-\frac{x ^2}{\pi ^2})(1-\frac{x ^2}{4\pi ^2})(1-\frac{x ^2}{9\pi ^2})\cdots \tag{6}\label{eq6}
\\]

其实就是因式分解，只不过是在复数域上进行。比较 \\(\eqref{eq5}, \eqref{eq6}\\) 中的二次项系数，容易得出：\\(\zeta(2) = \sum\limits\_{n=1}^{\infty} 1/n ^2 = \pi ^2/6\\)

### Other Approaches

wikipedia还给出了三种解法，分别是：

* 利用zeta函数和 [Bernoulli number](https://en.wikipedia.org/wiki/Bernoulli_number) 的关系公式 \\(\zeta(2n) = \frac{(2\pi)^{2n}(-1)^{n+1} B\_{2n}}{2\cdot(2n)!}\\)
* 通过对 \\(f(x) = 2 \sum\limits\_{n=1}^{\infty}\frac{(-1)^{n+1}}{n} sin(nx)\\) 进行傅里叶变换，然后通过 [Parseval's identity](https://en.wikipedia.org/wiki/Parseval's_identity)（如果没记错的话也叫能量公式）求值
* 通过不等式夹逼

具体的解法见参考链接。

## PS

一个简单的数学问题可以将诸多著名的结论联系起来，贯穿了数论，概率论，数学分析，复变等多个分支；而wikipedia的内容组织形式以及其足够的专业度让我可以完全在站内找到我所需要的答案。

## References

* [Möbius inversion formula](https://en.wikipedia.org/wiki/Möbius_inversion_formula)
* [Proof of the Euler product formula for the Riemann zeta function](https://en.wikipedia.org/wiki/Proof_of_the_Euler_product_formula_for_the_Riemann_zeta_function)
* [Dirichlet series](https://en.wikipedia.org/wiki/Dirichlet_series)
* [Dirichlet convolution](https://en.wikipedia.org/wiki/Dirichlet_convolution)
* [Basel problem](https://en.wikipedia.org/wiki/Basel_problem)
* [Bernoulli number](https://en.wikipedia.org/wiki/Bernoulli_number)
* [Parseval's identity](https://en.wikipedia.org/wiki/Parseval's_identity)
* [Weierstrass factorization theorem](https://en.wikipedia.org/wiki/Weierstrass_factorization_theorem)
* [Coprime integers](https://en.wikipedia.org/wiki/Coprime_integers)
