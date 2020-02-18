local sgmatch = string.gmatch
local utils = require 'bin.scaffold.utils'

local gitignore = [[
# lor
client_body_temp
fastcgi_temp
logs
proxy_temp
tmp
uwsgi_temp

# Compiled Lua sources
luac.out

# luarocks build files
*.src.rock
*.zip
*.tar.gz

# Object files
*.o
*.os
*.ko
*.obj
*.elf

# Precompiled Headers
*.gch
*.pch

# Libraries
*.lib
*.a
*.la
*.lo
*.def
*.exp

# Shared objects (inc. Windows DLLs)
*.dll
*.so
*.so.*
*.dylib

# Executables
*.exe
*.out
*.app
*.i*86
*.x86_64
*.hex
]]

local mime_types = [[
types {
    text/html                             html htm shtml;
    text/css                              css;
    text/xml                              xml;
    image/gif                             gif;
    image/jpeg                            jpeg jpg;
    application/javascript                js;
    application/atom+xml                  atom;
    application/rss+xml                   rss;

    text/mathml                           mml;
    text/plain                            txt;
    text/vnd.sun.j2me.app-descriptor      jad;
    text/vnd.wap.wml                      wml;
    text/x-component                      htc;

    image/png                             png;
    image/tiff                            tif tiff;
    image/vnd.wap.wbmp                    wbmp;
    image/x-icon                          ico;
    image/x-jng                           jng;
    image/x-ms-bmp                        bmp;
    image/svg+xml                         svg svgz;
    image/webp                            webp;

    application/font-woff                 woff;
    application/java-archive              jar war ear;
    application/json                      json;
    application/mac-binhex40              hqx;
    application/msword                    doc;
    application/pdf                       pdf;
    application/postscript                ps eps ai;
    application/rtf                       rtf;
    application/vnd.apple.mpegurl         m3u8;
    application/vnd.ms-excel              xls;
    application/vnd.ms-fontobject         eot;
    application/vnd.ms-powerpoint         ppt;
    application/vnd.wap.wmlc              wmlc;
    application/vnd.google-earth.kml+xml  kml;
    application/vnd.google-earth.kmz      kmz;
    application/x-7z-compressed           7z;
    application/x-cocoa                   cco;
    application/x-java-archive-diff       jardiff;
    application/x-java-jnlp-file          jnlp;
    application/x-makeself                run;
    application/x-perl                    pl pm;
    application/x-pilot                   prc pdb;
    application/x-rar-compressed          rar;
    application/x-redhat-package-manager  rpm;
    application/x-sea                     sea;
    application/x-shockwave-flash         swf;
    application/x-stuffit                 sit;
    application/x-tcl                     tcl tk;
    application/x-x509-ca-cert            der pem crt;
    application/x-xpinstall               xpi;
    application/xhtml+xml                 xhtml;
    application/xspf+xml                  xspf;
    application/zip                       zip;

    application/octet-stream              bin exe dll;
    application/octet-stream              deb;
    application/octet-stream              dmg;
    application/octet-stream              iso img;
    application/octet-stream              msi msp msm;

    application/vnd.openxmlformats-officedocument.wordprocessingml.document    docx;
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet          xlsx;
    application/vnd.openxmlformats-officedocument.presentationml.presentation  pptx;

    audio/midi                            mid midi kar;
    audio/mpeg                            mp3;
    audio/ogg                             ogg;
    audio/x-m4a                           m4a;
    audio/x-realaudio                     ra;

    video/3gpp                            3gpp 3gp;
    video/mp2t                            ts;
    video/mp4                             mp4;
    video/mpeg                            mpeg mpg;
    video/quicktime                       mov;
    video/webm                            webm;
    video/x-flv                           flv;
    video/x-m4v                           m4v;
    video/x-mng                           mng;
    video/x-ms-asf                        asx asf;
    video/x-ms-wmv                        wmv;
    video/x-msvideo                       avi;
}
]]


