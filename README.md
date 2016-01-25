# Lor

[![https://travis-ci.org/sumory/lor.svg?branch=master](https://travis-ci.org/sumory/lor.svg?branch=master)](https://travis-ci.org/sumory/lor)

**Lor**是一个运行在[OpenResty](http://openresty.org)上的基于Lua编写的Web框架. 

- 路由采用[Sinatra](http://www.sinatrarb.com/)风格，Sinatra是Ruby小而精的web框架.
- API基本采用了[Express](http://expressjs.com)的思路和设计，Node.js跨界开发者可以很快上手.
- 支持插件(middleware)，路由可分组，路由匹配支持string/正则模式.
- lor以后会保持核心足够精简，扩展功能依赖`middleware`来实现. `lor`本身也是基于`middleware`构建的.
- 推荐使用lor作为HTTP API Server，lor也已支持session/cookie/html template等功能.
- 框架文档在[这里](http://lor.sumory.com)，正在逐步完善.

当前版本：v0.0.4，下一版本v0.0.5计划：

- 完善文档，补充用例


### 快速开始

在使用lor之前请首先确保OpenResty和luajit已安装.

一个简单示例，更复杂的示例或项目模板请使用`lord`命令生成：

```
local lor = require("lor.index")
local app = lor()

app:get("/", function(req, res, next)
    res:send("hello world!")
end)

-- 路由示例: 匹配/query/123?foo=bar
app:get("/query/:id", function(req, res, next)
    local foo = req.query.foo -- 从url queryString取值："bar"
    local path_id = req.params.id -- 从path取值："123"
    res:json({
        foo = foo,
        id = path_id
    })
end)

-- 404 error
app:use(function(req, res, next)
    if req:isFound() ~= true then
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


使用install.sh安装lor框架

```
#如把lor安装到/opt/lua/lor目录下
sh install.sh /opt/lua/lor 
```

执行以上命令后lor的命令行工具`lord`就被安装在了`/usr/local/bin`下, 通过`which lord`查看:

```
$ which lord
/usr/local/bin/lord
```

`lor`的运行时包安装在了`/opt/lua/lor`下, 通过`ll /opt/lua/lor`查看:

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
-rw-r--r--   1 root  wheel   1.6K  1 19 23:48 install.md
-rw-r--r--   1 root  wheel   1.0K  1 21 22:37 install.sh
drwxr-xr-x   4 root  wheel   136B  1 21 22:40 lor
drwxr-xr-x  13 root  wheel   442B  1 22 01:17 test
```

至此， `lor`框架已经安装完毕，接下来使用`lord`命令行工具快速开始一个项目.




### 使用

```
$ lord -h
lor v0.0.4, a Lua web framework based on OpenResty.

Usage: lor COMMAND [OPTIONS]

Commands:
 new [name]             Create a new application
 start                  Starts the server
 stop                   Stops the server
 restart                Restart the server
 version                Show version of lor
 help                   Show help tips

Options:
 --debug                Show some runtime details
```

执行`lord new lor_demo`，则会生成一个名为lor_demo的示例项目，然后执行：

```
cd lor_demo
lord start
```

之后访问http://localhost:8888/，即可。

更多使用方法，请参考[test](./test)测试用例。


### 讨论交流

目前有一个QQ群用于在线讨论：[![QQ群522410959](http://pub.idqqimg.com/wpa/images/group.png)](http://shang.qq.com/wpa/qunwpa?idkey=b930a7ba4ac2ecac927cb51101ff26de1170c0d0a31c554b5383e9e8de004834) 522410959


### License

[MIT](./LICENSE)