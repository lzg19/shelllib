# memory related
## page table size
`getconf PAGESIZE`
## cache line size
`getconf LEVEL1_DACHE_LINESIZE` or
`cat /proc/cpuinfo |grep cache_alignment`
# cpu related
## check 64 or 32 bit version
```
uname -a
uname -m
file /sbin/init
arch
```
For 32bit, it includes x686, for 64bit, it includes x86_64