local index_view_tpl = [[
<!DOCTYPE html>
<html>
<style>
body {
    font: 400 14px/1.6 "Open Sans",sans-serif;
    color: #555;
}

.lor {
    margin: 100px auto;
    width: 800px;
}

.name {
    display: block;
    font: 100 4.5em "Helvetica Neue","Open Sans",sans-serif;
    margin-bottom: 0.25em;
}

a {
    color: #259DFF;
    text-decoration: none;
}

.description {
  position: relative;
  top: -5px;
  font: 100 3em "Helvetica Neue","Open Sans",sans-serif;
  color: #AEAEAE;
}
</style>
<body>

<div class="lor">
<a href="#" class="name">
{{name}}
{% if locals.app_version then %}
    <span class="version">{{locals.app_version}}</span>
{% end %}
</a>
<span class="description">{{desc}}</span>

</div>
</body>
</html>
]]

local user_info_view_tpl = [[
<!DOCTYPE html>
<html>
<style>
body {
    font: 400 14px/1.6 "Open Sans",sans-serif;
    color: #555;
}

.lor {
    margin: 100px auto;
    width: 800px;
}

.desc {
  position: relative;
  bottom: 15px;
  font: 100 3em "Helvetica Neue","Open Sans",sans-serif;
  color: #AEAEAE;
}

.id {
    display: block;
    font: 100 3em "Helvetica Neue","Open Sans", sans-serif;
}

.name {
    display: block;
    font: 100 3em "Helvetica Neue","Open Sans", sans-serif;
    margin-bottom: 0.25em;
}

</style>
<body>

<div class="lor">
  <span class="desc">{{desc}}</span><br>
  <span class="id">{{id}}</span>
  <span class="name">{{name}}</span>
</div>
</body>
</html>
]]

local main_tpl = [[
local app = require("app.server")
app:run()
]]

local server_tpl = [[
local string_find = string.find
local lor = require("lor.index")
local router = require("app.router")
local app = lor()

-- 模板配置
app:conf("view enable", true)
app:conf("view engine", "tmpl")
app:conf("view ext", "html")
app:conf("view layout", "")
app:conf("views", "./app/views")

-- session和cookie支持，如果不需要可注释以下配置
local mw_cookie = require("lor.lib.middleware.cookie")
local mw_session = require("lor.lib.middleware.session")
app:use(mw_cookie())
app:use(mw_session({
    session_key = "__app__", -- the key injected in cookie
    session_aes_key = "aes_key_for_session", -- should set by yourself
    timeout = 3600 -- default session timeout is 3600 seconds
}))

-- 自定义中间件1: 注入一些全局变量供模板渲染使用
local mw_inject_version = require("app.middleware.inject_app_info")
app:use(mw_inject_version())

-- 自定义中间件2: 设置响应头
app:use(function(req, res, next)
    res:set_header("X-Powered-By", "Lor framework")
    next()
end)

router(app) -- 业务路由处理

-- 错误处理插件，可根据需要定义多个
app:erroruse(function(err, req, res, next)
    ngx.log(ngx.ERR, err)

    if req:is_found() ~= true then
        if string_find(req.headers["Accept"], "application/json") then
            res:status(404):json({
                success = false,
                msg = "404! sorry, not found."
            })
        else
            res:status(404):send("404! sorry, not found. " .. (req.path or ""))
        end
    else
        if string_find(req.headers["Accept"], "application/json") then
            res:status(500):json({
                success = false,
                msg = "500! internal error, please check the log."
            })
        else
            res:status(500):send("internal error, please check the log.")
        end
    end
end)

return app
]]


local router_tpl = [[
-- 业务路由管理
local userRouter = require("app.routes.user")

return function(app)

    -- simple router: hello world!
    app:get("/hello", function(req, res, next)
        res:send("hi! welcome to lor framework.")
    end)

    -- simple router: render html, visit "/" or "/?name=foo&desc=bar
    app:get("/", function(req, res, next)
        local data = {
            name =  req.query.name or "lor",
            desc =  req.query.desc or 'a framework of lua based on OpenResty'
        }
        res:render("index", data)
    end)

    -- group router: 对以`/user`开始的请求做过滤处理
    app:use("/user", userRouter())
end

]]


