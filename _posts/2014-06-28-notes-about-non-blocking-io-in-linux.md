---
layout: post
title: "Notes about non-blocking IO in linux"
description: ""
category: notes
tags: linux kernel
---
{% include JB/setup %}

刚接触这些内容，从应用的角度出发来学习。
以下笔记内容翻译自[这里](http://www.ulduzsoft.com/2014/01/select-poll-epoll-practical-difference-for-system-architects/)。

## 简介

在设计高性能应用的时候，我们需要使用非阻塞的I/O，我们需要确定使用何种选择手段来处理文件描述符fd产生的事件，
linux下，我们的选择有select，poll，epoll。这些方式都是所谓的多路IO复用，用非阻塞的方式来提升性能。
下面介绍三者的用法和区别。

## select()

为了使用select，开发者需要初始化一系列的 fd_set 结构，这些数据结构可以看作是对某个IO事件来说，需要监控的
所有文件描述符的集合，然后我们需要调用select()函数，典型的流程如下：

{% highlight c %}
fd_set fd_in, fd_out;
struct timeval tv;

// Reset the sets
FD_ZERO( &fd_in );
FD_ZERO( &fd_out );

// Monitor sock1 for input events
FD_SET( sock1, &fd_in );

// Monitor sock2 for output events
FD_SET( sock1, &fd_out );

// Find out which socket has the largest numeric value as select requires it
int largest_sock = sock1 > sock2 ? sock1 : sock2;

// Wait up to 10 seconds
tv.tv_sec = 10;
tv.tv_usec = 0;

// Call the select
int ret = select( largest_sock, &fd_in, &fd_out, NULL, &tv );

// Check if select actually succeed
if ( ret == -1 )
    // report error and abort
else if ( ret == 0 )
    // timeout; no event detected
else
{
    if ( FD_ISSET( sock1, &fd_in ) )
        // input event on sock1

    if ( FD_ISSET( sock2, &fd_out ) )
        // output event on sock2
}
{% endhighlight %}

select 的五个参数:

1. 被监控的文件描述符的范围，0~arg0-1
2. 所有被监控读事件的fd集合
3. 所有被监控写事件的fd集合
4. 所有被监控异常事件的fd集合
5. 超时计时器

select的设计比较早，所以也存在较多缺陷，比如:

* 允许监控的fd的数量上限由 FD_SETSIZE指定，通常为1024
* 事件检测的机制有限
* fd_set 不可复用
* 检测具体产生事件的fd的时候，需要用 FD_ISSET 将所有fd轮循一遍，效率低下
* fd_set 中被监控的fd不能被其它线程修改，否则可能造成意想不到的结果

使用select的两个理由:

* 可移植性，win XP是不支持poll的...
* 对时间的控制可以到纳秒级别，然而poll和epoll只有毫秒级别

## poll()

用 pollfd 取代了 fd_set 。
典型的流程:

{% highlight c %}
// The structure for two events
struct pollfd fds[2];

// Monitor sock1 for input
fds[0].fd = sock1;
fds[0].events = POLLIN;

// Monitor sock2 for output
fds[1].fd = sock2;
fds[1].events = POLLOUT;

// Wait 10 seconds
int ret = poll( fds, 2, 10000 );

// Check if poll actually succeed
if ( ret == -1 )
    // report error and abort
else if ( ret == 0 )
    // timeout; no event detected
else
{
    // If we detect the event, zero it out so we can reuse the structure
    if ( pfd[0].revents & POLLIN )
        pfd[0].revents = 0;
        // input event on sock1

    if ( pfd[1].revents & POLLOUT )
        pfd[1].revents = 0;
        // output event on sock2
}
{% endhighlight %}

跟 select 很类似，不过 poll 函数的参数显得更为清晰，第二个参数就是 pollfd 数组的长度，第三个则是 timeout，单位毫秒。

* 没有数量的限制
* pollfd 可以被重用
* 更加细致的事件监听机制

与 select 一样，还是有后两个问题的存在。

当面临如下情况时，应该选择 poll 而不是 epoll:

* 不仅仅支持linux（epoll is linux only）
* 只需要监控 1k 以内的fd，大数量时 epoll 的性能才会明显
* 以socket为例，当链接建立的时间很短时，即便链接数量很大，epoll的性能提升也不够明显

## epoll()

epoll 是最新的选择机制。
我们需要这些准备工作:

* 创建 epoll 描述符，通过 epoll_create()
* 初始化 struct epoll
* 调用 epoll_ctl(... EPOLL_CTL_ADD ) 来添加监控的描述符
* epoll_wait() 等待一定数量的事件，并将事件存储为 epoll_event 数据结构
* 遍历 epoll_event 数组中的前n个有效单位，处理事件

典型的流程：

{% highlight c %}
// Create the epoll descriptor. Only one is needed per app, and is used to monitor all sockets.
// The function argument is ignored (it was not before, but now it is), so put your favorite number here
int epollfd = epoll_create( 0xCAFE );

if ( epollfd < 0 )
 // report error

// Initialize the epoll structure in case more members are added in future
struct epoll_event ev = { 0 };

// Associate the connection class instance with the event. You can associate anything
// you want, epoll does not use this information. We store a connection class pointer, pConnection1
ev.data.ptr = pConnection1;

// Monitor for input, and do not automatically rearm the descriptor after the event
ev.events = EPOLLIN | EPOLLONESHOT;

// Add the descriptor into the monitoring list. We can do it even if another thread is
// waiting in epoll_wait - the descriptor will be properly added
if ( epoll_ctl( epollfd, EPOLL_CTL_ADD, pConnection1->getSocket(), &ev ) != 0 )
    // report error

// Wait for up to 20 events (assuming we have added maybe 200 sockets before that it may happen)
struct epoll_event pevents[ 20 ];

// Wait for 10 seconds
int ready = epoll_wait( pollingfd, pevents, 20, 10000 );

// Check if epoll actually succeed
if ( ret == -1 )
    // report error and abort
else if ( ret == 0 )
    // timeout; no event detected
else
{
    // Check if any events detected
    for ( int i = 0; i < ret; i++ )
    {
        if ( pevents[i].events & EPOLLIN )
        {
            // Get back our connection pointer
            Connection * c = (Connection*) pevents[i].data.ptr;
            c->handleReadEvent();
         }
    }
}
{% endhighlight %}

优势:

* 只返回了真实出发事件的描述符，省去了循环所有描述符的开销
* 可以为监控的事件添加附加信息，如回调函数，而不仅仅是文件描述符
* 允许其余线程动态修改 epollfd
* 边沿触发...
* 可以使用多线程同时等待同一个epoll队列

劣势:

* 无法使用简单的位操作，而是必须用 epoll_ctl 系统调用来修改事件标志位，低效
* 添加 socket 的操作也需要额外的一次系统调用
* 只能用于linux
* 更加难以编写以及debug

## libevent

libevent 将各种 polling method 进行了封装，呈现出统一的上层接口，便于移植。
但是编写的难度反而提升了。
一般用于这样的场合:

* 需要用 epoll 来提升性能
* 需要跨平台的支持
