---
layout: post
title: "SVD++ Implementation in GraphX"
description: ""
category: notes
tags: scala spark ml
---
{% include JB/setup %}

## Clarification

写完之后我突然发现这个标题看上去貌似有“以下实现是由本人完成的”这样的误导，所以特此澄清，下文出现的代码统统摘自
 [apache/spark](https://github.com/apache/spark.git).

## SVD++ Intro

首先简单介绍 SVD++ 算法在协同过滤中的应用及其数学直觉。

### SVD in CF

考虑 CF 中最为常见的用户给电影评分的场景，我们需要一个数学模型来模拟用户给电影打分的场景，i.e. 对评分进行预测。

一个 Naive 的方案可以是将评分矩阵看作是两个矩阵的乘积：

\\[
U = \begin{bmatrix}
u\_{11} & \cdots & u\_{1k} \\\\
\vdots & \ddots & \vdots \\\\
u\_{m1} & \cdots & u\_{mk}
\end{bmatrix}
\begin{bmatrix}
i\_{11} & \cdots & i\_{1n} \\\\
\vdots & \ddots & \vdots \\\\
i\_{k1} & \cdots & i\_{kn}
\end{bmatrix}
\\].

其中的 \\(u\_{xy}\\) 可以看作是 user x 对电影的隐藏特质 y 的热衷程度，而 \\(i\_{yz}\\) 可以看作是特质 y 在电影 z 中的体现程度。那么上述模型的评分预测公式为：

\\[
\hat{r}\_{ui} = q\_i ^T p\_u
\\]

q 和 p 分别对应了电影和用户在各个隐藏特质上的特征向量。

以上的模型中，用户和电影都体现得无差别，例如某些用户非常挑剔，总是给予很低的评分；或是某部电影拍得奇烂，恶评如潮。为了模拟以上的情况，需要引入 baseline predictor.

\\[
\hat{r}\_{ui} = \mu + b\_i + b\_u + q\_i ^T p\_u
\\]

其中 μ 为所有评分基准，\\(b\_i\\) 为电影 i 的评分均值相对 μ 的偏移，\\(b\_u\\) 类似。注意，这些均为参数，需要通过训练得到具体数值，不过可以用相应的均值作为初始化时的估计。

### SVD++

某个用户对某个电影进行了评分，那么说明他看过这部电影，那么这样的行为事实上蕴含了一定的信息，因此我们可以这样来理解问题：评分的行为从侧面反映了用户的喜好，可以将这样的反映通过隐式参数的形式体现在模型中，从而得到一个更为精细的模型，便是 SVD++.

\\[
\hat{r}\_{ui} = \mu + b\_i + b\_u + (p\_u + \frac{1}{\sqrt{|N(u)|}}\sum\_{j\in N(u)} y\_j ) ^T q\_i \tag{1}\label{eq1}
\\]

其中 N(u) 为该用户所评价过的所有电影的集合，\\(y\_j\\) 为隐藏的“评价了电影 j”反映出的个人喜好偏置。收缩因子取集合大小的根号是一个经验公式，并没有理论依据。

事实上隐式返回的形式可以是多样的，例如可以考虑一个用户的相邻用户对其产生的影响，这在Koren 的原始论文中也有提及，他甚至在最后提到了一个整合了两者的模型。

但是有些方式在实际应用中存在问题，比如我们反过来考虑用户的评价行为对电影特征的影响就不合适，这是因为实际应用中用户数量往往是远大于电影数量的，这么做会引入过多的隐式参数，导致模型在训练的时候难以收敛。

我们暂且只关注上面公式对应的隐式模型，因为后文关心的 GraphX 中的实现如此。

### Training

有了上述的模型，我们的训练目标非常明确，即最小化 RMSE:

\\[
min\_{q\_\*,x\_\*,y\_\*,b\_\*,} \sum\limits\_{(u, i) \in \mathfrak{K}} (r\_{ui}-\hat{r}\_{ui}) ^2 + \lambda\_6(b\_u ^2 + b\_i ^2) + \lambda\_7(||q\_i|| ^2 + ||p\_u|| ^2 + ||y\_j|| ^2)
\\]

后两项为正规化因子，为了避免过拟合，之所以选这么诡异的下标，是为了跟 GraphX 中的实现对应，事实上该实现是参照了原论文中的命名，只可惜搞乱了希腊字母 lambda 和 gamma，Whatever...

带入 \\(\eqref{eq1}\\) 后求偏导，容易得到如下的学习公式：

\\[
e\_{ui} \overset{def}{=} r\_{ui} - \hat{r}\_{ui} \\\\
b\_u \gets b\_u + \gamma\_1 \cdot (e\_{ui} - \lambda\_6 \cdot b\_u) \\\\
b\_i \gets b\_i + \gamma\_1 \cdot (e\_{ui} - \lambda\_6 \cdot b\_i) \\\\
q\_i \gets q\_i + \gamma\_2 \cdot (e\_{ui} \cdot (p\_u + |N(u)| ^{-\frac{1}{2}} \sum\_{j \in N(u)} y\_j) - \lambda\_7 \cdot q\_i) \\\\
p\_u \gets p\_u + \gamma\_2 \cdot (e\_{ui} \cdot q\_i - \lambda\_7 \cdot p\_u) \\\\
\forall j \in N(u): y\_j \gets y\_j + \gamma\_2 \cdot (e\_{ui} \cdot |N(u)| ^{-\frac{1}{2}} \cdot q\_i - \lambda\_7 \cdot y\_j)
\\]

此处选取了两种学习速率。

## Implementation in GraphX

GraphX 是 Apache Spark 中的图计算框架，SVD++ 算法以一种图的形式在其中得到了实现。基本思路：将用户和电影看作两种节点，打分看作是连接对应节点的边，从而得到一个二分图。更具体的有：

* 用户节点 u 具有四元组属性 \\((p\_u, p\_u + |N(u)| ^{-\frac{1}{2}} \cdot \sum\limits\_{j \in N(u)} y\_j, b\_u, |N(u)| ^{-\frac{1}{2}})\\)
* 电影（姑且这么叫）节点 i 具有四元组属性 \\((q\_i, y\_i, b\_i, \*)\\)
* 边节点具有属性 \\(r\_{ui}\\)，边的源节点为 u，目标节点为 i

其实了解了上述设定之后源码便容易理解了，下面具体展开一下。

### Overview

首先看下入口函数的类型：

{% highlight scala %}
def run(edges: RDD[Edge[Double]], conf: Conf)
    : (Graph[(Array[Double], Array[Double], Double, Double), Double], Double)
{% endhighlight %}

* 函数参数为一个包含了所有的评分的 RDD，需要转化成 Edge 的数据结构，可以简单理解为三元组 (u, i, rate).
* 函数的返回值为一个二元组，第1元为训练之后得到的图，图中的各个节点包括了训练之后得到的各个参数
  * 向量以数组的形式存储
* 第二元为所有评分的均值

### Initialization

首先计算 baseline predictor 的初始值（各种均值），以及随机初始化各个个性向量。

{% highlight scala linenos %}
// Generate default vertex attribute
def defaultF(rank: Int): (Array[Double], Array[Double], Double, Double) = {
    // TODO: use a fixed random seed
    val v1 = Array.fill(rank)(Random.nextDouble())
    val v2 = Array.fill(rank)(Random.nextDouble())
    (v1, v2, 0.0, 0.0)
}

// calculate global rating mean
edges.cache()
val (rs, rc) = edges.map(e => (e.attr, 1L)).reduce((a, b) => (a._1 + b._1, a._2 + b._2))
val u = rs / rc

// construct graph
var g = Graph.fromEdges(edges, defaultF(conf.rank)).cache()
materialize(g)
edges.unpersist()

// Calculate initial bias and norm
val t0 = g.aggregateMessages[(Long, Double)](
    ctx => { ctx.sendToSrc((1L, ctx.attr)); ctx.sendToDst((1L, ctx.attr)) },
    (g1, g2) => (g1._1 + g2._1, g1._2 + g2._2))

val gJoinT0 = g.outerJoinVertices(t0) {
    (vid: VertexId, vd: (Array[Double], Array[Double], Double, Double),
    msg: Option[(Long, Double)]) =>
    (vd._1, vd._2, msg.get._2 / msg.get._1 - u, 1.0 / scala.math.sqrt(msg.get._1))
}.cache()
materialize(gJoinT0)
g.unpersist()
g = gJoinT0
{% endhighlight %}

1. 9-12: 首先计算 μ, 在输入的 RDD 上作简单的 MapReduce 即可
2. 14-17: 从边生成图 g，节点的属性全部为 defaultF 函数生成的随机初始值，将图进行存储，并释放边的 RDD （后续类似操作的描述在下文中省略）
3. 19-22: 通过聚合消息，得到一个拓扑一致的图，图中的节点属性为 `(num(rates), sum(rates))`，用于计算个体均值来初始化 \\(b\_i = \sum(r\_{\*i})/num(r\_{\*i}) - u, b\_u = \sum(r\_{u\*})/num(r\_{u\*}) - u\\) （事实上并不是图，而是一个包含了节点 ID 及其接收到的消息的 RDD，具体的类型请参见官方文档）
4. 24-31: 通过将两个图进行合并，更新 g 中对应的属性值，函数无副作用，因此要重命名

### Trainning Through Messages

{% highlight scala linenos %}
def sendMsgTrainF(conf: Conf, u: Double)
    (ctx: EdgeContext[
        (Array[Double], Array[Double], Double, Double),
        Double,
        (Array[Double], Array[Double], Double)]) {
    val (usr, itm) = (ctx.srcAttr, ctx.dstAttr)
    val (p, q) = (usr._1, itm._1)
    val rank = p.length
    var pred = u + usr._3 + itm._3 + blas.ddot(rank, q, 1, usr._2, 1)
    pred = math.max(pred, conf.minVal)
    pred = math.min(pred, conf.maxVal)
    val err = ctx.attr - pred
    // updateP = (err * q - conf.gamma7 * p) * conf.gamma2
    val updateP = q.clone()
    blas.dscal(rank, err * conf.gamma2, updateP, 1)
    blas.daxpy(rank, -conf.gamma7 * conf.gamma2, p, 1, updateP, 1)
    // updateQ = (err * usr._2 - conf.gamma7 * q) * conf.gamma2
    val updateQ = usr._2.clone()
    blas.dscal(rank, err * conf.gamma2, updateQ, 1)
    blas.daxpy(rank, -conf.gamma7 * conf.gamma2, q, 1, updateQ, 1)
    // updateY = (err * usr._4 * q - conf.gamma7 * itm._2) * conf.gamma2
    val updateY = q.clone()
    blas.dscal(rank, err * usr._4 * conf.gamma2, updateY, 1)
    blas.daxpy(rank, -conf.gamma7 * conf.gamma2, itm._2, 1, updateY, 1)
    ctx.sendToSrc((updateP, updateY, (err - conf.gamma6 * usr._3) * conf.gamma1))
    ctx.sendToDst((updateQ, updateY, (err - conf.gamma6 * itm._3) * conf.gamma1))
}
{% endhighlight %}

* 该函数的作用是利用上边分析得到的学习公式，以边为单位，以消息的形式，逐个对节点参数进行调整
* 此处仅仅是计算更新，发送消息，稍后进行消息的聚合，参数的更新
* 更新公式与上文完全对应，不再展开，有趣的是，原论文中的 lambda6 和 lambda7 在此处被混为了 gamma，事实上这并不符合规范，正则化参数通常应该写作 lambda，Whatever...
* 参数 conf 为训练参数，包括：
  * rank: 表示隐藏特质的个数，即矩阵的维度 k
  * maxIters: 迭代次数上限，此处的实现是确确实实地执行到该上限，不会提前判断是否收敛
  * gamma1-2: 表示两个学习速率
  * gamma6-7: 表示两个正则化参数

### Updating Properties

执行如下的更新步骤 maxIters 次：

{% highlight scala linenos %}
// Phase 1, calculate pu + |N(u)|^(-0.5)*sum(y) for user nodes
g.cache()
val t1 = g.aggregateMessages[Array[Double]](
ctx => ctx.sendToSrc(ctx.dstAttr._2),
(g1, g2) => {
    val out = g1.clone()
    blas.daxpy(out.length, 1.0, g2, 1, out, 1)
    out
})
val gJoinT1 = g.outerJoinVertices(t1) {
(vid: VertexId, vd: (Array[Double], Array[Double], Double, Double),
    msg: Option[Array[Double]]) =>
    if (msg.isDefined) {
    val out = vd._1.clone()
    blas.daxpy(out.length, vd._4, msg.get, 1, out, 1)
    (vd._1, out, vd._3, vd._4)
    } else {
    vd
    }
}.cache()
materialize(gJoinT1)
g.unpersist()
g = gJoinT1

// Phase 2, update p for user nodes and q, y for item nodes
g.cache()
val t2 = g.aggregateMessages(
sendMsgTrainF(conf, u),
(g1: (Array[Double], Array[Double], Double), g2: (Array[Double], Array[Double], Double)) =>
{
    val out1 = g1._1.clone()
    blas.daxpy(out1.length, 1.0, g2._1, 1, out1, 1)
    val out2 = g2._2.clone()
    blas.daxpy(out2.length, 1.0, g2._2, 1, out2, 1)
    (out1, out2, g1._3 + g2._3)
})
val gJoinT2 = g.outerJoinVertices(t2) {
(vid: VertexId,
    vd: (Array[Double], Array[Double], Double, Double),
    msg: Option[(Array[Double], Array[Double], Double)]) => {
    val out1 = vd._1.clone()
    blas.daxpy(out1.length, 1.0, msg.get._1, 1, out1, 1)
    val out2 = vd._2.clone()
    blas.daxpy(out2.length, 1.0, msg.get._2, 1, out2, 1)
    (out1, out2, vd._3 + msg.get._3, vd._4)
}
}.cache()
materialize(gJoinT2)
g.unpersist()
g = gJoinT2
{% endhighlight %}

1. 首先将与某个用户节点相连的所有电影节点的属性2，即 \\(y\_i\\) 进行聚合以更新用户属性2（参见上文）
    1. 每个 Triplet 向其源节点（用户）发送其目标节点（电影）的属性2，见第4行
    2. 用户节点将收到的消息中的值进行聚合，此处为向量求和
    3. 将取到的和乘以系数（此处为属性4），加上属性1，即得到更新后的属性2，见14-16行
2. 对 sendMsgTrainF 的消息进行聚合，并更新各个 p, q, y, b
    1. 消息聚合时，消息中所带的更新值对应位置各自求和（p, q, y 为向量），见31-35行
    2. 通过 join 将值更新至图 g，见41-45行

### Testing

{% highlight scala linenos %}
// calculate error on training set
def sendMsgTestF(conf: Conf, u: Double)
    (ctx: EdgeContext[(Array[Double], Array[Double], Double, Double), Double, Double]) {
    val (usr, itm) = (ctx.srcAttr, ctx.dstAttr)
    val (p, q) = (usr._1, itm._1)
    var pred = u + usr._3 + itm._3 + blas.ddot(q.length, q, 1, usr._2, 1)
    pred = math.max(pred, conf.minVal)
    pred = math.min(pred, conf.maxVal)
    val err = (ctx.attr - pred) * (ctx.attr - pred)
    ctx.sendToDst(err)
}

g.cache()
val t3 = g.aggregateMessages[Double](sendMsgTestF(conf, u), _ + _)
val gJoinT3 = g.outerJoinVertices(t3) {
    (vid: VertexId, vd: (Array[Double], Array[Double], Double, Double), msg: Option[Double]) =>
    if (msg.isDefined) (vd._1, vd._2, vd._3, msg.get) else vd
}.cache()
materialize(gJoinT3)
g.unpersist()
g = gJoinT3
{% endhighlight %}

* 将每部电影相关的误差平方和存入该节点的属性4（之前的这个域并无意义），见第17行
* 这里有个问题，看到17行的代码，你可能会想，如果节点没有收到 msg，i.e. 这个电影没有人进行评价，那么它的属性4会保留原值，追溯代码发现这个原值在 Initialization 的第27行被定义，那么按说这个节点没人评价就没有连线，那么在 init 的时候也并不能收到消息，所以27行中的 msg 应该是 None，直接调用 get 难道不会抛出异常么？
    * 事实上回忆图 g 的生成过程，它是通过一个包含所有边的 RDD 生成的，调用的是 fromEdges 方法，用这个方法生成的图中是不会有孤立点存在的，所以27行这么写是安全的，而这里的17行其实可以不进行条件判断，这样一边存在判断，另一边没有判断的做法反而让人困惑，Whatever...

### Misc

* 算法中的 materialize 函数在该文件中定义，写作两个 count 操作，为的是触发对应的顶点和边 RDD 的生成，我比较纳闷的是，materialize 随后 cache 应该是属于常见操作，为什么 RDD 不提供对应的接口通用呢？
  * 单独调用 cache 方法只是说在该 RDD 被第一次真正计算的时候再进行 cache，是个 lazy 的操作，并不触发计算任务
* 我认为用图的方式对该算法进行抽象是符合直觉的，因为算法中涉及到对 N(u) 集合的计算，对应了图中的邻节点的概念，如果用普通的 RDD 操作，则需要涉及到一系列的 filter，直觉上性能是有损失的，当然具体的性能我没有调研，所以其实我只是瞎扯蛋。

## Referrences

* Koren, Yehuda. "Factorization meets the neighborhood: a multifaceted collaborative filtering model." Proceedings of the 14th ACM SIGKDD international conference on Knowledge discovery and data mining. ACM, 2008.
* [GraphX](http://spark.apache.org/docs/latest/graphx-programming-guide.html)
