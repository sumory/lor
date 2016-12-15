### benchmark1

a `hello world` program

#### case 1

```
centos virtual machine
CPU 8core:       Intel(R) Xeon(R) CPU E5-2680 v2 @ 2.80GHz
MemTotal:        8027960 kB

nginx.conf

worker_processes 8;

events {
    worker_connections 4096;
}
```


siege -c 100 -b http://192.168.100.122:8888/hello

tps 8000+

to be specified...