local user_router_tpl = [[
local lor = require("lor.index")
local userRouter = lor:Router() -- 生成一个group router对象

-- 按id查找用户
-- e.g. /query/123
userRouter:get("/query/:id", function(req, res, next)
    local query_id = tonumber(req.params.id) -- 从req.params取参数

    if not query_id then
        return res:render("user/info", {
            desc = "Error to find user, path variable `id` should be a number. e.g. /user/query/123"
        })
    end

    -- 渲染页面
    res:render("user/info", {
        id = query_id,
        name = "user" .. query_id,
        desc = "User Information"
    })
end)

-- 删除用户
-- e.g. /delete?id=123
userRouter:delete("/delete", function(req, res, next)
    local id = req.query.id -- 从req.query取参数
    if not id then
        return res:html("<h2 style='color:red'>Error: query param id is required.</h2>")
    end

    -- 返回html
    res:html("<span>succeed to delete user</span><br/>user id is:<b style='color:red'>" .. id .. "</b>")
end)

-- 修改用户
-- e.g. /put/123?name=sumory
userRouter:put("/put/:id", function(req, res, next)
    local id = req.params.id  -- 从req.params取参数
    local name = req.query.name -- 从req.query取参数

    if not id or not name then
        return res:send("error params: id and name are required.")
    end

    -- 返回文本格式的响应结果
    res:send("succeed to modify user[" .. id .. "] with new name:" .. name)
end)

-- 创建用户
userRouter:post("/post", function(req, res, next)
    local content_type = req.headers['Content-Type']

    -- 如果请求类型为form表单或json请求体
    if string.find(content_type, "application/x-www-form-urlencoded",1, true) or
        string.find(content_type, "application/json",1, true) then
        local id = req.body.id -- 从请求体取参数
        local name = req.body.name -- 从请求体取参数

        if not id or not name then
            return res:json({
                success = false,
                msg = "error params: id and name are required."
            })
        end

        res:json({-- 返回json格式的响应体
            success = true,
            data = {
                id = id,
                name = name,
                desc = "succeed to create new user" .. id
            }
        })
    else -- 不支持其他请求体
        res:status(500):send("not supported request Content-Type[" .. content_type .. "]")
    end
end)

return userRouter
]]


local middleware_tpl = [[

### 自定义插件目录(define your own middleware)


You are recommended to define your own middlewares and keep them in one place to manage.

建议用户将自定义插件存放在此目录下统一管理，然后在其他地方引用，插件的格式如下:

```
local middleware =  function(params)
    return function(req, res, next)
        -- do something with req/res
        next()
    end
end

return middleware
```

]]


local middleware_example_tpl = [[
--- 中间件示例： 为每个请求注入一些通用的变量
local lor = require("lor.index")
return function()
    return function(req, res, next)
        -- res.locals是一个table, 可以在这里注入一些“全局”变量
        -- 这个示例里注入app的名称和版本号， 在渲染页面时即可使用
        res.locals.app_name = "lor application"
        res.locals.app_version = lor.version or ""
        next()
    end
end
]]


local static_tpl = [[

### 静态文件目录(static files directory)

nginx对应配置为

```
location /static {
    alias app/static;
}
```

]]

local ngx_conf_directory = [[

### nginx configuration directory

]]


