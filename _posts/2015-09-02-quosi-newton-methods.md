---
layout: post
title: "Quosi Newton Methods"
description: ""
category: notes
tags: ml math
---
{% include JB/setup %}

## Preface

最近在以蜗牛般的速度啃 PRML。第五章提到了拟牛顿法，这玩意我之前大致意会过，并作了一些笔记，然而我完全无法回忆起来，于是翻出之前的笔记重新意会了一遍，顺便更正了之前一些不太正确的理解，总结整理成下文。

## Newton's Method

考虑求自变量 X 为 N 维向量的函数 \\(f(X)\\) 的极值点问题。我们知道高中数学中的牛顿法可以用于求解函数0点的：\\(X\_{k+1} = X\_n - [J\_f(X\_k)] ^{-1}f(X\_k)\\). 那么可导函数的极值问题其实就是求其导函数的0点问题，同样可以用牛顿法求解。

以同样的迭代方式逼近，设 \\(X\_k\\) 为当前对极值点的估计，考虑 f 在其附近的二阶 Taylor 展开：

\\[
f(X) \approx f(X\_k) + \nabla f(X\_k) \cdot (X - X\_k) + 0.5 \cdot (X - X\_k) ^T \cdot \nabla ^2 f(X\_k) \cdot (X - X\_k)\tag{1}\label{eq1}
\\].

引入如下的简化标记（梯度向量，Hessian 矩阵）：

\\[
\nabla f = g =
\begin{pmatrix}
\frac{\partial f}{\partial x\_1} \\\\
\frac{\partial f}{\partial x\_2} \\\\
\vdots \\\\
\frac{\partial f}{\partial x\_N} \\\\
\end{pmatrix} \\\\
\\]

\\[
\nabla ^2 f = H =
\begin{pmatrix}
\frac{\partial ^2 f}{\partial x\_1 ^2} & \frac{\partial ^2 f}{\partial x\_1\partial x\_2} & \cdots & \frac{\partial ^2 f}{\partial x\_1\partial x\_N}\\\\
\frac{\partial ^2 f}{\partial x\_2\partial x\_1} & \frac{\partial ^2 f}{\partial x\_2 ^2} & \cdots & \frac{\partial ^2 f}{\partial x\_2\partial x\_N}\\\\
\vdots & \vdots & \ddots & \vdots\\\\
\frac{\partial ^2 f}{\partial x\_N\partial x\_1} & \frac{\partial ^2 f}{\partial x\_N\partial x\_2} & \cdots & \frac{\partial ^2 f}{\partial x\_N ^2}\\\\
\end{pmatrix}
\\]

\\(\eqref{eq1}\\) 的约等号两边分别对 X 求梯度，得到 \\(\nabla f(X) = g\_k + H\_k \cdot (X - X\_k)\\), 我们希望它的值为0，解出对应的 X，作为极值点的下一个估计 \\(X\_{k+1} = X\_k - H\_k ^{-1} \cdot g\_k\\).

### Wolfe Conditions

在拟牛顿法中，实际的更新并不是严格按照上边的等式进行。为了保证每一步迭代之后，估计点更加逼近极值点（此处以极小值为例），我们采取一种 line search 的方法：\\(X\_{k+1} = X\_k - \lambda H\_k ^{-1} \cdot g\_k\\)，不改变其更新的方向，但是调整更新步长。这里的参数 α 需要满足所谓的 Wolfe 条件：

1. \\(f(\mathbf{X}\_k+\lambda\mathbf{p}\_k)\leq f(\mathbf{X}\_k)+c\_1\lambda\mathbf{p}\_k ^{\mathrm T}\nabla f(\mathbf{X}\_k)\\)
2. \\(\mathbf{p}\_k ^{\mathrm T}\nabla f(\mathbf{X}\_k+\lambda\mathbf{p}\_k) \geq c\_2\mathbf{p}\_k ^{\mathrm T}\nabla f(\mathbf{X}\_k)\\)

其中 \\(\mathbf{p}\_k = - H\_k ^{-1} \cdot g\_k\\) 称作牛顿方向，\\(0 < c1 < c2 < 1\\), 简单用自然语言解释下上面两个条件：

