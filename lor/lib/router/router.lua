local  tinsert = table.insert
local Route = require("lor.lib.router.route")
local Layer = require("lor.lib.router.layer")
local supported_http_methods = require("lor.lib.methods")
local debug = require("lor.lib.debug")

local function table_is_array(t)
    if type(t) ~= "table" then return false end
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then return false end
    end
    return true
end

local function get_path_name(req)
    return req.path
end

local function layer_match(layer, path)
    local is_match = layer:match(path)
    -- debug("index.lua - is_match:", is_match, "path:", path)
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
local function merge_params(params, parent)
    if not parent then
        return params
    end
    local obj = mixin({}, parent)
    return mixin(obj, params)
end


local function restore(fn, obj)
    local origin = {
        baseUrl = obj['baseUrl'],
        next = obj['next'],
        -- params = obj['params']
    }

    return function(err)
        obj['baseUrl'] = origin.baseUrl
        obj['next'] = origin.next
       -- obj['params'] = origin.params -- maybe overrided by layer.params, so no need to keep

        fn(err)
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

-- dispatch
function proto:handle(req, res, out)
    -- debug("index.lua#handle")
    local idx = 1
    local stack = self.stack
    local parentParams = req.params
    local parentUrl = req.baseUrl or ''
    local done = restore(out, req)

    local function next(err)
        local layerError = err
        --debug("index.lua#next..., layerError:", layerError, "stackLen:", #stack)

        if idx > #stack then
            done(layerError)
            return
        end

        local path = get_path_name(req)
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

            match = layer_match(layer, path)
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

        if not match then
            --debug("no match")
            done(layerError)
            return
        end

        -- store route
        if route then
            req.route = route
        end

        if self.mergeParams then
            debug("router.lua# merge params")
            req.params = merge_params(layer.params, parentParams)
        else
            debug("router.lua# not merge params")
            debug(function()
                print("router.lua# print layer.params")
                if layer.params then
                    for i,v in pairs(layer.params) do
                        print(i,v)
                    end
                end
            end)
            req.params = layer.params
        end

        if route then
            --debug("[1]index.lua#next has route->handle_request", "layer.name", layer.name, "match:", match, idx)
            layer:handle_request(req, res, next)
        end

        if layerError then
            --debug("[2]index.lua#next no route and layerError->handle_error", "layer.name", layer.name, "match:", match, idx)
            layer:handle_error(layerError, req, res, next)
        elseif route then
            --debug("[3]index.lua#next hasroute and not layerError->next()", "layer.name", layer.name, "match:", match, idx)
            next()
        else
            --debug("[4]index.lua#next no route->handle_request", "layer.name", layer.name, "match:", match, idx)
            layer:handle_request(req, res, next)
        end
    end

    -- end of next function

    -- setup next layer
    req.next = next

    --setup basic req values
    req.baseUrl = parentUrl
    req.originalUrl = req.originalUrl or req.url

    -- debug("index.lua#next", next)
    next()
end

--  Use the given middleware function, with optional path, defaulting to "/".
function proto:use(path, fn, fn_args_length)

    local layer = Layer:new(path, {
        sensitive = self.caseSensitive,
        strict = false,
        is_end = false
    }, fn, fn_args_length)

    tinsert(self.stack, layer)

    debug(function()
        for i, v in ipairs(self.stack) do
            print(i, v)
        end
    end)


    --debug("index.lua#use new layer for path:", path, "stack length:", #self.stack, "middleware type:", fn_args_length)
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

    tinsert(self.stack, layer)
    debug(function()
        for i, v in ipairs(self.stack) do
            print(i, v)
        end
    end)

    --debug("index.lua#route new route for path:", path, "stack length:", #self.stack, "middleware type:", 3)
    return route
end


-- create Router#VERB functions
function proto:init()
    for http_method, _ in pairs(supported_http_methods) do
        self[http_method] = function(s, path, fn) -- 形成
            local route = s:route(path)
            route[http_method](fn) -- 调用route的get或是set等的方法, fn也可能会是个数组，也可能是一个元素
            return s
        end
    end
end



return proto