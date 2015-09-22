---
layout: post
title: "The Hybird Monte Carlo"
description: ""
category: PRML
tags: ml physics
---
{% include JB/setup %}

## Preface

作为一种先进的采样算法，在 PRML 11.5 中有较为详细的介绍，然而我反复细读了两遍才初窥门径，于是打算将其整理成文。

## Goals of Sampling

我决定从 Metropolis 算法开始介绍 Markov Chain Monte Carlo，然后是 Gibbs 采样，最后到混合 Monte Carlo，顺便作为笔记以便日后翻阅。

不论是哪种算法，其目的都是一致的，即抽取出符合分布 \\(p(\mathbf{z})\\) 的样本，同时，我们希望样本之间是无关的，即满足 [i.i.d.](https://en.wikipedia.org/wiki/Independent_and_identically_distributed_random_variables) 条件。

采样的目的很大程度上是为了计算期望值，为了近似 \\(\mathbb{E}[f] = \int f(\mathbf{z}) p(\mathbf{z}) d\mathbf{z} \approx \frac1L \sum\limits\_{l=1} ^L f(\mathbf{z} ^{(l)})\\).

## Markov Chain Monte Carlo

Markov Chain Monte Carlo (MCMC) 的基本思想是，通过构造一个状态分布收敛于 \\(p(\mathbf{z})\\) 的 Markov chain 来进行采样，每次根据当前样本和转移函数（条件概率）抽取出下一个样本，序列中较为靠后的样本近似服从目标分布，当序列足够长时，这种采样便能获得很好的效果。

于是需要解决两个问题：

1. 如何构造这样的马尔科夫链使得它收敛到唯一的 equilibrium distribution \\(p(\mathbf{z})\\)？
2. 显然，通过 MCMC 直接获取的相邻样本间有很强的相关性，如何处理，使得样本之间近似独立？

### Markov Chains

首先假设我们选取的转移概率函数 \\(T(\mathbf{z} ^{(m)}, \mathbf{z} ^{(m+1)}) = p(\mathbf{z} ^{(m+1)} | \mathbf{z} ^{(m)})\\) 是时不变的，i.e. 只考虑 time-homogeneous Markov chain. 以便于分析与计算。

为了解决问题1，分两步走：

1.1 保证这个 MC 有唯一的 stationary distribution </br>
1.2 使得 \\(p(\mathbf{z})\\) 是其 stationary distribution, i.e. \\(p(\mathbf{z}) = \sum\limits\_{\mathbf{z'}} T(\mathbf{z'}, \mathbf{z}) p(\mathbf{z'})\\)

根据随机过程的相关理论，1.1 的一个充分条件如下：

* finite state
* irreducible, 即任意两个状态相互可达
* all states are positive recurrent

更加明确地，对于有限状态的 MC，只需满足 \\(v = min\_{x}min\_{x': p(x')>0} T(x, x')/p(x') > 0\\) 即可（相关证明见文末参考链接）。对于无限状态的 MC，收敛性质变得不容易分析，但是与有限状态类似，1.1 的性质并不难满足，后面的讨论都假设它已经成立。

对于 1.2，我们希望 T 满足下述充分不必要条件 detailed balance:

\\[
p(\mathbf{z}) T(\mathbf{z}, \mathbf{z'}) = p(\mathbf{z'}) T(\mathbf{z'}, \mathbf{z})\tag{1}\label{eq1}
\\]

直观上看，说的是任意两个状态之间的收支互补，于是分布不变。严格的证明很容易，此处略去。

至此，为了满足1，只需要找到合适的 T 满足 \\(\eqref{eq1}\\). （假设1.1容易满足）

### The Metropolis-Hastings Algorithm

首先假设 \\(p(\mathbf{z}) = \tilde{p}(\mathbf{z})/ Z\_p\\)，此处的归一化因子难以计算。我们任意取一个已知的容易抽样的条件概率函数 \\(q(\mathbf{z'} | \mathbf{z})\\)，若当前状态为 z，则以对应的条件概率抽取下一个候选状态 z'，然后以概率

\\[
A(\mathbf{z'}, \mathbf{z}) = min(1, \frac{\tilde{p}(\mathbf{z'})q(\mathbf{z} | \mathbf{z'})}{\tilde{p}(\mathbf{z})q(\mathbf{z'} | \mathbf{z})})
\\]

选择是否接受 z'. 可见对应的转移概率函数 \\(T(\mathbf{z}, \mathbf{z'}) = q(\mathbf{z'} | \mathbf{z}) A(\mathbf{z'}, \mathbf{z})\\) 带入 \\(\eqref{eq1}\\) 可得：

\\[
p(\mathbf{z})q(\mathbf{z'} | \mathbf{z}) A(\mathbf{z'}, \mathbf{z}) = min(p(\mathbf{z})q(\mathbf{z'} | \mathbf{z}), p(\mathbf{z'})q(\mathbf{z} | \mathbf{z'})) \\\\
= min(p(\mathbf{z'})q(\mathbf{z} | \mathbf{z'}), p(\mathbf{z})q(\mathbf{z'} | \mathbf{z})) \\\\
= p(\mathbf{z'})q(\mathbf{z} | \mathbf{z'}) A(\mathbf{z}, \mathbf{z'})
\\]

此处的证明在我看的 PRML 第一版中将 q 中所有对应的条件和结果给搞反了，不过不影响理解。对于 q 的选取，当状态空间连续时，通常选择高斯分布。

于是问题1得到了解决，对于问题2，一个简单的做法是在生成的样本中每隔若干选取一个，这样相邻的样本之间的相关度就大大降低了。那么应该间隔多少呢？我在这里略去具体的定量分析，事实上 PRML 对 Random walk 以及独立步长的描述也是含糊不清，但是其定性的描述是非常符合直觉的。

例如考虑 q 取高斯分布的情况，均值肯定是对应的条件值，若方差很小，则每次转移的平均步长会很小，因此相邻样本之间的关联性很大，为了获取 i.i.d. 需要的间隔就很大；反之若方差很大，转移的平均步长较大，A 取到较小值的概率增加，即采样的失败率下降。因此 q 的方差可以对采样失败率和独立步长进行 trade-off. 而后文介绍的混合蒙特卡洛则能够将这两个值同时降低到一个较为理想的值。

### Gibbs Sampling

Gibbs 采样基于的假设是条件概率容易计算且容易采样，是 Metropolis-Hastings 的一个特例，对于 n 维向量 \\(\mathbf{z}\\), 每 n 次状态转移构成一个新的样本，其中第 k 次转移只改变 \\(z\_k\\) 的值，转移概率函数为 \\(q\_k(\mathbf{z'} | \mathbf{z}) = p(z'\_k | \mathbf{z\_{/k}})\\) 即为目标分布下的条件概率。容易算得对应的采样成功率 A 为理想值1.

在理想的状况下，若 \\(\mathbf{z}\\) 的各个分量相互独立，则每次转移便能够看成是从联合分布中随机抽取一个维度，每 k 次转移完整地从联合分布中抽取一个样本，于是满足 i.i.d. 性质。不然的话，相邻样本间存在相关性，需要舍弃一些中间样本。

## Hybird Monte Carlo

根据 [Maxwell–Boltzmann](https://en.wikipedia.org/wiki/Maxwell–Boltzmann_distribution) 分布，如果我们将 \\(\mathbf{z}\\) 类比为分子的空间位置，若平衡后分子的位置分布服从 \\(p(\mathbf{z})\\)，则对应的空间势能函数 \\(E(\mathbf{z})\\) 满足 \\(p(\mathbf{z}) = \frac{1}{Z\_p} exp(-E(\mathbf{z}))\\), 此处忽略了系数 kT.

若引入分子的动量 \\(\mathbf{r}\\)，则总能量为势能+动能，即 \\(H(\mathbf{z}, \mathbf{r}) = E(\mathbf{z}) + K(\mathbf{r})\\), 其中 \\(K(\mathbf{r}) = \frac12 \sum\limits\_{i} r\_i ^2\\). 则平衡后分子的分布满足

\\[
p(\mathbf{z}, \mathbf{r}) = \frac{1}{Z\_H} exp(-H(\mathbf{z}, \mathbf{r})) \tag{2}\label{eq2}
\\]

若我们将分子的运动看作是随机变量 \\((\mathbf{z}, \mathbf{r})\\) 上的一个 MC，只不过此处我们只在经典力学范围内进行演绎，因此状态转移函数是确定的。类比于 Maxwell-Boltzmann 分布，可以知道这个 MC 收敛于 \\(\eqref{eq2}\\).

于是我们可以在上述 Markov Chain 上对扩充后的状态空间 \\((\mathbf{z}, \mathbf{r})\\) 进行采样，随后再将不需要的动量舍去，便能够得到服从 \\(p(\mathbf{z})\\) 的样本。之所以要引入多余的变量 \\(\mathbf{r}\\)，是为了求解动力学方程，从而得到一个确定的转移函数。

此处我的描述与 PRML 中略有出入，原因是我认为第一版中 P550 中对 \\(\eqref{eq2}\\) 在转移下 invariant 的论述并不正确，anyway，我相信这个结论是对的，而且我上面的论述更让自己信服。

事实上，如果我们能够通过动力学方程准确地计算出分子的轨迹和动量变化（或者是转移方程 T），回到最初提出的两个要求：

1. 对于要求1，根据上述分析，1.2在 T 下确实得到满足
2. 只需要每隔足够的时间进行一次采样就能保证独立性

由于收敛条件1.2已然满足，我们不需要引入额外的 A，即采样的成功率是 100%. 我们只需要沿着时间轴，每隔一段时间根据转移方程和当前状态确定地计算出下一个样本状态即可。然而在实现的时候存在如下问题：

1. 为了计算 T，我们需要进行数值积分，因而引入误差，从而导致1.2不再成立
2. 即便是没有误差，由于能量守恒，和特定的起始状态，抽样并不能遍历整个状态空间，换句话说1.1并不成立

对于1.1，我们可以在某些采样的时候对引入的额外变量 \\(\mathbf{r}\\) 进行 Gibbs 采样来强制进行偏移，由于我们只关心采样后得到的 \\(\mathbf{z}\\)，这样的做法在条件概率可采样的情况下是可行的，并且不会降低其采样成功率。虽然这个做法还是存在一定的问题，但是更加细致的分析我本人并不关心。

于是剩下的就只是误差问题，后面我们将看到即便存在误差，1.2依然可以满足。

### Dynamical Systems

首先我们试图计算 T，建立动力学方程。首先，动量正比于速度，略去质量这个常数后有

\\[
\frac{d z\_i}{d t} = r\_i = \frac{\partial H}{\partial r\_i} \tag{3}\label{eq3}
\\]

又动量变化量正比于外力（可以看作粒子处于势能为 \\(E(\mathbf{z})\\)）的力场，于是略去常数后有

\\[
\frac{d r\_i}{d t} = - \frac{\partial E(\mathbf{z})}{\partial z\_i} = - \frac{\partial H}{\partial z\_i}\tag{4}\label{eq4}
\\]

我们假设 \\(E(\mathbf{z})\\) 对应于目标分布，是已知的，且其值以及各个 \\(\frac{\partial E(\mathbf{z})}{\partial z\_i}\\) 均容易计算，则我们可以通过如下的 leapfrog 公式近似得到 T:

\\[
\hat{r}\_i(t + \epsilon/2) = \hat{r}\_i(t) - \frac{\epsilon}{2} \frac{\partial E}{\partial z\_i}(\hat{\mathbf{z}}(t)) \\\\
\hat{z\_i}(t + \epsilon) = \hat{z\_i}(t) + \epsilon \hat{r}\_i(t + \epsilon/2) \\\\
\hat{r}\_i(t + \epsilon) = \hat{r}\_i(t + \epsilon/2) - \frac{\epsilon}{2} \frac{\partial E}{\partial z\_i}(\hat{\mathbf{z}}(t + \epsilon))
\\]

其原理很简单，考虑泰勒展开即可，之所以要将更新穿插进行，一方面是为了精确，更重要的是因为这样得到的 \\(\hat{T}\\) 是可逆的，即正向更新 \\(\epsilon\\) 后紧接着反向更新步长 \\(-\epsilon\\) 可以回到原状态。这使得在不能精确还原 T 的情况下通过巧妙的调整依然可以保证收敛性质1.2。可以看出，我们不单可以顺着时间轴进行采样，逆向回溯也是可行的。

### The Algorithm

所谓的“巧妙的调整”指的是，每次采样时（假设当前状态为 \\(\mathfrak{R}\\)），抛硬币决定是正向以 \\(\epsilon\\) 或者反向以 \\(-\epsilon\\) 为步长迭代 L 次 leapfrog 得到候选状态 \\(\mathfrak{R}'\\)，同时类似 Metropolis-Hastings 算法，以概率 \\(min(1, exp(-H(\mathfrak{R'}) + H(\mathfrak{R})))\\) 接受该候选状态。

下面通过证明这样修改后的 T 满足 \\(\eqref{eq1}\\) 从而说明收敛性质1.2得到满足。

首先，由于状态空间连续，对应版本的 detailed balance 需要考察状态空间中的两块可以相互转化的小区域（区域内的 H 值视为常数），容易知道在 leapfrog 操作下前后对应的状态空间区域的体积不变（每一步更新只在一个维度上平移一个常量，更严格的论述参见书本 p553），令这个不变的体积为 \\(\delta V\\)，依据上面描述的 T，有：

\\[
p(\mathfrak{R}) T(\mathfrak{R}, \mathfrak{R'}) = \frac{1}{Z\_H}exp(-H(\mathfrak{R})) \delta V \frac12 min{1, exp(-H(\mathfrak{R'}) + H(\mathfrak{R})))} \\\\
= \frac{1}{Z\_H}exp(-H(\mathfrak{R'})) \delta V \frac12 min{1, exp(-H(\mathfrak{R}) + H(\mathfrak{R'})))} \\\\
= p(\mathfrak{R'}) T(\mathfrak{R'}, \mathfrak{R})
\\]

其中系数0.5源自抛硬币的概率，第二个等号的成立只需要对 \\(H(\mathfrak{R}), H(\mathfrak{R'})\\) 的相对大小分类讨论即能得出。注意：第一版中将 min 函数内部的正负号均搞反了，容易造成误导。

至此，可以看出这个算法在理论上与 MCMC 一样是可行的，那么它的优越性其实在于，在 L 够大的情况下，状态得到充分的偏移，样本间的独立性容易满足，而且此时，由于 leapfrog 的近似，状态转移近似依照 T 进行，因而能量近似守恒，即采样成功率很高。粗略的定量分析可以参照书本 p553-554.

## References

* [Markov chain](https://en.wikipedia.org/wiki/Markov_chain)
* [Markov chain Monte Carlo](https://en.wikipedia.org/wiki/Markov_chain_Monte_Carlo)
* [Christopher M. Bishop | PRML](http://research.microsoft.com/en-us/um/people/cmbishop/prml/)
* [Probabilistic Inference Using Markov Chain Monte Carlo Methods](http://www.cs.toronto.edu/pub/radford/review.pdf)
