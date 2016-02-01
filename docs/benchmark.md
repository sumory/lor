### benchmark1

a `hello world` program

#### case 1

```
centos virtual machine
CPU 8core:       Intel(R) Xeon(R) CPU E5-2680 v2 @ 2.80GHz
MemTotal:        8027960 kB

nginx.conf

worker_processes 4;

events {
    worker_connections 4096;
}
```


siege -c 100 -b http://192.168.100.122:8888/hello

```
Transactions:                 538757 hits
Availability:                 100.00 %
Elapsed time:                 292.32 secs
Data transferred:               6.68 MB
Response time:                  0.04 secs
Transaction rate:            1843.04 trans/sec
Throughput:                     0.02 MB/sec
Concurrency:                   80.02
Successful transactions:      538757
Failed transactions:               0
Longest transaction:            0.13
Shortest transaction:           0.00
```
```
Transactions:                 199908 hits
Availability:                 100.00 %
Elapsed time:                  78.82 secs
Data transferred:               2.48 MB
Response time:                  0.04 secs
Transaction rate:            2536.26 trans/sec
Throughput:                     0.03 MB/sec
Concurrency:                   99.80
Successful transactions:      199908
Failed transactions:               0
Longest transaction:            0.13
Shortest transaction:           0.01
```

#### case 2

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

```
Transactions:                 400002 hits
Availability:                 100.00 %
Elapsed time:                 148.84 secs
Data transferred:               4.96 MB
Response time:                  0.04 secs
Transaction rate:            2687.46 trans/sec
Throughput:                     0.03 MB/sec
Concurrency:                   99.79
Successful transactions:      400002
Failed transactions:               0
Longest transaction:            0.17
Shortest transaction:           0.00
```

### benchmark2

a `hello world` program in some group router after more than 10 `route` or `layer`


```
centos virtual machine
Intel(R) Xeon(R) CPU E5-2680 v2 @ 2.80GHz - 8 core
MemTotal:        8027960 kB

nginx.conf

worker_processes 8;

events {
    worker_connections 4096;
}
```


siege -c 100 -b http://192.168.100.122:8888/todo/hello

```

Transactions:                 593496 hits
Availability:                 100.00 %
Elapsed time:                 212.30 secs
Data transferred:               7.36 MB
Response time:                  0.04 secs
Transaction rate:            2795.55 trans/sec
Throughput:                     0.03 MB/sec
Concurrency:                   98.25
Successful transactions:      593496
Failed transactions:               0
Longest transaction:            0.38
Shortest transaction:           0.00
```

