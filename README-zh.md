# Lor

[![https://travis-ci.org/sumory/lor.svg?branch=master](https://travis-ci.org/sumory/lor.svg?branch=master)](https://travis-ci.org/sumory/lor)

**Lor**是一个运行在[OpenResty](http://openresty.org)上的基于Lua编写的Web框架. 

- 路由采用[Sinatra](http://www.sinatrarb.com/)风格，Sinatra是Ruby小而精的web框架.
- API基本采用了[Express](http://expressjs.com)的思路和设计，Node.js跨界开发者可以很快上手.
- 支持插件(middleware)，路由可分组，路由匹配支持string/正则模式.
- lor以后会保持核心足够精简，扩展功能依赖`middleware`来实现. `lor`本身也是基于`middleware`来实现的.
- 框架文档在[这里](http://lor.sumory.com)
- 推荐使用lor作为HTTP API Server，此外也会支持模板渲染/Session/Cookie等常规web功能.

## 快速开始

在使用lor之前请首先确保OpenResty和luajit已安装.

一个简单实例：

```lua
local lor = require("lor.index")
local app = lor()

-- 插件: 对以`/user`开始的请求做过滤处理
app:use("/user", function(req, res, next)
    req.params.inject = 'inject value'
    next()
end)

-- 按id查找用户
app:get("/user/query/:id", function(req, res, next)
    local query_id = req.params.id -- 从req.params取参数
    -- 处理...
    next() -- 交给下一个调用者
end)

app:post("/user/:id/create", function(req, res, next)
    -- 创建一个用户
end)

-- 404 not found插件，不能被匹配的路由会在这里处理
app:use(function(req, res, next)
    -- res.status(404).send()
end)

-- 错误处理插件，可根据需要定义多个
app:erroruse(function(err, req, res, next)
    -- err是错误对象
    res.status(500).send("服务器内发生未知错误")
end)
```

#### 安装


##### 手动安装

```bash
git clone https://github.com/sumory/lor
#然后将${Your-lor-path}/lor加入到package.path，就可以调用`快速开始`实例中的代码
```
##### luarocks

待续.



## License

[MIT](./LICENSE)