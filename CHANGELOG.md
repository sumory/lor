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