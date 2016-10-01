### v0.2.0 

- 支持opm

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
