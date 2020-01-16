# Lor

[![https://travis-ci.org/sumory/lor.svg?branch=master](https://travis-ci.org/sumory/lor.svg?branch=master)](https://travis-ci.org/sumory/lor)  [![GitHub release](https://img.shields.io/github/release/sumory/lor.svg)](https://github.com/sumory/lor/releases/latest) [![license](https://img.shields.io/github/license/sumory/lor.svg)](https://github.com/sumory/lor/blob/master/LICENSE)

<a href="./README_zh.md" style="font-size:13px">中文</a> <a href="./README.md" style="font-size:13px">English</a>

A fast and minimalist web framework based on [OpenResty](http://openresty.org).



```lua
local lor = require("lor.index")
local app = lor()

app:get("/", function(req, res, next)
    res:send("hello world!")
end)

app:run()
```

## Examples

- [lor-example](https://github.com/lorlabs/lor-example)
- [openresty-china](https://github.com/sumory/openresty-china)
- [lua-redis-admin](https://github.com/lifeblood/lua-redis-admin)


## Installation

1) shell

```shell
git clone https://github.com/sumory/lor
cd lor
make install
```

`LOR_HOME` and `LORD_BIN` are supported by `Makefile`, so the following command could be used to customize installation:

```
make install LOR_HOME=/path/to/lor LORD_BIN=/path/to/lord
```

2) opm

`opm install` is supported from v0.2.2.

```
opm install sumory/lor
```

`lord` cli is not supported with this installation.

3) homebrew

you can use [homebrew-lor](https://github.com/syhily/homebrew-lor) on Mac OSX.

```
$ brew tap syhily/lor
$ brew install lor
```


## Features

- Routing like [Sinatra](http://www.sinatrarb.com/) which is a famous Ruby framework
- Similar API with [Express](http://expressjs.com), good experience for Node.js or Javascript developers
- Middleware support
- Group router support
- Session/Cookie/Views supported and could be redefined with `Middleware`
- Easy to build HTTP APIs, web site, or single page applications


## Docs & Community

- [Website and Documentation](http://lor.sumory.com).
- [Github Organization](https://github.com/lorlabs) for Official Middleware & Modules.


## Quick Start

A quick way to get started with lor is to utilize the executable cli tool `lord` to generate an scaffold application.

`lord` is installed with `lor` framework. it looks like:

```bash
$ lord -h
lor ${version}, a Lua web framework based on OpenResty.

Usage: lord COMMAND [OPTIONS]

Commands:
 new [name]             Create a new application
 start                  Starts the server
 stop                   Stops the server
 restart                Restart the server
 version                Show version of lor
 help                   Show help tips
```

Create app:

```
$ lord new lor_demo
```

Start server:

```
$ cd lor_demo && lord start
```

Visit [http://localhost:8888](http://localhost:8888).


## Tests

Install [busted](http://olivinelabs.com/busted/), then run test

```
busted spec/*
```

## Homebrew

[https://github.com/syhily/homebrew-lor](https://github.com/syhily/homebrew-lor) maintained by [@syhily](https://github.com/syhily)

## Contributors

- [@ms2008](https://github.com/ms2008)
- [@wanghaisheng](https://github.com/wanghaisheng)
- [@lihuibin](https://github.com/lihuibin)
- [@syhily](https://github.com/syhily)
- [@vinsonzou](https://github.com/vinsonzou)
- [@lhmwzy](https://github.com/lhmwzy)
- [@hanxi](https://github.com/hanxi)
- [@诗兄](https://github.com/269724033)
- [@hetz](https://github.com/hetz)
- [@XadillaX](https://github.com/XadillaX)

## License

[MIT](./LICENSE)
