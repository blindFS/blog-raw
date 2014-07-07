---
layout: post
title: "Memorize memory!"
description: ""
category: notes
tags: linux memory regexp
---
{% include JB/setup %}

书到用时方恨少... 我需要恶补一下有关内存的内容。以下的内容组织有些混乱，因为我仅仅对
我不了解的内容进行了记录。

## 虚拟内存

作用:

* 进程隔离
* 用内存映射文件 mmap
* 方便共享(COW)

### 虚存类型

|             | PRIVATE                                  | SHARED            |
|-------------|------------------------------------------|-------------------|
| ANONYMOUS   | stack/malloc()/mmap(ANON, PRIVATE)/brk() | mmap(ANON, SHARD) |
| FILE-BACKED | mmap(fd, PRIVATE)                        | mmap(fd, SHARED)  |

* Anonymous Memory 只对应 RAM，只有当这部分虚存被写时，才将其绑定到物理内存中
* File-backed/swap 对应磁盘文件，通常是当读写真实发生时才装载进RAM，也可以预取 madvise(2)

## 进程相关

* man proc(5)
* man pmap(1)
* `/proc/pid/maps` 不同列分别代表了:
    1. 地址区间
    2. 权限 可以通过 mprotect(2) 设置
    3. 偏移量 (对于文件)
    4. 设备
    5. inode
    6. 文件
* `/proc/pid/smaps` 比maps更加详细的信息 包括 RSS(占用的phy mem)， Anonymous
* `/proc/pid/mem` 虚拟内存的镜像，由于有未映射的VMA，需要通过lseek，read来读取
* shared anonymous map 其实是基于文件的通常存在于 tmpfs

| ELF 段  | 属性 |
|---------|------|
| .text   | r-x  |
| .rodata | r--  |
| .data   | rw-  |
| .bss    | rw-  |

* 通常 .rodata 紧跟着 .text, .bss 紧跟着 .data
* .data 和 .rodata 在 pmap 的输出中会显示文件，但在smaps的信息中，其类型属于 Anonymous
* .bss 不显示文件，属于 Anonymous

### [stack] 以及 [stack:thread_pid]

* 主线程的stack是被内核动态分配的
* 其余线程的stack在线程初始化的时候创建，可以通过 *pthread_attr* 中的 *stacksize* 指定
* stack 大小的上限可以通过 /etc/limits.conf, ulimit setrlimit(3) 指定
* alloca(3)
* 由于 [ register and stack allocation ](http://en.wikipedia.org/wiki/Register_allocation)
导致两个不同时使用的变量可能共享 stack中的同一个地址

### [heap]

* 通常 heap 会在低地址附近，靠近可执行文件的 .bss，但是会和 .bss 有一段不小的距离
* brk(2) / sbrk(2) 会增加 .bss 段的map
* 在 malloc(3) 的实现中，包括了 brk 的调用，所以程序员通常不需要调用 brk
* mmap(2)

## Tools

* valgrind
* massif

## Snippet

以下的程序会将某个进程的 heap 和 stack 转储到文件，顺便记录下 GNU regex 的基本用法。

{% highlight c %}
#include <stdio.h>
#include <string.h>
#include <regex.h>
#include <stdlib.h>
#include <sys/types.h>
#include <signal.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

int pid;
const char *p_heap = "([0-9A-Fa-f]+)-([0-9A-Fa-f]+) [-r].*heap";
const char *p_stack = "([0-9A-Fa-f]+)-([0-9A-Fa-f]+) [-r].*stack";
char n_mem[20], n_map[20];

// 查询 maps 文件，直到找到对应的 pattern. 修改 start 和 end 的数值为对应 VMA 的区间
int find_boundary(long *start, long *end, const char *regex) {
    regex_t ss;
    char *line = NULL;
    size_t len = 0;
    regmatch_t matchptr[2];

    if (regcomp(&ss, regex, REG_EXTENDED)) {
        perror("failed to compile the regexp...\n");
        return 2;
    }

    FILE *maps = fopen(n_map, "r");
    if (maps == NULL) {
        perror("failed to open maps file ... maybe no such pid \n");
        return 1;
    }

    while (getline(&line, &len, maps) != -1) {
        if (regexec(&ss, line, 3, matchptr, 0) == 0) {
            puts(line);
            int i;
            for (i = 1; i < 3; i++) {
                int size = matchptr[i].rm_eo-matchptr[i].rm_so;
                char *buf = malloc(size);
                memcpy(buf, &line[matchptr[i].rm_so], size);
                buf[size] = '\0';
                if (i == 1) {
                    *start = strtol(buf, NULL, 16);
                    printf("start: %ld\n", *start);
                } else {
                    *end = strtol(buf, NULL, 16);
                    printf("end: %ld\n", *end);
                }
            }
            break;
        }
    }

    if (line)
        free(line);
    regfree(&ss);
    fclose(maps);
    return 0;
}

void dump_to_file(int start, int end, char *fn) {
    int mem_fd, core_fd;
    int size = end - start;
    char *buff = (char *)malloc(size);
    printf("reading %d bytes from /proc/%d/mem\n", size, pid);

    mem_fd = open(n_mem, O_RDONLY);
    core_fd = open(fn, O_RDWR | O_CREAT);

    lseek(mem_fd, start, SEEK_SET);
    read(mem_fd, buff, size);
    write(core_fd, buff, size);

    free(buff);
    close(mem_fd);
    close(core_fd);
}

int main(int argc, char const* argv[])
{
    if (argc != 2){
        puts("Usage: memdump pid\n");
        return -1;
    }

    pid = atoi(argv[1]);
    printf("get pid %d\n", pid);
    sprintf(n_mem, "/proc/%d/mem", pid);
    sprintf(n_map, "/proc/%d/maps", pid);

    if (kill(pid, SIGSTOP) == -1) {
        printf("failed to sleep the process %d\n", pid);
        return -3;
    }

    long off_start = 0,  off_end = 0;

    if (find_boundary(&off_start, &off_end, p_heap) != 0) {
        perror(" find_boundary heap fails ... \n");
        return -4;
    }
    if (off_end != off_start)
        dump_to_file(off_start, off_end, "./heap");

    if (find_boundary(&off_start, &off_end, p_stack) != 0) {
        perror(" find_boundary stack fails ... \n");
        return -4;
    }
    if (off_end != off_start)
        dump_to_file(off_start, off_end, "./stack");

    if (kill(pid, SIGCONT) == -1) {
        printf("failed to continue the process %d\n", pid);
        return -5;
    }

    return 0;
}
{% endhighlight %}
