local lor_conf = require 'lor.scaffold.config'
local utils = require 'lor.lib.utils'

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


local index_controller = [[
local IndexController = {}


function IndexController:index(req, res)
    local data = {
        name = 'lor',
        desc = 'a framework of lua based on OpenResty'
    }
    res:render("index/index", data)
end

function IndexController:render(req, res)
    local data = {
        name = 'lor',
        desc = 'a framework of lua based on OpenResty'
    }
    res:render("index/index", data)
end

function IndexController:json(req, res)
    local j = {
        success = true,
        code = 200, 
        data = {
            name = "lor",
            language = 'lua',
            author = 'sumory.wu',
            extras = {
                1,2,3,4,5,4,3,2,1
            }
        }
    }

    res:json(j)
end

function IndexController:send(req, res)
    res:send('this is a message from controller.')
end

return IndexController
]]


local index_tpl = [[
<!DOCTYPE html>
<html>
<style>
body {
    font: 400 14px/1.6 "Open Sans",sans-serif;
    color: #555;
}
.name {
    display: block;
    font: 100 4.5em "Helvetica Neue","Open Sans",sans-serif;
    color: #353535;
    margin-bottom: 0.25em;
}
a {
    color: #259DFF;
    text-decoration: none;
}

.description {
    position: relative;
    top: -5px;
    font: 100 4.2em/0.75 "Helvetica Neue","Open Sans",sans-serif;
    color: #AEAEAE;
}
</style>
<body>


<a href="/" class="name">{{name}}</a>
<span class="description">{{desc}}</span>

</body>
</html>
]]


local error_controller = [[
local ErrorController = {}

function ErrorController:common_error(req, res)
    local data = {
        status = 'out of control',
        body = {
            errorCode = 500,
            msg = 'this is an error'
        }
    }
    res:render("error/common_err", data)
end

return ErrorController

]]


local error_tpl = [[
<!DOCTYPE html>
<html>
<body>
  <p>error page: {{status}}</p>
  {% for k, v in pairs(body) do %}
      {% if k == 'message' then %}
      <p>{{k}}  =>  {{v}}</p>
      {% else %}
      <p>{{k}}  :  {{v}}</p>
      {% end %}
  {% end %}
</body>
</html>

]]

local dao = [[
local TableDao = {}

function TableDao:set(key, value)
    self.__cache[key] = value
    return true
end

function TableDao:new()
    local instance = {
        set = self.set,
        __cache = {}
    }
    setmetatable(instance, TableDao)
    return instance
end

function TableDao:__index(key)
    local out = rawget(rawget(self, '__cache'), key)
    if out then return out else return false end
end
return TableDao
]]

local service = [[
local table_dao = require('application.models.dao.table'):new()
local UserService = {}

function UserService:get()
    table_dao:set('key1', 'value1')
    return table_dao.key1
end

return UserService
]]


local application_conf = [[
local Appconf={}
Appconf.name = '{{APP_NAME}}'

Appconf.route='lor.framework.routes.simple'
Appconf.bootstrap='application.bootstrap'
Appconf.app={}
Appconf.app.root='./'

Appconf.controller={}
Appconf.controller.path=Appconf.app.root .. 'application/controllers/'

Appconf.view={}
Appconf.view.path=Appconf.app.root .. 'application/views/'
Appconf.view.suffix='.html'
Appconf.view.auto_render=true

return Appconf
]]


local errors_conf = [[
local Errors = {}
return Errors
]]


local nginx_conf = [[
local ngx_conf = {}

ngx_conf.common = {
    INIT_BY_LUA_FILE = './application/nginx/init.lua',
    LUA_SHARED_DICT = 'nginx.sh_dict',
    -- LUA_PACKAGE_PATH = '',
    -- LUA_PACKAGE_CPATH = '',
    CONTENT_BY_LUA_FILE = './application/main.lua'
}

ngx_conf.env = {}
ngx_conf.env.dev = {
    LUA_CODE_CACHE = false,
    PORT = 8888
}

ngx_conf.env.test = {
    LUA_CODE_CACHE = true,
    PORT = 9999
}

ngx_conf.env.prod = {
    LUA_CODE_CACHE = true,
    PORT = 80
}

return ngx_conf
]]

local nginx_init_by_lua_tpl = [[

local function init_by_lua()
    -- init something...
end

init_by_lua()

]]


local nginx_share_dict_tpl = [[
local sh_dict_conf = {
    dict1 = '10m',
    dict2 = '2m'
}
return sh_dict_conf
]]

local lor_main = [[
local App = require('lor.framework.application')
local Routes = require('lor.framework.routes')
local config = require('config.application')

local app = App:new(config)
local routes = Routes:new()

routes:get('/', 'index:index')
routes:get('/json', 'index:json')
routes:get('/render', 'index:render')
routes:get('/send', 'index:send')
routes:get('/error', 'error:common_error')

app:routes(routes):run()

]]


local Generator = {}

Generator.files = {
    ['.gitignore'] = gitignore,

    ['application/main.lua'] = lor_main,

    ['application/controllers/index.lua'] = index_controller,
    ['application/controllers/error.lua'] = error_controller,

    ['application/library/.gitkeep'] = "",

    ['application/models/dao/table.lua'] = dao,
    ['application/models/service/user.lua'] = service,

    ['application/views/index/index.html'] = index_tpl,
    ['application/views/error/common_err.html'] = error_tpl,

    ['application/nginx/init.lua'] = nginx_init_by_lua_tpl,
    ['application/nginx/sh_dict.lua'] = nginx_share_dict_tpl,

    ['config/errors.lua'] = errors_conf,
    ['config/nginx.lua'] = nginx_conf,
}

function Generator.new(name)
    print('Creating app: ' .. name .. '...')
    
    Generator.files['config/application.lua'] = string.gsub(application_conf, '{{APP_NAME}}', name)
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




