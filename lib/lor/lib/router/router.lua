local pairs = pairs
local ipairs = ipairs
local type = type
local setmetatable = setmetatable
local getmetatable = getmetatable
local tinsert = table.insert
local string_format = string.format


local utils = require("lor.lib.utils.utils")
local is_table_empty = utils.is_table_empty
local random = utils.random
local mixin = utils.mixin

local supported_http_methods = require("lor.lib.methods")
local debug = require("lor.lib.debug")
local Trie = require("lor.lib.trie")

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

local function compose_func(matched, method)
    if not matched or type(pipeline) ~= "table" then
        return nil
    end

    local exact_node = matched.node
    local pipeline = matched.pipeline or {}
    if not exact_node or not pipeline then
        return nil
    end

    local stack = {}
    for i, p in ipairs(pipeline) do
        local middlewares = p.middlewares
        local handlers = p.handlers
        if middlewares then
            for _, middleware in ipairs(middlewares) do
                tinsert(stack, middleware)
            end
        end

        if p.id == exact_node.id and handlers and handlers[method] then
            for _, handler in ipairs(handlers[method]) do
                tinsert(stack, handler)
            end
        end
    end

    return stack
end

local Router = {}

function Router:new(options)
    local opts = options or {}
    local router = {}

    router.name =  "router-" .. random()
    router.group_router = opts.group_router -- is a group router
    router.trie = Trie:new({
        ignore_case = opts.ignore_case,
        tsr = opts.tsr
    })
    router.middleware_trie = Trie:new({
        ignore_case = opts.ignore_case,
        tsr = opts.tsr
    })

    self:init()
    setmetatable(router, {
        __index = self,
        __call = self._call,
        __tostring = function(s)
            local ok, result = pcall(function()
                return string_format("name: %s, group_router: %s", s.name, s.group_router)
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

--- a magick for usage like `lor:Router()`
-- generate a new router for different routes group
function Router:_call()
    local new_router =  clone(self)
    new_router.name = self.name .. ":group-router-" .. random()
    return new_router
end

--- a magick to convert `router()` to `router:handle()`
-- so a router() could be regarded as a `middleware`
function Router:call()
    return function(req, res, next)
        return self:handle(req, res, next)
    end
end

-- dispatch a request
function Router:handle(req, res, out)
    debug("index.lua#handle start")
    local idx = 1
    local path = req.path
    local method = req.method
    local done = restore(out, req)

    local stack = nil
    local matched = self.trie:match(path)
    debug(matched.node==nil)
    local matched_node = matched.node
    if not method or not matched_node then
        return done("404! not found.")
    else
        local matched_handlers = matched_node.handlers and matched_node.handlers[method]
        if not matched_handlers or #matched_handlers <= 0 then
            return done("Oh! no handler to process method: " .. method)
        end

        stack = compose_func(matched, method)
        if not stack or #stack <= 0 then
            return done("Oh! no handlers found.")
        end
    end

    local stack_len = #stack
    req:set_found(true)
    req.params = matched.params or {}

    local function next(err)
        debug("\nindex.lua#next...,", "stack_len:", #stack, "idx:", idx)
        if err then
            debug("\nindex.lua#next...,", "err:", err)
            return done(err)
        end

        if idx > stack_len then
            debug("\nindex.lua#next...,", "stack_len:", #stack, "idx:", idx)
            return
        end

        local handler = stack[idx]
        debug("\nindex.lua#next...,", "handler:", handler.id)
        handler.func(req, res, next)
    end
    -- end of next function

    next()
    debug("index.lua#handle end")
end

function Router:use(path, fn, fn_args_length)
    local layer
    if type(fn) == "function" then -- fn is a function
        local node = self.trie:add_node(path)
        node:use(fn)
    else -- fn is a group router
        error("not implemented...")
    end

    return self
end

-- invoked by app:route, add ^ before pattern
-- add an empty route pointing to next layer
function Router:app_route(http_method, path, fn)
    debug(string_format("router#app_route[%s], method:%s path:%s", self.name, http_method, path))
    local node = self.trie:add_node(path)
    node:handle(http_method, fn)
    return route
end

function Router:init()
    for http_method, _ in pairs(supported_http_methods) do
        self[http_method] = function(s, path, fn)
            local node = s.trie:add_node(path)
            node:handle(http_method, fn)
            return s
        end
    end
end

return Router
