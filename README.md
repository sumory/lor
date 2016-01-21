# Lor

[![https://travis-ci.org/sumory/lor.svg?branch=v0.0.2](https://travis-ci.org/sumory/lor.svg?branch=v0.0.2)](https://travis-ci.org/sumory/lor)

lor is a framework particularly designed for API usages. lor is based on [OpenResty](http://openresty.org) and still under heavy development.

## Get started

#### Clone

before install, you should have installed OpenResty and luajit

```
git clone https://github.com/sumory/lor
```

#### Install

```
cd lor
sh install.sh /opt/lua/lor #choose your path as you want
# `lor` cli in /usr/local/bin/
# `lor` package in /opt/lua/lor
```

#### Usage

use lor to build a project scaffold

```
cd /tmp/ && lor new lor_demo && cd /tmp/lor_demo
lor start
```

then open http://localhost:8888/


## Documentation

You can find more detail about `lor` on [http://lor.sumory.com](http://lor.sumory.com)

## License

[MIT](./LICENSE)