local Route = require("lor.lib.router.route")
local Layer = require("lor.lib.router.layer")
local supported_http_methods = require("lor.lib.methods")

local function table_is_array(t)
    if type(t) ~= "table" then return false end
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then return false end
    end
    return true
end

local function getPathname(req)
    return req.path
end

local function matchLayer(layer, path)
    local is_match = layer:match(path)
    -- print("index.lua - is_match:", is_match, "path:", path)
    return is_match
end

local function mixin(a, b)
    if a and b then
        for k, v in pairs(b) do
            a[k] = b[k]
        end
    end

    return a
end

-- todo: merge params with parent params
-- a 填充到 b
local function mergeParams(params, parent)
    if not parent then
        return params
    end

    local obj = mixin({}, parent)

    return mixin(obj, params)
end


-- restore obj props after function
-- local done = restore(out, req, 'baseUrl', 'next', 'params')
local function restore(fn, obj)
    local vals = {
        baseUrl = obj['baseUrl'],
        next = obj['next'],
        params = obj['params']
    }

    return function(err)
        obj['baseUrl'] = vals.baseUrl
        obj['next'] = vals.next
        obj['params'] = vals.params

        fn(err) -- 继续调用fn函数
        return
    end
end


local proto = {}


function proto:new(options)
    local opts = options or {}

    local router = {}
    router.params = {}
    router._params = {} --array
    router.caseSensitive = opts.caseSensitive
    router.mergeParams = opts.mergeParams
    router.strict = opts.strict
    router.stack = {} --array

    self:init()
    setmetatable(router, { __index = self })

    return router
end

-- Dispatch a req, res into the router.
function proto:handle(req, res, out)
    -- print("index.lua#handle")
    local urlIndexOf = string.find(req.url, "?")

    local pathLength
    if urlIndexOf then
        pathLength = urlIndexOf - 1
    else
        pathLength = req.url:len()
    end

    local fqdn
    if string.sub(req.url, 1, 1) ~= '/' then
        fqdn = 1 + string.find(string.sub(req.url, 1, pathLength), "://")
    end

    local protohost
    if fqdn then
        local tt = string.find(req.url, "/", 2 + fqdn)
        protohost = string.sub(req.url, 1, tt)
    else
        protohost = ""
    end

    local idx = 1
    local slashAdded = false

    -- middleware and routes
    local stack = self.stack

    -- manage inter-router variables
    local parentParams = req.params
    local parentUrl = req.baseUrl or ''
    local done = restore(out, req)




    local function next(err)
        local layerError = err
        --print("index.lua#next..., layerError:", layerError, "stackLen:", #stack)

        if slashAdded then
            req.url = string.sub(req.url, 2) -- 去除/
            slashAdded = false
        end

        -- no more matching layers
        if idx > #stack then
            done(layerError)
            return
        end

        -- get pathname of request
        local path = getPathname(req)
        if not path then
            done(layerError)
            return
        end

        -- find next matching layer
        local layer, match, route
        while (not match and idx <= #stack)
        do
            local tmp_idx = idx
            layer = stack[idx]
            idx = idx + 1

            match = matchLayer(layer, path)
            route = layer.route

            if type(match) ~= 'boolean' then
                layerError = layerError or match
            end

            if not match then
                -- to continue
            else
                if not route then
                    -- to continue
                else
                    if layerError then
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

        -- no match
        if not match then
            --print("no mathhhhhhhhhhhhhh")
            done(layerError)
            return
        end

        -- store route for dispatch on change
        if route then
            req.route = route
        end

        if self.mergeParams then
            req.params = mergeParams(layer.params, parentParams)
        else
            req.params = layer.params
        end

        if route then
            --print("111111111111111index.lua#next has route->handle_request", "layer.name", layer.name, "match:", match, idx)
            layer:handle_request(req, res, next)
        end

        if layerError then
            --print("2222222222222222index.lua#next no route and layerError->handle_error", "layer.name", layer.name, "match:", match, idx)
            layer:handle_error(layerError, req, res, next)
        elseif route then
            --print("333333333333333index.lua#next hasroute and not layerError->next()", "layer.name", layer.name, "match:", match, idx)
            next()
        else
            --print("444444444444444index.lua#next no route->handle_request", "layer.name", layer.name, "match:", match, idx)
            layer:handle_request(req, res, next)
        end
    end

    -- end of next function

    -- setup next layer
    req.next = next

    --setup basic req values
    req.baseUrl = parentUrl
    req.originalUrl = req.originalUrl or req.url

    -- print("index.lua#next", next)
    next()
end

--  Use the given middleware function, with optional path, defaulting to "/".
function proto:use(path, fn, fn_args_length)

    local layer = Layer:new(path, {
        sensitive = self.caseSensitive,
        strict = false,
        is_end = false
    }, fn, fn_args_length)

    table.insert(self.stack, layer)
    table.foreach(self.stack, function(i,v)
        print(i, v)
    end)

    print("index.lua#use new layer for path:", path, "stack length:", #self.stack, "middleware type:", fn_args_length)
    return self
end

-- Create a new Route for the given path.
function proto:route(path) -- 在第一层增加一个空route指向下一层
    local route = Route:new(path)
    local layer = Layer:new(path, {
        sensitive = self.caseSensitive,
        strict = self.strict,
        is_end = true
    }, route, 3) -- import: a magick to supply route:dispatch
    layer.route = route

    table.insert(self.stack, layer)
    table.foreach(self.stack, function(i,v)
        print(i, v)
    end)


    print("index.lua#route new route for path:", path, "stack length:", #self.stack, "middleware type:", 3)
    return route
end



-- create Router#VERB functions
function proto:init()
    for http_method, _ in pairs(supported_http_methods) do
        -- 生成方法，类似
        -- proto:get = function(path, fn)
        --
        -- end
        self[http_method] = function(s, path, fn) -- 形成
            local route = s:route(path)
            route[http_method](fn) -- 调用route的get或是set等的方法, fn也可能会是个数组，也可能是一个元素

            return s
        end
    end
end



return proto