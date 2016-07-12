local tinsert = table.insert
local pairs = pairs
local ipairs = ipairs
local type = type
local setmetatable = setmetatable
local getmetatable = getmetatable

local utils = require("lor.lib.utils.utils")
local is_table_empty = utils.is_table_empty
local random = utils.random
local mixin = utils.mixin

local supported_http_methods = require("lor.lib.methods")
local Route = require("lor.lib.router.route")
local Layer = require("lor.lib.router.layer")
local debug = require("lor.lib.debug")


local function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_object = {}
        lookup_table[object] = new_object
        for key, value in pairs(object) do
            new_object[_copy(key)] = _copy(value)
        end
        return setmetatable(new_object, getmetatable(object))
    end
    return _copy(object)
end

local function layer_match(layer, path)
    local is_match = layer:match(path)
    debug("index.lua - is_match:", is_match, "path:", path, layer)
    return is_match
end

local function merge_params(params, parent)
    local obj = mixin({}, parent)
    local result =  mixin(obj, params)
    return result
end

local function restore(fn, obj)
    local origin = {
        path = obj['path'],
        query = obj['query'],
        next = obj['next'],
        locals = obj['locals'],
        -- params = obj['params']
    }

    return function(err)
        obj['path'] = origin.path
        obj['query'] = origin.query
        obj['next'] = origin.next
        obj['locals'] = origin.locals
        -- obj['params'] = origin.params -- maybe overrided by layer.params, so no need to keep
        fn(err)
    end
end


local Router = {}

function Router:new(options)
    local opts = options or {}
    local router = {}

    router.name =  "origin-router-" .. random()
    router.group_router = opts.group_router -- is a group router
    router.stack = {} -- layer array

    self:init()
    setmetatable(router, {
        __index = self,
        __call = self._call,
        __tostring = function(s)
            local ok, result = pcall(function()
                return "(name:" .. s.name .. "\tstack_length:" .. #s.stack .. ")"
            end)
            if ok then
                return result
            else
                return "router.tostring() error"
            end
        end
    })

    debug("router.lua#new:", router)
    return router
end



-- a magick for usage like `lor:Router()`, generate a new router for different routes group
function Router:_call()
    local new_router =  clone(self)
    new_router.name = self.name .. ":group-router-" .. random()
    return new_router
end

-- a magick to convert `router()` to `router:handle()`
-- so a router() could be regarded as a `middleware`
function Router:call()
    return function(req, res, next)
        return self:handle(req, res, next)
    end
end

-- dispatch a request
function Router:handle(req, res, out)
    debug("index.lua#handle")
    local idx = 1
    local stack = self.stack
    local done = restore(out, req)

    local function next(err)
        local layer_error = err
        debug("\nindex.lua#next..., layer_error:", layer_error, "stack_len:", #stack, "idx:", idx)

        if idx > #stack then
            done(layer_error)
            return
        end

        local path = req.path
        if not path then
            done(layer_error)
            return
        end

        -- to find the next matched layer
        local layer, match, route
        while (not match and idx <= #stack)
        do
            layer = stack[idx]
            idx = idx + 1

            match = layer_match(layer, path)
            route = layer.route

            -- lua has no `continue` keyword, such a pain
            if not match then
                -- to continue
            else
                if not route then
                    -- to continue
                else
                    if layer_error then
                        match = false
                        -- to continue
                    else

                        local method = req.method
                        local has_method = route:_handles_method(method)
                        if not has_method then
                            match = false
                            -- to continue
                        end
                    end
                end
            end
        end

        if not match then
            -- debug("no match")
            done(layer_error)
            return
        end

        -- store route
        if route then
            req.route = route
            req:set_found(true) -- to indicate that this req is not a 404 request.
        end

        if match then
            debug("match and merge_params")
            local merged_params = merge_params(layer.params, req.params)
            if merged_params and ( not is_table_empty(merged_params)) then
                req.params = merged_params
            end
        end


        if route then
            debug("[1]index.lua#next has route->handle_request", "layer.name", layer.name, "match:", match, idx)
            layer:handle_request(req, res, next)
        end

        if layer_error then
            debug("[2]index.lua#next no route and layer_error->handle_error", "layer.name", layer.name, "layer.length", layer.length,"match:", match, idx)
            layer:handle_error(layer_error, req, res, next)
        elseif route then
            debug("[3]index.lua#next hasroute and not layer_error->next()", "layer.name", layer.name, "layer.length", layer.length,"match:", match, idx)
            next()
        else
            debug("[4]index.lua#next no route->handle_request", "layer.name", layer.name, "layer.length", layer.length,"match:", match, idx)
            layer:handle_request(req, res, next)
        end
    end
    -- end of next function

    -- setup next layer
    req.next = next

    -- debug("index.lua#next", next)
    next()
end

function Router:use(path, fn, fn_args_length)
    local layer
    if type(fn) == "function" then -- fn is a function
        layer = Layer:new(path, {
            is_end = false,
            is_start = true
        }, fn, fn_args_length)
    else -- fn is a group router
        layer = Layer:new(path, {
            is_end = false,
            is_start = true
        }, fn.call(fn), fn_args_length)

        local group_router_stack = fn.stack
        if group_router_stack and not fn.is_repatterned then
            fn.is_repatterned = true -- fixbug: fn.is_repatternd to remember, avoid 404 error when "lua_code_cache on"
            for i, v in ipairs(group_router_stack) do
                v.pattern = utils.clear_slash("^/" .. path .. v.pattern)
            end
        end

        debug("router.lua#use-inner now the group router(" .. fn.name .. ") stack is:")
        debug(function()
            for i, v in ipairs(fn.stack) do
                print(i, v)
            end
        end)
        debug("router.lua#use-inner now the group router(" .. fn.name .. ") stack is------\n")
    end

    tinsert(self.stack, layer)

    debug("router.lua#use now the router(" .. self.name .. ") stack is:")
    debug(function()
        for i, v in ipairs(self.stack) do
            print(i, v)
        end
    end)
    debug("router.lua#use now the router(" .. self.name .. ") stack is------\n")

    return self
end

-- invoked by app:route, add ^ before pattern
-- add an empty route pointing to next layer
function Router:app_route(path)
    local route = Route:new(path)
    local layer = Layer:new(path, {
        is_end = true,
        is_start = true
    }, route, 3) -- important: a magick to supply route:dispatch
    layer.route = route

    tinsert(self.stack, layer)

    debug("router.lua#route now the router(" .. self.name .. ") stack is:")
    debug(function()
        for i, v in ipairs(self.stack) do
            print(i, v)
        end
    end)
    debug("router.lua#route now the router(" .. self.name .. ") stack is++++++\n")

    return route
end

-- add an empty route pointing to next layer
function Router:route(path)
    local route = Route:new(path)
    local layer = Layer:new(path, {
        is_end = true,
        is_start = false
    }, route, 3)
    layer.route = route

    tinsert(self.stack, layer)

    debug("router.lua#route now the router(" .. self.name .. ") stack is:")
    debug(function()
        for i, v in ipairs(self.stack) do
            print(i, v)
        end
    end)
    debug("router.lua#route now the router(" .. self.name .. ") stack is++++++\n")

    return route
end

function Router:init()
    for http_method, _ in pairs(supported_http_methods) do
        self[http_method] = function(s, path, fn)
            local route = s:route(path)
            -- 参数应该明确指定为route，不得省略，否则group_router.test.lua使用lor:Router()语法时无法传递route
            route[http_method](route, fn)
            return s
        end
    end
end


return Router