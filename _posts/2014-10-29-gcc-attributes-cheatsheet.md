---
layout: post
title: "Gcc attributes cheatsheet"
description: ""
category: cheatsheet
tags: linux kernel sparse gcc
---
{% include JB/setup %}

# Attributes

* 用于修改编译器默认行为，错误检测
* [doc-func](https://gcc.gnu.org/onlinedocs/gcc-4.0.0/gcc/Function-Attributes.html)
* [doc-var](https://gcc.gnu.org/onlinedocs/gcc-4.0.0/gcc/Variable-Attributes.html)
* [doc-type](https://gcc.gnu.org/onlinedocs/gcc-4.0.0/gcc/Type-Attributes.html)

## Attributes of functions

| Attributes                                | Explanation in chinese                                    |
|-------------------------------------------|-----------------------------------------------------------|
| alias ("target")                          | 将函数声明为target的一个别名                              |
| always_inline                             | 即使没开优化也inline                                      |
| cdecl                                     | 函数的调用者会将传参用的栈弹出                            |
| const                                     | 函数不能读取global memory，是pure的加强形式               |
| constructor/destructor                    | 在main函数之前/之后被调用                                 |
| deprecated                                | 用来提示函数已经被舍弃                                    |
| fastcall                                  | i386下前两个参数通过ecx和edx传递                          |
| format (archetype, str-idx, 1st-to-check) | 用于检查从1st-to-check开始的参数是否满足第str-idx         |
| \/                                        | 个参数给出的格式，archetype为printf,scanf...              |
| interrupt                                 | ARM,AVR...架构下用于声明中断处理程序                      |
| long_call/short_call                      | ARM下的long_call和short_call                              |
| malloc                                    | 函数返回时如果返回非空指针，则不存在该指针的alias指针     |
| noinline                                  | 防止inline                                                |
| nonnull (arg-index, ...)                  | 函数参数不能为空指针                                      |
| noreturn                                  | 永不返回的函数，如abort，exit，fatal                      |
| nothrow                                   | 函数不抛出异常                                            |
| pure                                      | 声明函数没有副作用                                        |
| regparm (number)                          | i386下通过寄存器传递至多number个参数                      |
| section ("name")                          | 将生成的机器码放在特定段，默认为text段                    |
| sentinel                                  | 函数调用时某个参数为NULL                                  |
| sp_switch                                 | 配合interrupt_handler使用，中断处理使用额外的栈           |
| stdcall                                   | i386下与cdecl类似                                         |
| used/unused                               | 必须被使用/可以不使用                                     |
| visibility ("type")                       | 修改链接时符号的能见度，protected,hidden,default,internal |
| warn_unused_result                        | 触发warning，如果调用者不使用返回值                       |
| weak                                      | 链接时生成弱符号，便于被重载                              |

## Attributes of variables

| Attributes             | Explanation in chinese                               |
|------------------------|------------------------------------------------------|
| aligned (alignment)    | n字节对齐                                            |
| cleanup (cleanup_func) | 调用cleanup_func函数，当越界时                       |
| common/nocommon        | 放入"common"存储器/直接分配                          |
| dprecated              | ...                                                  |
| mode (mode)            | 指定数据类型，如byte,word,pointer                    |
| packed                 | 最小化对齐要求                                       |
| section ("name")       | 指定段                                               |
| tls_model ("mode")     | 为一个__thread变量修改Thread-Local模式可以是         |
| \/                     | global-dynamic,local-dynamic,initial-exec,local-exec |
| unused                 | ...                                                  |
| vector_size (bytes)    | 指定大小                                             |
| weak                   | 弱符号                                               |
| ms_struct/gcc_struct   | 当使用packed之后，用于区别microsoft ABI              |

## Attributes of types

| Attributes           | Explanation in chinese                     |
|----------------------|--------------------------------------------|
| aligned              | ...                                        |
| packed               | ...                                        |
| unused               | ...                                        |
| dprecated            | ...                                        |
| transparent_union    | 作用于联合体，当用作函数参数时，做特殊处理 |
| ms_struct/gcc_struct | ...                                        |

## Sparse-specific

* [wiki](http://en.wikipedia.org/wiki/Sparse)
* *Sparse* 是linux内核编译时使用的静态检测工具
* 编译内核时，指定 `make C=1/2` 时会调用Sparse
    - 1 : 检查所有重新编译的代码
    - 2 : 检查所有代码
* 额外的attributes:
    - address_space (num) : 0 kernel, 1 user, 2 io
    - noderef : no dereference, 不能解引用，即内核不访问这部分的空间
    - bitwise : 确保内核使用的整数是在同样的位方式下(大端/小端)
    - force : 修饰的变量可以进行强制类型转换，没有使用__force修饰的变量进行强转时，报warning
    - nocast : 不允许强转
    - safe : 如果在使用前没有判断是否为null，报warning
    - context (expression, in_context, out_context) : 引用计数器操作
* `linux/compiler.h` 中，如下
{% highlight c %}
#ifdef __CHECKER__
# define __user     __attribute__((noderef, address_space(1)))
# define __kernel   __attribute__((address_space(0)))
# define __safe     __attribute__((safe))
# define __force    __attribute__((force))
# define __nocast   __attribute__((nocast))
# define __iomem    __attribute__((noderef, address_space(2)))
# define __must_hold(x) __attribute__((context(x,1,1))) // x执行前为1，执行后为1
# define __acquires(x)  __attribute__((context(x,0,1))) // x执行前为0，执行后为1
# define __releases(x)  __attribute__((context(x,1,0))) // x执行前为1，执行后为0
# define __acquire(x)   __context__(x,1)  // +1操作
# define __release(x)   __context__(x,-1) // -1操作
# define __cond_lock(x,c)   ((c) ? ({ __acquire(x); 1; }) : 0)
# define __percpu   __attribute__((noderef, address_space(3)))
#ifdef CONFIG_SPARSE_RCU_POINTER
# define __rcu      __attribute__((noderef, address_space(4)))
{% endhighlight %}
