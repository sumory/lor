# Lor

[![https://travis-ci.org/sumory/lor.svg?branch=master](https://travis-ci.org/sumory/lor.svg?branch=master)](https://travis-ci.org/sumory/lor)  [![GitHub release](https://img.shields.io/github/release/sumory/lor.svg)](https://github.com/sumory/lor/releases/latest) [![license](https://img.shields.io/github/license/sumory/lor.svg)](https://github.com/sumory/lor/blob/master/LICENSE)

<a href="./README_zh.md" style="font-size:13px">中文</a> <a href="./README.md" style="font-size:13px">English</a>

**Lor**是一个运行在[OpenResty](http://openresty.org)上的基于Lua编写的Web框架.

- 路由采用[Sinatra](http://www.sinatrarb.com/)风格，结构清晰，易于编码和维护.
- API借鉴了[Express](http://expressjs.com)的思路和设计，Node.js跨界开发者可以很快上手.
- 支持多种路由，路由可分组，路由匹配支持正则模式.
- 支持middleware机制，可在任意路由上挂载中间件.
- 可作为HTTP API Server，也可用于构建传统的Web应用.


### 文档

[http://lor.sumory.com](http://lor.sumory.com)

#### 示例项目

- 简单示例项目[lor-example](https://github.com/lorlabs/lor-example)
- 全站示例项目[openresty-china](https://github.com/sumory/openresty-china)


### 快速开始

**特别注意:** 在使用lor之前请首先确保OpenResty已安装，并将`nginx`/`resty`命令配置到环境变量中。即在命令行直接输入`nginx -v`、`resty -v`能正确执行。

一个简单示例(更复杂的示例或项目模板请使用`lord`命令生成)：

```lua
local lor = require("lor.index")
local app = lor()

app:get("/", function(req, res, next)
    res:send("hello world!")
end)

-- 路由示例: 匹配/query/123?foo=bar
app:get("/query/:id", function(req, res, next)
    local foo = req.query.foo
    local path_id = req.params.id
    res:json({
        foo = foo,
        id = path_id
    })
end)

-- 错误处理插件，可根据需要定义多个
app:erroruse(function(err, req, res, next)
    -- err是错误对象
    ngx.log(ngx.ERR, err)
    if req:is_found() ~= true then
        return res:status(404):send("sorry, not found.")
    end
    res:status(500):send("server error")
end)

app:run()
```

### 安装


#### 1）使用脚本安装(推荐)

使用Makefile安装lor框架:

```shell
git clone https://github.com/sumory/lor
cd lor
make install
```

默认`lor`的运行时lua文件会被安装到`/usr/local/lor`下， 命令行工具`lord`被安装在`/usr/local/bin`下。

如果希望自定义安装目录， 可参考如下命令自定义路径：

```shell
make install LOR_HOME=/path/to/lor LORD_BIN=/path/to/lord
```

执行**默认安装**后, lor的命令行工具`lord`就被安装在了`/usr/local/bin`下, 通过`which lord`查看:

```
$ which lord
/usr/local/bin/lord
```

`lor`的运行时包安装在了指定目录下, 可通过`lord path`命令查看。


#### 2）使用opm安装

`opm`是OpenResty即将推出的官方包管理器，从v0.2.2开始lor支持通过opm安装：

```
opm install sumory/lor
```

注意： 目前opm不支持安装命令行工具，所以此种方式安装后不能使用`lord`命令。


#### 3）使用homebrew安装

除使用以上方式安装外, Mac用户还可使用homebrew来安装lor, 该方式由[@syhily](https://github.com/syhily)提供， 更详尽的使用方法请参见[这里](https://github.com/syhily/homebrew-lor)。

```
$ brew tap syhily/lor
$ brew install lor
```

至此， `lor`框架已经安装完毕，接下来使用`lord`命令行工具快速开始一个项目骨架.


### 使用

```
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

执行`lord new lor_demo`，则会生成一个名为lor_demo的示例项目，然后执行：

```
cd lor_demo
lord start
```

之后访问[http://localhost:8888/](http://localhost:8888/)， 即可。

更多使用方法，请参考[use cases](./spec/cases)测试用例。

### Homebrew

[https://github.com/syhily/homebrew-lor](https://github.com/syhily/homebrew-lor)由[@syhily](https://github.com/syhily)维护。

### 贡献者

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

### 讨论交流

有一个QQ群用于在线讨论: 522410959

### License

[MIT](./LICENSE)