local ngx_config = require 'bin.scaffold.nginx.config'
local ngx_conf_template = require 'bin.scaffold.nginx.conf_template'
local function nginx_conf_content()
    -- read nginx.conf file
    local nginx_conf_template =  ngx_conf_template.get_ngx_conf_template()

    -- append notice
    nginx_conf_template = [[# generated by `lor framework`]] .. nginx_conf_template

    local match = {}
    local tmp = 1
    for v in sgmatch(nginx_conf_template , '{{(.-)}}') do
        match[tmp] = v
        tmp = tmp + 1
    end

    for _, directive in ipairs(match) do
        if ngx_config[directive] ~= nil then
            nginx_conf_template = string.gsub(nginx_conf_template, '{{' .. directive .. '}}', ngx_config[directive])
        else
            nginx_conf_template = string.gsub(nginx_conf_template, '{{' .. directive .. '}}', '#' .. directive)
        end
    end

    return nginx_conf_template
end
local ngx_conf_tpl = nginx_conf_content()


local start_sh = [[
#!/bin/sh

#####################################################################
# usage:
# sh start.sh -- start application @dev
# sh start.sh ${env} -- start application @${env}

# examples:
# sh start.sh prod -- use conf/nginx-prod.conf to start OpenResty
# sh start.sh -- use conf/nginx-dev.conf to start OpenResty
#####################################################################

if [ -n "$1" ];then
    PROFILE="$1"
else
    PROFILE=dev
fi

mkdir -p logs & mkdir -p tmp
echo "start lor application with profile: "${PROFILE}
nginx -p `pwd`/ -c conf/nginx-${PROFILE}.conf
]]


local stop_sh = [[
#!/bin/sh

#####################################################################
# usage:
# sh stop.sh -- stop application @dev
# sh stop.sh ${env} -- stop application @${env}

# examples:
# sh stop.sh prod -- use conf/nginx-prod.conf to stop OpenResty
# sh stop.sh -- use conf/nginx-dev.conf to stop OpenResty
#####################################################################

if [ -n "$1" ];then
    PROFILE="$1"
else
    PROFILE=dev
fi

mkdir -p logs & mkdir -p tmp
echo "stop lor application with profile: "${PROFILE}
nginx -s stop -p `pwd`/ -c conf/nginx-${PROFILE}.conf
]]

local reload_sh = [[
#!/bin/sh

#####################################################################
# usage:
# sh reload.sh -- reload application @dev
# sh reload.sh ${env} -- reload application @${env}

# examples:
# sh reload.sh prod -- use conf/nginx-prod.conf to reload OpenResty
# sh reload.sh -- use conf/nginx-dev.conf to reload OpenResty
#####################################################################

if [ -n "$1" ];then
    PROFILE="$1"
else
    PROFILE=dev
fi

mkdir -p logs & mkdir -p tmp
echo "reload lor application with profile: "${PROFILE}
kill -HUP $(cat `pwd`/${PROFILE}-nginx.pid)
]]


local Generator = {}

Generator.files = {
    ['.gitignore'] = gitignore,
    ['app/main.lua'] = main_tpl,
    ['app/server.lua'] = server_tpl,
    ['app/router.lua'] = router_tpl,
    ['app/routes/user.lua'] = user_router_tpl,
    ['app/views/index.html'] = index_view_tpl,
    ['app/views/user/info.html'] = user_info_view_tpl,
    ['app/middleware/README.md'] = middleware_tpl,
    ['app/middleware/inject_app_info.lua'] = middleware_example_tpl,
    ['app/static/README.md'] = static_tpl, -- static files directory,e.g. js/css/img
    ['conf/README.md'] = ngx_conf_directory, -- nginx config directory
    ['conf/nginx-dev.conf'] = ngx_conf_tpl, -- nginx config file
    ['conf/mime.types'] = mime_types, -- nginx mime
    ['start.sh'] = start_sh,
    ['stop.sh'] = stop_sh,
    ['reload.sh'] = reload_sh
}

function Generator.new(name)
    print('Creating app: ' .. name .. '...')
    Generator.create_files(name)
end

function Generator.create_files(parent)
    for file_path, file_content in pairs(Generator.files) do

        local full_file_path = parent .. '/' .. file_path
        local full_file_dirname = utils.dirname(full_file_path)
        os.execute('mkdir -p ' .. full_file_dirname .. ' > /dev/null')

        local fw = io.open(full_file_path, 'w')
        fw:write(file_content)
        fw:close()
        print('  created file ' .. full_file_path)
    end
end

return Generator
