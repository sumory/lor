local pairs = pairs
local pcall = pcall
local require = require
local setmetatable = setmetatable

local Utils = require 'lor.lib.utils'
local Dispatcher = require 'lor.framework.dispatcher'


local Application = {}

function Application:lpcall( ... )
    local ok, rs_or_error = pcall( ... )
    if ok then
        return rs_or_error
    else
        self:raise_syserror(rs_or_error)
    end
end

function Application:new(config)
    if config.name == nil or config.app.root == nil then
        self:raise_syserror([[
        app name and app root should be set in config/application.lua like:
        
            Appconf.name = 'lor_demo'
            Appconf.app.root='./'
        ]])
    end

    self.config = config
    local instance = {
        dispatcher = Dispatcher:new(self)
    }
    setmetatable(instance, {__index = self})
    return instance
end

function Application:routes(routes)
    self.dispatcher:setRoutes(routes)
    return self
end

function Application:run()
    self:lpcall(self.dispatcher.exec, self.dispatcher)
end

function Application:raise_syserror(err)
    if type(err) == 'table' then
        ngx.status = err.status
    else
        ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    end

    ngx.say(Utils.format_var(err))
    ngx.eof()
end

return Application