1. 迭代之后的函数值确实减小了（此处考虑极小值问题，所以牛顿方向需要满足 \\(p\_k ^T g\_k < 0\\)），且至少以线性速率递减，c1 通常取一个很小的数，如 0.0001
2. 每次迭代之后，梯度以近似指数的速率缩小（考虑到两边均小于0），因而能向0趋近，c2 为衰减速率，因而取一个近似1的较大值即可，如 0.9

这样的性质固然很好，但是如何寻找满足如此复杂条件的步长呢？似乎并没有什么高效的办法。所以实际应用中，这个问题往往被近似为 \\(argmin\_{\lambda} f(X\_k + \lambda \mathbf{p}\_k)\\)，这将容易数值求解。

此外 Wolfe 条件被证明能够保留 Hessian 矩阵的估计值（将在后文出现）的正定性。

### Secant Equation & Quosi-Newton Condition

考虑梯度函数在 \\(X\_k\\) 处的一阶泰勒展开，有 \\(\nabla f(X\_k+\Delta X) \approx \nabla f(X\_k)+H(X\_k) \Delta X\\)，这被称作 Secant 等式，对应与牛顿法类似的 [Secant Method](https://en.wikipedia.org/wiki/Secant_method). 当步长足够小时，上式的直接推论： \\(g\_{k+1} - g\_k = H\_{k+1} \cdot (X\_{k+1} - X\_k)\\)， 这被称为拟牛顿条件（Quosi-Newton condition）后面的拟牛顿法将利用这个等式来迭代地计算 H，从而降低复杂度。

## Broyden–Fletcher–Goldfarb–Shanno algorithm

首先总结下牛顿法的求解思路：

1. 给定初值 \\(X\_0\\) 和精度阈值e，k=0
2. 计算 \\(g\_k, H\_k\\)
3. 若 \\(||g\_k|| < e\\) 停止，否则计算牛顿方向 \\(\mathbf{p}\_k = - H\_k ^{-1} \cdot g\_k\\)
4. 利用牛顿方向计算最优步长因子，\\(argmin\_{\lambda} f(X\_k + \lambda \mathbf{p}\_k)\\)
5. k++, goto step 2

牛顿法的问题就是第二步的数值计算十分低效，PRML 的第五章花了不少篇幅讲解了在神经网络这样特殊的场景下如何利用 back propagation 高效的计算 Jacobian 和 Hessian 矩阵。

一般场景下的做法是通过 Secant 等式来近似地迭代更新 Hessian 矩阵（或者其逆矩阵），于是步骤2的计算代价被大大降低，这样的方法称为 Quosi-Newton Method.

由于篇幅的原因（其实是我懒得抄数学公式），我直接跳过比较古老的 [DFP 算法](https://en.wikipedia.org/wiki/Davidon–Fletcher–Powell_formula)，直接介绍如今比较流行的 BFGS 和 L-BFGS.

引入如下记号：

1. \\(s\_k = X\_{k+1} - X\_k\\)
2. \\(y\_k = g\_{k+1} - g\_k\\)
3. \\(B\_k \approx H\_k\\)

假设每次迭代更新时，H 的增量满足如下形式 \\(\Delta B\_k = \alpha uu ^T + \beta vv ^T\\). 至于为何假设为这样的形式，我估计是出于以下考虑：

* 如果高阶导数均连续，则 H 矩阵为对称矩阵，参见 [Clairaut's theorem](https://en.wikipedia.org/wiki/Symmetry_of_second_derivatives#Clairaut.27s_theorem)
* 保留正定性
* 碰巧有满足拟牛顿条件的特殊解： \\(\Delta B\_k = \frac{y\_k y\_k ^T}{y\_k ^T s\_k} - \frac{B\_k s\_k s\_k ^T B\_k}{s\_k ^T B\_k s\_k}\\)

但是计算 H 的目标事实上是为了计算牛顿方向，这需要涉及到矩阵求逆运算，幸运的是，上面的迭代公式可以通过 [Woodbury formula](https://en.wikipedia.org/wiki/Woodbury\_matrix\_identity) 的特殊形式 [Sherman–Morrison formula](https://en.wikipedia.org/wiki/Sherman–Morrison\_formula) 巧妙地转化为其逆矩阵的迭代公式：

\\[B\_{k+1} ^{-1} = \left (I-\frac { s\_k y\_k ^T} {y\_k ^T s\_k} \right ) B\_{k} ^{-1} \left (I-\frac { y\_k s\_k ^T} {y\_k ^T s\_k} \right )+\frac {s\_k s\_k ^T} {y\_k ^T \, s\_k} \\\\
= B\_k ^{-1} + \frac{(\mathbf{s}\_k ^{\mathrm{T}}\mathbf{y}\_k+\mathbf{y}\_k ^{\mathrm{T}} B\_k ^{-1} \mathbf{y}\_k)(\mathbf{s}\_k \mathbf{s}\_k ^{\mathrm{T}})}{(\mathbf{s}\_k ^{\mathrm{T}} \mathbf{y}\_k) ^2} - \frac{B\_k ^{-1} \mathbf{y}\_k \mathbf{s}\_k ^{\mathrm{T}} + \mathbf{s}\_k \mathbf{y}\_k ^{\mathrm{T}}B\_k ^{-1}}{\mathbf{s}\_k ^{\mathrm{T}} \mathbf{y}\_k}
\\]

这样的计算是非常高效的，并且没有需要存储的中间结果矩阵。

将上述牛顿法算法中的第2-3步中计算牛顿方向的方式换成 \\(\mathbf{p}\_k = - B\_{k} ^{-1} \cdot g\_k\\), 同时加入对 B 的迭代，即得到完整的 BFGS 算法。注意，此处的梯度依然是通过普通方法计算（解析解或者数值解）。

### L-BFGS

考虑到当自变量的维度 N 过大时，存储 \\(B\_k ^{-1}\\) 需要过多的存储资源，于是便有了 L-BFGS 这样的改版算法，在该算法中，并不存储完整的 Hessian 矩阵的逆矩阵的近似值，而是通过存储 2m 个 N 维向量（最近m 个 s 和 y）来近似还原它。如果令：

1. \\(\rho\_k = \frac{1}{y\_k ^Ts\_k}\\)
2. \\(V\_k = I - \rho\_ky\_ks\_k ^T\\)
3. \\(D\_k = B\_k ^{-1}\\)

反复利用 BFGS 的递推公式可以得到：

\\[
D\_{k+1} = (V\_k ^TV\_{k-1} ^T \cdots V\_{k-m+1} ^T)D\_{k-m+1}(V\_{k-m+1} \cdots V\_{k-1}V\_k) \\\\
    + (V\_k ^TV\_{k-1} ^T \cdots V\_{k-m+2} ^T)(\rho\_{k-m+1}s\_{k-m+1}s\_{k-m+1} ^T)(V\_{k-m+2} \cdots V\_{k-1}V\_k) \\\\
    + (V\_k ^TV\_{k-1} ^T \cdots V\_{k-m+3} ^T)(\rho\_{k-m+2}s\_{k-m+2}s\_{k-m+2} ^T)(V\_{k-m+3} \cdots V\_{k-1}V\_k) \\\\
    + ... \\\\
    + (V\_k ^TV\_{k-1} ^T)(\rho\_{k-2}s\_{k-2}s\_{k-2} ^T)(V\_{k-1}V\_k) \\\\
    + V\_k ^T(\rho\_{k-1}s\_{k-1}s\_{k-1} ^T)V\_k \\\\
    + \rho\_ks\_ks\_k ^T
\\]

于是只需要对 \\(D\_{k-m+1}\\) 作出估计即可近似地计算出牛顿方向，通常取 \\(D\_{k-m+1} = \frac{s\_k ^T y\_k}{y\_k ^T y\_k} I\\).

## References

* [Quasi-Newton method](https://en.wikipedia.org/wiki/Quasi-Newton_method)
* [Broyden–Fletcher–Goldfarb–Shanno algorithm](https://en.wikipedia.org/wiki/Broyden–Fletcher–Goldfarb–Shanno_algorithm)
