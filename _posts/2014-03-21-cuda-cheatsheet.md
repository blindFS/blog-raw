---
layout: post
title: "CUDA cheatsheet"
description: ""
category: notes
tags: CUDA gpu
---
{% include JB/setup %}

## Execution model

{% highlight text %}
               +---------------+        +-----+
               | Global memory | <----> | I/O |<-----+
               +---------------+        +-----+      |
                  ^  ^  ^                            |
+-----------------+--+--+------------------------+   |
|                 |  |  v                        |   |
|                 |  v +-----------------------+ |   |
|                 v +--+    Processing Unit    | |   |
|                +--+  |                       | |   |
| +--------+     |  |  |  +-----+ +----------+ | |   |
| | Shared |<----+--+->|  | ALU | | register | | |   |
| |        |<----+->|  |  +-----+ |   file   | | |   |
| | memory |<--->|  |  |          +----------+ | |   |
| +--------+     |  |  +--------------------+--+ |   |
|        ^       |  +--------------------+--+    |   |
|        v       +-----------------------+       |   |
|       +-------------------+                    |   |
|       |   Control  Unit   |                    |   |
|       | +----+     +----+ |                    |   |
|       | | PC |     | IR | |<-------------------+---+
|       | +----+     +----+ |                    |
|       +-------------------+                    |
|            Processor (SM)                      |
+------------------------------------------------+
{% endhighlight %}

### Heterogeneous host+device application C program

* serial parts in *host* C code
* parallel parts in *device* SPMD *kernel* C code

### CUDA thread

* each thread is a "virtualized" Von-Neumann processor

### CUDA kernel

* a CUDA *kernel* is executed by a grid(numbers of blocks) of threads
* all threads in a grid run the same *kernel* code(SPMD)
* each *kernel* has block indexes(*blockidx*) and thread indexes(*threadidx*)
* blockidx and threadidx can be 1D,2D or 3D
* threads within a block cooperate via *shared memory*, [[atomic operations]] and barrier synchronization
* threads in different blocks do not interact

### CUDA memories

* Device code can:
    * R/W per-thread registers
    * R/W all shared global memory
* Host code can
    * Transfer data to/from per grid global memory
    * Transfer data to/from host memory

* shared memory
    * one in each SM
    * faster than global memory

{% highlight text %}
+------------------------------------+   +------------------------------------+
| Block (0, 0)                       |   | Block (1, 0)                       |
|        +---------------+           |   |        +---------------+           |
|        | shared memory |           |   |        | shared memory |           |
|        +------+--------+           |   |        +------+--------+           |
|               ^   ^                |   |               ^   ^                |
| +-----------+ |   | +-----------+  |   | +-----------+ |   | +-----------+  |
| | registers | |   | | registers |  |   | | registers | |   | | registers |  |
| +-----------+ |   | +-----------+  |   | +-----------+ |   | +-----------+  |
|       ^       |   |       ^        |   |       ^       |   |       ^        |
|       |       |   |       |        |   |       |       |   |       |        |
|       v       v   v       v        |   |       v       v   v       v        |
| +--------------+  +--------------+ |   | +--------------+  +--------------+ |
| | thread(0, 0) |  | thread(1, 0) | |   | | thread(0, 0) |  | thread(1, 0) | |
| +--------------+  +--------------+ |   | +--------------+  +--------------+ |
+--------^------------------^--------+   +---------^-----------------^--------+
         |                  |                      |                 |
 +-------v------------------v----------------------v-----------------v--------+     +---------+
 | Global memory                                                              |<--->|         |
 +----------------------------------------------------------------------------+     |  Host   |
 +----------------------------------------------------------------------------+     |         |
 | Constant memory                                                            |<--->|         |
 +----------------------------------------------------------------------------+     +---------+
{% endhighlight %}

### CUDA compiler

{% highlight text %}
                         +---------------+
           +-------------| NVCC compiler |---------------+
 host code |             +---------------+               | device code(PTX)
           v                                             v
+----------+-------------+                +--------------+---------------+
| Host C compiler/linker |                | Device just-in-time compiler |
+------------------------+                +------------------------------+
           |                                             | GPU ISA
           v                                             v
    +--------------------------------------------------------+
    | Heterogeneous computing platform with CPUs, GPUs, etc. |
    +--------------------------------------------------------+
{% endhighlight %}

### CUDA Thread scheduling

* Threads are assigned to *Streaming Multiprocessors(SM)* in block granularity
    * up to 8 blocks in each SM
    * SM is a hardware device designed similar to CPUs
    * SM maintains thread/block idx
    * SM manages/schedules thread execution
* Each block is executed as 32-thread *warps*
    * an implementation decision
    * warps are scheduling units in SM
    * thread ids within a warp are consecutive
    * threads in a warp execute in SIMD
        * if threads in a single warp choose different branches
        * each thread will execute all branches serially
        * but only the right one takes effect(performance lost)
* SM implements zero-overhead warp scheduling
    * Warps whose next instruction has its operands ready for consumption are eligible for execution
    * Eligible warps are selected for execution on a prioritized scheduling policy
    * All threads in a warp execute the same instruction when selected.

### CUDA Control Divergence

* Instructions come in 3 flavors:
    * Operate
    * Data transfer
    * Program control flow
* Instruction cycle:
    1. Fetch
    2. Decode
    3. Execute
    4. Memory

## API functions

### Memory control

* cudaMalloc(address, size)
    * allocates object in the device *global memory*
* cudaFree(pointer)
    * frees object from device global memory
