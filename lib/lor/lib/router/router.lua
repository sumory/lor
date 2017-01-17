local pairs = pairs
local ipairs = ipairs
local pcall = pcall
local xpcall = xpcall
local type = type
local setmetatable = setmetatable
local getmetatable = getmetatable
local traceback = debug.traceback
local tinsert = table.insert
local table_concat = table.concat
local string_format = string.format

local utils = require("lor.lib.utils.utils")
local supported_http_methods = require("lor.lib.methods")
local debug = require("lor.lib.debug")
local Trie = require("lor.lib.trie")
local is_table_empty = utils.is_table_empty
local random = utils.random
local mixin = utils.mixin


local function restore(fn, obj)
    local origin = {
        path = obj['path'],
        query = obj['query'],
        next = obj['next'],
        locals = obj['locals'],
    }

    return function(err)
        obj['path'] = origin.path
        obj['query'] = origin.query
        obj['next'] = origin.next
        obj['locals'] = origin.locals
        fn(err)
    end
end

local function compose_func(matched, method)
    if not matched or type(matched.pipeline) ~= "table" then
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

local function compose_error_handler(node)
    if not node then
        return nil
    end

    local stack = {}
    while node do
        for _, middleware in ipairs(node.error_middlewares) do
            tinsert(stack, middleware)
        end
        node = node.parent
    end

    return stack
end


local Router = {}

function Router:new(options)
    local opts = options or {}
    local router = {}

    router.name =  "router-" .. random()
    router.trie = Trie:new({
        ignore_case = opts.ignore_case,
        tsr = opts.tsr
    })

    self:init()
    setmetatable(router, {
        __index = self,
        __tostring = function(s)
            local ok, result = pcall(function()
                return string_format("name: %s", s.name)
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

    local path = req.path
    local method = req.method
    local done = restore(out, req)

    local stack = nil
    local matched = self.trie:match(path)
    local matched_node = matched.node
    if not method or not matched_node then
        if res.status then res:status(404) end
        return self:error_handle("404! not found.", req, res, self.trie.root, done)
    else
        local matched_handlers = matched_node.handlers and matched_node.handlers[method]
        if not matched_handlers or #matched_handlers <= 0 then
            return self:error_handle("Oh! no handler to process method: " .. method, req, res, self.trie.root, done)
        end

        stack = compose_func(matched, method)
        if not stack or #stack <= 0 then
            return self:error_handle("Oh! no handlers found.", req, res, self.trie.root, done)
        end
    end

    local stack_len = #stack
    req:set_found(true)
    req.params = matched.params or {}

    debug("start next, stack_len:", #stack, "params_len:", #req.params)
    local idx = 0
    local function next(err)
        debug("index.lua#next...,", "stack_len:", #stack, "idx:", idx)
        if err then
            debug("index.lua#next ---> to error_handle,", "err:", err)
            return self:error_handle(err, req, res, stack[idx].node, done)
        end

        if idx > stack_len then
            debug("index.lua#next...,", "stack_len:", #stack, "idx:", idx, "err:", err)
            return done(err) -- err is nil or not
        end

        idx = idx + 1
        local handler = stack[idx]
        if not handler then
            return done(err)
        end
        debug("index.lua#next...,", "handler:", handler.id)

        local err_msg
        local ok, ee = xpcall(function()
            handler.func(req, res, next)
        end, function(msg)
            if msg then
                if type(msg) == "string" then
                    err_msg = msg
                elseif type(msg) == "table" then
                    err_msg = "[ERROR]" .. table_concat(msg, "|") .. "[/ERROR]"
                end
            else
                err_msg = ""
            end
            err_msg = err_msg .. "\n" .. traceback()
        end)

        if not ok then
            --debug("handler func:call error ---> to error_handle,", ok, "err_msg:", err_msg)
            return self:error_handle(err_msg, req, res, handler.node, done)
        end
    end
    -- end of next function

    next()
    debug("index.lua#handle end")
end

-- dispatch an error
function Router:error_handle(err_msg, req, res, node, done)
    debug("index.lua#error_handle start")
    local stack = compose_error_handler(node)
    if not stack or #stack <= 0 then
        return done(err_msg)
    end

    debug("index.lua#error_handle next begin, stack_len:", #stack)
    local idx = 0
    local stack_len = #stack
    local function next(err)
        if idx >= stack_len then
            debug("index.lua#error_handle next end,", "stack_len:", #stack, "idx:", idx)
            return done(err)
        end

        idx = idx + 1
        local error_handler = stack[idx]
        if not error_handler then
            return done(err)
        end
        debug("index.lua#error_handle next,", "statck idnex:", idx, "error_handler:", error_handler.id)

        local ok, ee = xpcall(function()
            error_handler.func(err, req, res, next)
        end, function(msg)
            if msg then
                if type(msg) == "string" then
                    err_msg = msg
                elseif type(msg) == "table" then
                    err_msg = "[ERROR]" .. table_concat(msg, "|") .. "[/ERROR]"
                end
            else
                err_msg = ""
            end

            err_msg = string_format("%s\n[ERROR in ErrorMiddleware#%s(%s)] %s \n%s", err, idx, error_handler.id, err_msg, traceback())
        end)

        if not ok then
            -- debug("index.lua#error_handle next func:call error", error_handler.id, ok, "ee:", ee, "err:", err,  "err_msg:", err_msg)
            return done(err_msg)
        end
    end
    -- end of next function

    next(err_msg)
    debug("index.lua#error_handle end")
end

function Router:use(path, fn, fn_args_length)
    if type(fn) == "function" then -- fn is a function
        local node
        if not path then
            node = self.trie.root
        else
            node = self.trie:add_node(path)
        end
        if fn_args_length == 3 then
            node:use(fn)
        elseif fn_args_length == 4 then
            node:error_use(fn)
        end
    elseif fn and fn.is_group == true then -- fn is a group router
        if fn_args_length ~= 3 then
            error("illegal param, fn_args_length should be 3")
        end

        path = path or "" -- if path is nil, then mount it on `root`
        self:merge_group(path, fn)
    end

    return self
end

function Router:merge_group(prefix, group)
    local apis = group:get_apis()
    if apis and #apis > 0 then
        for uri, api_methods in pairs(apis) do
            if type(api_methods) == "table" and #api_methods > 0 then
                local path = utils.clear_slash(prefix .. "/" .. uri)
                local node = self.trie:add_node(path)
                if not node then
                    return error("cann't define node on router trie, path:" .. path)
                end

                for method, func in pairs(api_methods) do
                    local m = string_lower(method)
                    if supported_http_methods[m] == true then
                        node:handle(m, func)
                    end
                end
            end
        end
    end
end

function Router:app_route(http_method, path, fn)
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
