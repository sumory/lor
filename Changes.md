### v0.3.4 2017.08.30

- 修复默认session插件的`session_aes_secret`长度问题
    - 此问题存在于OpenResty v1.11.2.5版本及可能之后的版本中
    - lua-resty-string v0.10开始AES salt必须是[8个字符](https://github.com/openresty/lua-resty-string/commit/69df3dcc2230364a54761a0d5a65327c6a4e256a)
- 使用内置的session插件时`session_aes_secret`不再是必须配置
    - 若不填则默认为`12345678`
    - 若不足8个字符则以`0`补足
    - 若超过8个字符则只使用前8个

### v0.3.3 2017.08.05

- 使用严格的路由节点id策略,避免潜在冲突


### v0.3.2 2017.06.10

- 关于内置session插件的更改
    - 修复session过期时间bug
    - 移除lua-resty-session依赖
    - 内置session插件替换为基于cookie的简单实现
    - 接口仍然保持与之前版本兼容
    - 关于session处理，仍然建议根据具体业务需求和安全考量自行实现
- 支持URI中含有字符'-'

### v0.3.1 2017.04.16

- 支持路由中包含`~`字符（from [@XadillaX](https://github.com/XadillaX))
- 支持组路由(group router)的多级路由写法
- 支持组路由下直接挂载中间件(see [issues#40](https://github.com/sumory/lor/issues/40))

### v0.3.0 2017.02.11

此版本为性能优化和内部实现重构版本，API使用上保持与之前版本兼容，详细描述如下：

**特性**

- 中间件（middlewares）重构，支持任意级别、多种方式挂载中间件，这些中间件包括
    - 预处理中间件(use)
    - 错误处理中间件(erroruse)
    - 业务处理中间件(get/post/put/delete...)
- 提高路由性能
    - 路由匹配次数不再随路由数增多而正比例增长
    - 全面支持正则路由和通配符路由
- use、get/put/delete/post等API优化，如支持数组参数、支持单独挂载中间件等改进
- 路由匹配更加灵活: 优先匹配精确路由，其次再匹配正则路由或通配符路由

**Break Changes**

与之前版本相比，break changes主要有以下几点(基本都是一些比较少用到的特性)

- 路由执行顺序不再与路由定义顺序相关， 如错误路由不用必须定义在最下方
- 如果一个请求最终匹配不到已定义的任何路由，则不会执行任何中间件代码（之前的版本会执行，这浪费了一些性能）


### v0.2.6 2016.11.26

- 升级内部集成的session中间件
    - lua-resty-session升级到2.13版本
    - 添加一个session过期参数timeout,默认为3600秒
    - 添加一个refresh_cookie参数，用于控制否在有新请求时刷新session和cookie过期时间，默认“是”
- 更新`lord new`项目模板
    - 缓存`app`对象，提高性能
    - 调整CRUD示例, 详细请参看脚手架代码中的app/routes/user.lua
- 删除默认响应头X-Powered-By

### v0.2.4 2016.11.16

- 支持"application/json"类型请求


### v0.2.2 2016.10.15

- 支持opm， 可通过`opm install sumory/lor`安装
    - 注意opm暂不支持命令安装， 所以这种方式无法安装`lord`命令
- 若仍想使用`lord`命令，建议使用`sh install.sh`方式安装

### v0.1.6 2016.10.14

- `lord`工具改为使用resty-cli实现，不再依赖luajit

### v0.1.5 2016.10.01

- Path URI支持"."
- 使用xpcall替换pcall以记录更多出错日志
- 更新了测试用例

### v0.1.4 2016.07.30

- 删除一些无用代码和引用
- 升级测试依赖库
- 修改文档和注释
- 修改一些小bug

### v0.1.0 2016.03.15

- 增加一配置项，是否启用模板功能：app:conf("view enable", true), 默认为关闭
- view.lua中ngx.var.template_root存在性判断
- 增加docker支持
- 命令`lord --path`变更为`lord path`，用于查看当前lor的安装路径
- 官网文档更新[http://lor.sumory.com](http://lor.sumory.com)

### v0.0.9 2016.03.02

- 使用install.sh安装lor时如果有指定安装目录，则在指定的目录后面拼上"lor"，避免文件误删的问题
- TODO: debug时列出整个路由表供参考

### v0.0.8 2016.02.26

- 支持multipart/form文件上传
- 修复了一个group router被多次app:use时出现404的bug
- 支持Response:json(data, flag)方法传入第二个bool类型参数flag，指明序列化json时默认的空table是否编码为{}
    - true 作为{}处理
    - false 作为[]处理
    - 不传入第二个参数则当作[]处理


### v0.0.7 2016.02.02

- 统一代码风格
- 优化部分代码，比如使用ngx.re代替string对应方法、尽量使用local等
- Break API: req:isFound() -> req:is_found()
- Fix bug: 修复了在lua_code_cache on时的一些404问题


### v0.0.6 2016.01.30

- 修改了lor的默认安装路径到/usr/local/lor
- 命令行工具`lord`生成的项目模板更改
    - 加入了nginx.conf配置，方便之后维护自定义的nginx配置
    - 加入start/stop/restart脚本，方便之后项目的灵活部署
- 改善了路由pattern，支持path variable含有"-"字符
- 增加了几个测试用例
- 修复了上一个请求的path variable会污染之后请求的bug
- 完善了res:redirect API
- 修复了请求体为空时解析的bug
- 给lor对象添加了版本号
- 添加了静态文件支持（通过在nginx.conf里配置）
- 编写了lor框架示例项目[lor-example](https://github.com/lorlabs/lor-example)


### v0.0.5 2016.01.28

- 完善了Documents和API文档，详见[lor官网](http://lor.sumory.com)
- `lor new`命令生成的项目模板增加了一个middleware目录，用于存放自定义插件
    - 该目录的命名和位置都是非强制的，用户可按需要将自定义的插件放在任何地方
- 修改了lor new产生的项目模板，增加了几个基本API的使用方式


### v0.0.4 2016.01.25

- 以默认插件的形式添加cookie支持(lua-resty-cookie)
- 以默认插件的形式添加session支持(lua-resty-session)


### v0.0.3 2016.01.23

- 修复上版本路由bug
- 添加模板支持（lua-resty-template）
- 完善了40余个常规测试用例
- 完善了命令行工具`lord`
- 常规API使用方法添加到默认项目模板


### v0.0.2 2016.01.21

- 完全重构v0.0.1路由
- Sinatra风格路由
- 主要API设计完成并实现


### v0.0.1 2016.01.15

- 原型设计和实验