* cudaMemcpy(ptr_dest, ptr_src, size, type)
    * memory data transfer
    * transfer to device is asynchronous
    * type:
        * cudaMemcpyHostToDevice
        * cudaMemcpyDeviceToHost

### Function declarations

* `__device__`
    * executed on the *device*, called from the *device*
* `__global__`
    * executed on the *device*, called from the *host*
    * define kernel functions
    * must return void
* `__host__`
    * executed on the *host*, called from the *host*
    * should have sth like: `kernel_func<<<DimGrid, DimBlock>>>(args)`
    * DimGrid & DimBlock are both in type *dim3*
    * `__host__` can be omitted

### Variable declarations

| Variable declaration                    | Memory   | Scope  | Lifetime    |
|-----------------------------------------|----------|--------|-------------|
| int LocalVar                            | register | thread | thread      |
| `__device__ __shared__ int SharedVar`   | shared   | block  | block       |
| `__device__ int GlobalVar`              | global   | grid   | application |
| `__device__ __constant__ int GlobalVar` | constant | grid   | application |

* `__device__` is optional when used with `__shared__` or `__constant__`
* 这里的device理解为整个GPU device，global memory就相当于显存
* `const __restrict__` constant caching

### Barrier Synchronization

* API call: `__syncthreads()`
* All threads in the same block must reach the `__syncthreads()` before any can move on
* Best used to coordinate blocked algorigthms
    * To ensure that all elements of a block are loaded
    * To ensure that all elements of a block are consumed

### Device Query

* Number of devices in the system
    * `cudaGetDeviceCount(&dev_count)`
* Capability of devices

{% highlight cuda %}
cudaDeviceProp dev_prop;
for (i = 0, i < dev_count; i++) {
    cudaGetDeviceProperties( &dev_prop, i);
}
{% endhighlight %}

* cudaDeviceProp is a built-in C structure type
    * `dev_prop.maxThreadsPerBlock`
    * `dev_prop.sharedMemoryPerBlock`
    * ...

### wbImage_t

{% highlight cuda %}
typedef struct {
    int width;
    int height;
    int pitch; // pitch = (width+padding) * channels
    int channels;
    float* data;
} * wbImage_t

// these api functions are done in the host code
wbImage_t wbImage_new(int height, int width, int channels)
wbImage_t wbImport(char * File)
void wbImage_delete(wbImage_t img)
int wbImage_getWidth(wbImage_t img)
int wbImage_getHeight(wbImage_t img)
int wbImage_getChannels(wbImage_t img)
int wbImage_getPitch(wbImage_t img)
float *wbImage_getData(wbImage_t img)
{% endhighlight %}

## Performance Considerations

### Global memory(DRAM) Brandwith

* DRAM core arrays are slow
* DDR{2, 3} SDRAM cores clocked at 1/N speed of the interface:
    * load (N* interface width) of DRAM bits from the same row at once to an internal buffer, then transfer in N steps at interface speed.
    * DDR2/GDDR3: buffer width = 4* interface width
* many memory channels
* memory coalescing

## Data transfer

* Virtual memory management
    * many virtual memory spaces mapped into a single physical memory
    * virtual addresses are translated into physical addresses
    * *not* all variables and data structures are always in the physical memory
        * each virtual address space is divided into pages when mapped into physical memory
        * memory pages can be paged out to make room
        * whether a variable is in the physical memory is checked at address translation time
* DMA(Direct Memory Access) hardware is used for `cudaMemcpy()` for better efficiency
    * frees CPU for other tasks
    * transfers a number of bytes requested by OS
    * uses system interconnect (PCIe)
    * uses physical addresses
        * address is translated and page presence checked at beginning of each DMA transfer
* The OS can page-out the data that is being read or written by a DMA and page-in another virtual page into the same physical location
* Pinned memory
    * virtual memory pages that are marked so that they *cannot* be paged out
    * allocated/freeed by `cudaHostAlloc(pointer, size, option) cudaFreeHost(pointer)`
    * a.k.a Page Locked Memory, Locked Pages
    * CPU memory that serve as the src/destination of a DMA transfer must be pinned
    * limited resource
* *CUDA data transfer uses pinned memory*
    * if a source or destination of a `cudaMemcpy()` in the host memory is not allocated in pinned memory, it needs to be first copied to a pinned memory
    * 2x faster if the host memory is originally pinned

{% highlight text %}
                +-----------------+
                | CPU main memory |
                +-----------------+
                              ^
                       PCIe   |
                              |
+-----------------------------v---+
| +--------+              +-----+ |
| | global |<------------>| DMA | |
| | memory |              +-----+ |
| +--------+                      |
|     GPU card/other I/O cards    |
+---------------------------------+
{% endhighlight %}

### Task parallelism

* Some CUDA devices support device overlap: simultaneously *execute a kernle* while *copying data* between device and host memory
    * can be checked by `prop.deviceOverlap`

### CUDA streams

* a queue of operations(kernel launches/ memory copies)
* requests made from the host code are put into FIFO queues
* tasks in different streams can go in parallel

* API:http://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#streams

{% highlight cuda %}
cudaStream_t stream0, stream1;
cudaStreamCreate(&stream0);
cudaStreamCreate(&stream1);

cudaMemcpyAsync(dest, src, size, option, stream0);
kernelFunc<<<blockDim, threadDim, stream1>>>(args);
cudaStreamSynchronize(stream0)  // wait until all tasks in a stream have completed
{% endhighlight %}
