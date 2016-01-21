local tinsert = table.insert
local pairs = pairs
local ipairs = ipairs
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

local function is_table_empty(t)
    if t == nil or _G.next(t) == nil then
        return true
    else
        return false
    end
end

local function get_path_name(req)
    return req.path
end

local function layer_match(layer, path)
    local is_match = layer:match(path)
     debug("index.lua - is_match:", is_match, "path:", path, "layer.pattern", layer.regexp.pattern,"layer.length", layer.length)
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
    local obj = mixin({}, parent)
    local result =  mixin(obj, params)
--    debug("merge_params: params")
--    debug(params)
--    debug("merge_params: parent")
--    debug(parent)
--    debug("merge_params: result")
--    debug(result)
    return result
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
    local router = {
        desc = "the router of `lor`"
    }
    router.params = {}
    router._params = {} --array
    router.caseSensitive = opts.caseSensitive
    router.mergeParams = opts.mergeParams
    router.strict = opts.strict
    router.stack = {} --array

    self:init()
    setmetatable(router, {
        __index = self,
        __call = self.call
    })
    return router
end

-- a magick for usage like `lor:Router()` to invoke `handle`
function proto:call()
    return function(req, res, next)
        return self:handle(req, res, next)
    end
end

-- dispatch a request
function proto:handle(req, res, out)
    -- debug("index.lua#handle")
    local idx = 1
    local stack = self.stack
    local parentUrl = req.baseUrl or ''
    local done = restore(out, req)

    local function next(err)
        local layerError = err
        debug("\nindex.lua#next..., layerError:", layerError, "stackLen:", #stack)

        if idx > #stack then
            done(layerError)
            return
        end

        local path = get_path_name(req)
        if not path then
            done(layerError)
            return
        end

        -- find the next layer
        local layer, match, route
        while (not match and idx <= #stack)
        do
            layer = stack[idx]
            idx = idx + 1

            match = layer_match(layer, path)
            route = layer.route

            if type(match) ~= 'boolean' then
                layerError = layerError or match
            end

            -- lua has no `break` keyword, such a pain
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

        if layerError then
            debug("[2]index.lua#next no route and layerError->handle_error", "layer.name", layer.name, "layer.length", layer.length,"match:", match, idx)
            layer:handle_error(layerError, req, res, next)
        elseif route then
            debug("[3]index.lua#next hasroute and not layerError->next()", "layer.name", layer.name, "layer.length", layer.length,"match:", match, idx)
            next()
        else
            debug("[4]index.lua#next no route->handle_request", "layer.name", layer.name, "layer.length", layer.length,"match:", match, idx)
            layer:handle_request(req, res, next)

--            if layer.length == 3 then
--                layer:handle_request(req, res, next)
--            else
--                layer:handle_error(layerError, req, res, next)
--            end

        end
    end
    -- end of next function

    -- setup next layer
    req.next = next

    --setup basic req values
    req.baseUrl = parentUrl

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


function proto:init()
    for http_method, _ in pairs(supported_http_methods) do
        self[http_method] = function(s, path, fn)
            local route = s:route(path)

            -- 调用route的get或是set等的方法, fn也可能会是个数组，也可能是一个元素
            -- 参数应该明确指定为route，不得省略，否则group_router.test.lua使用lor:Router()语法时无法传递route
            route[http_method](route, fn)
            return s
        end
    end
end



return proto