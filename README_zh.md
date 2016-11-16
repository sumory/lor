# Lor

<a href="./README_zh.md" style="font-size:13px">中文</a> <a href="./README.md" style="font-size:13px">English</a>

[![https://travis-ci.org/sumory/lor.svg?branch=master](https://travis-ci.org/sumory/lor.svg?branch=master)](https://travis-ci.org/sumory/lor)

**Lor**是一个运行在[OpenResty](http://openresty.org)上的基于Lua编写的Web框架.

- 路由采用[Sinatra](http://www.sinatrarb.com/)风格，Sinatra是Ruby小而精的web框架.
- API基本采用了[Express](http://expressjs.com)的思路和设计，Node.js跨界开发者可以很快上手.
- 支持插件(middleware)，路由可分组，路由匹配支持string或正则模式.
- lor会保持核心足够精简，扩展功能依赖middleware来实现. `lor`本身也是基于middleware构建的.
- 推荐使用lor作为HTTP API Server，lor也已支持session/cookie/html template等功能.
- 简单示例项目[lor-example](https://github.com/lorlabs/lor-example)
- 全站示例项目[openresty-china](https://github.com/sumory/openresty-china)


当前版本：v0.2.4


### 文档

[http://lor.sumory.com](http://lor.sumory.com)


### 快速开始

**特别注意:** 在使用lor之前请首先确保OpenResty已安装，并将`nginx`/`resty`命令配置到环境变量中。即在命令行直接输入`nginx -v`、`resty -v`能正确输出。

一个简单示例，更复杂的示例或项目模板请使用`lord`命令生成：

```
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

-- 404 error
app:use(function(req, res, next)
    if req:is_found() ~= true then
        res:status(404):send("sorry, not found.")
    end
end)

-- 错误处理插件，可根据需要定义多个
app:erroruse(function(err, req, res, next)
    -- err是错误对象
    res:status(500):send("服务器内发生未知错误")
end)
```

### 安装


#### 1）使用脚本安装(推荐)

使用install.sh安装lor框架，强烈建议在使用install.sh安装前阅读该脚本代码。

```
# 把lor安装到/opt/lua/lor目录下
sh install.sh /opt/lua
# 或者安装到默认目录/usr/local/lor下
sh install.sh
```

执行以上命令后lor的命令行工具`lord`就被安装在了`/usr/local/bin`下, 通过`which lord`查看:

```
$ which lord
/usr/local/bin/lord
```

`lor`的运行时包安装在了指定目录下, 若安装在`/opt/lua/lor`，通过`ll /opt/lua/lor`查看:

```
$ ll /opt/lua/lor
total 56
drwxr-xr-x  14 root  wheel   476B  1 22 01:18 .
drwxrwxrwt  14 root  wheel   476B  1 22 01:18 ..
-rw-r--r--   1 root  wheel     0B  1 19 23:48 CHANGELOG.md
-rw-r--r--   1 root  wheel   1.0K  1 19 23:48 LICENSE
-rw-r--r--   1 root  wheel     0B  1 19 23:48 Makefile
-rw-r--r--   1 root  wheel   1.9K  1 21 20:59 README-zh.md
-rw-r--r--   1 root  wheel   870B  1 21 20:59 README.md
drwxr-xr-x   4 root  wheel   136B  1 22 00:06 bin
-rw-r--r--   1 root  wheel   1.0K  1 21 22:37 install.sh
drwxr-xr-x   4 root  wheel   136B  1 21 22:40 lor
```

#### 2）使用opm安装

`opm`是OpenResty即将推出的官方包管理器，从v0.2.2开始lor支持通过opm安装：

```
opm install sumory/lor
```

注意： 目前opm不支持安装命令行工具，所以此种方式安装后不能使用`lord`命令。


#### 3）使用homebrew安装


除使用install.sh安装外，Mac用户还可使用homebrew来安装lor，该方式由[@syhily](https://github.com/syhily)提供， 更详尽的使用方法请参见[这里](https://github.com/syhily/homebrew-lor)。

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

之后访问[http://localhost:8888/](http://localhost:8888/)，即可。

更多使用方法，请参考[test](./test)测试用例。


### Homebrew

[https://github.com/syhily/homebrew-lor](https://github.com/syhily/homebrew-lor)由[@syhily](https://github.com/syhily)维护。


### 贡献者

- [@wanghaisheng](https://github.com/wanghaisheng)
- [@lihuibin](https://github.com/lihuibin)
- [@ms2008](https://github.com/ms2008)
- [@syhily](https://github.com/syhily)
- [@vinsonzou](https://github.com/vinsonzou)

### 讨论交流

目前有一个QQ群用于在线讨论: 522410959


### License

[MIT](./LICENSE)
