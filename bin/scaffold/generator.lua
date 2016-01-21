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
<a href="https://github.com/sumory/lor" class="name">{{name}}</a>
<span class="description">{{desc}}</span>
</div>
</body>
</html>
]]



local main_tpl = [[
local lor = require("lor.index")
local router = require("app.router")
local app = lor()

app:use(function(req, res, next)
    -- 插件，在处理业务route之前的插件，可作编码解析、过滤等操作
    next()
end)


router(app) -- 业务路由处理


-- 404 error
app:use(function(req, res, next)
    if req:isFound() ~= true then
        res:status(404):send("sorry, not found.")
    end
end)


-- 错误处理插件，可根据需要定义多个
app:erroruse(function(err, req, res, next)
    -- err是错误对象
    res:status(500):send(err)
end)

app:run() -- 启动lor

]]


local router_tpl = [[
-- 业务路由管理
local userRouter = require("app.routes.user")
local testRouter = require("app.routes.test")


return function(app)

    -- group router, 对以`/user`开始的请求做过滤处理
    app:use("/user", userRouter())

    -- group router, 对以`/test`开始的请求做过滤处理
    app:use("/test", testRouter())

    -- 除使用group router外，也可单独进行路由处理，支持get/post/put/delete...
    app:get("/book/:id/view", function(req, res, next)
        res:send("view book" .. req.params.id)
    end)

end
]]


local user_router_tpl = [[
local lor = require("lor.index")
local userRouter = lor:Router() -- 生成一个router对象


-- 按id查找用户
userRouter:get("/query/:id", function(req, res, next)
    local query_id = req.params.id -- 从req.params取参数
    res:json({
        id = query_id,
        desc = "this if from user router"
    })
end)

-- 删除用户
userRouter:post("/delete/:id", function(req, res, next)
    local id = req.params.id
    res:json({
        id = id,
        desc = "delete user " .. id
    })
end)


return userRouter

]]

local test_router_tpl = [[
local lor = require("lor.index")
local testRouter = lor:Router() -- 生成一个router对象


-- 按id查找用户
testRouter:get("/hello", function(req, res, next)
    res:send("hello world!")
end)

return testRouter
]]


local Generator = {}

Generator.files = {
    ['.gitignore'] = gitignore,
    ['app/main.lua'] = main_tpl,
    ['app/router.lua'] = router_tpl,
    ['app/routes/user.lua'] = user_router_tpl,
    ['app/routes/test.lua'] = test_router_tpl,
    ['app/views/index.html'] = index_view_tpl
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




