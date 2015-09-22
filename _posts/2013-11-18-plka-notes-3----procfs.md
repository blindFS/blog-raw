---
layout: post
title: "PLKA notes 3 -- procfs-basic"
description: ""
category: OS
tags: linux kernel
---
{% include JB/setup %}

## proc FS

### /proc files

* Memory management
* Characteristic data of system processes
* Filesystems
* Device drivers
* System buses
* Power management
* Terminals
* System control parameters

The trend in kernel development is away from the provision of information by the proc filesystem and
toward the exporting of data by a problem-specific but likewise virtual filesystem.

#### /proc/PID/ files

| Filename   | Explanation                                                                          |
|------------|--------------------------------------------------------------------------------------|
| cmdline    | command to init the process                                                          |
| environ    | environment variables                                                                |
| maps       | All memory mappings to libraries (and to the binary file itself) used by the process |
| status     | general information on process status                                                |
| stat/statm | more status information on the process and its memory consumption                    |
| cwd        | current working directory of the process                                             |
| exe        | binary file with the application code                                                |
| root       | root directory of the process (chroot)                                               |

#### General System Information


| Filename           | Explanation                                                                                                        |
|--------------------|--------------------------------------------------------------------------------------------------------------------|
| iomem/ioports      | information on memory addresses and ports used to communicate with devices                                         |
| buddyinfo/slabinfo | current utilization of the buddy system and slab allocator                                                         |
| meminfo            | memory usage                                                                                                       |
| vmstat             | further memory management characteristics                                                                          |
| kallsyms           | a table with the addresses of all global kernel variables and procedures including their addresses in memory       |
| kcore              | a dynamic core file that ‘‘contains‘‘ all data of the running kernel — that is, the entire contents of main memory |
| interrupts         | the number of interrupts raised during the current operation                                                       |
| loadavg            | average system loading (i.e., the length of the run queue) during the last 60 seconds, 5 minutes, and 15 minutes   |
| uptime             | uptime                                                                                                             |

#### /proc/net files

* udp/tcp/udp6/tcp6
* arp
* dev

#### /proc/sys files

System Control Parameters

### Data Structure

* proc_dir_entry    get_info   read_proc/write_proc
* proc_inode    proc_get_link   proc_read

### Initialization

+--------------+<br/>
|proc_root_init|<br/>
+------+-------+<br/>
       |        +--------------------+<br/>
       +------->|proc_init_inodecache|<br/>
       |        +--------------------+<br/>
       |<br/>
       |        +-------------------+<br/>
       +------->|register_filesystem|<br/>
       |        +-------------------+<br/>
       |<br/>
       |        +---------------+<br/>
       +------->|kern_mount_data|<br/>
       |        +---------------+<br/>
       |<br/>
       |        +--------------+<br/>
       +------->|proc_misc_init|<br/>
       |        +--------------+<br/>
       |<br/>
       |        +-------------+<br/>
       +------->|proc_net_init|<br/>
       |        +-------------+<br/>
       |<br/>
       |        +----------+<br/>
       +------->|proc_mkdir|<br/>
                +----------+<br/>

### Mounting the Filesystem

`mount -t proc proc /proc`

### Managing /proc Entries

* create_proc_entry/creat_proc_read_entry/cread_proc_info_entry
* proc_register
* get_inode_number
* proc_mkdir/proc_mkdir_mode/proc_symlink
* remove_proc_entry
