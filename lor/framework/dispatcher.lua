local error = error
local pairs = pairs
local pcall = pcall
local setmetatable = setmetatable
local slower = string.lower
local smatch = string.match
local gmatch = string.gmatch
local function tappend(t, v) t[#t+1] = v end

local Routes = require 'lor.framework.routes'
local Request = require 'lor.framework.request'
local Response = require 'lor.framework.response'
local View = require 'lor.framework.view'
local utils = require 'lor.lib.utils'

local function new_view(view_conf)
    return View:new(view_conf)
end

local function require_controller(controller_prefix, controller_name)
    return require(controller_prefix .. controller_name)
end

local Dispatcher = {}

function Dispatcher:new(application)
    local instance = {
        application = application,
        routes = nil,
        request = Request:new(),
        response = Response:new(),
        controller_prefix = 'controllers.', -- todo: make this configurable
    }
    
    setmetatable(instance, {__index = self})
    return instance
end

function Dispatcher:setRoutes(routes)
    routes = routes or Routes:new()
    self.routes = routes
end


-- 调用执行链
function Dispatcher:exec()
    self.response.view =  self:lpcall(new_view, self.application.config.view) -- 生成 config/application.lua#config
     -- get routes
    local ok, invoke, params = pcall(function() return self:match() end)
           
    if ok == false then
        self:errResponse(500, invoke)
    elseif invoke then
        self:call_controller(invoke, params)
    else
        self.response:response(ngx.HTTP_NOT_FOUND, 'no route.')
    end
end

function Dispatcher:lpcall( ... )
    local ok, result = pcall( ... )
    if ok then
        return result
    else
        self:errResponse(500, result)
    end
end

function Dispatcher:errResponse(code, err)
    self.response:response(code, self:raise_error(err))
end

function Dispatcher:raise_error(err)
    -- todo: to refactor
    return err
end

-- match request to routes
function Dispatcher:match()
    local request = self.request
    local uri = request.uri
    local method = slower(request.method)

    local routes_dispatchers = self.routes.routes
    if routes_dispatchers == nil then error({ code = 102 }) end

     --ngx.say(#routes_dispatchers)

    for i = 1, #routes_dispatchers do
        local dispatcher = routes_dispatchers[i]
        local route = dispatcher[method] -- item of Routes.routes
        local pattern = dispatcher.pattern
       

        if route then
            local match = { smatch(uri, pattern) }
            if #match > 0 then -- uri match some route
                local params = {}
                for j = 1, #match do
                    if route.params[j] then
                        params[route.params[j]] = match[j]
                    else
                        tappend(params, match[j])
                    end
                end

                return route.invoke, params
            end
        end
    end
end

-- call the controller
function Dispatcher:call_controller(invoke, params)

    local controller_name, action_name = '', ''
    for k, v in gmatch(invoke, "([A-Za-z0-9_]+):([A-Za-z0-9_]+)") do
        controller_name = k
        action_name = v
    end

    if controller_name == nil or controller_name == '' or action_name == nil or action_name == '' then
        self:errResponse(404, 'match no routes')
    end

    self.request.path.params = params
    self.request.controller_name = controller_name
    self.request.action_name = action_name
    local matched_controller = self:lpcall(require_controller, self.controller_prefix, controller_name) 
    self:lpcall(function() return matched_controller[action_name](matched_controller, self.request, self.response) end)
end

return Dispatcher