local pcall = pcall
local xpcall = xpcall
local traceback = debug.traceback
local pairs = pairs
local ipairs = ipairs
local type = type
local setmetatable = setmetatable
local ostime = os.time
local pathRegexp = require("lor.lib.utils.path_to_regexp")
local utils = require("lor.lib.utils.utils")
local random = utils.random
local debug = require("lor.lib.debug")

math.randomseed(ostime())


local Layer = {}

function Layer:new(path, options, fn, fn_args_length)
    local opts = options or {}
    local instance = {}
    instance.handle = fn
    instance.name = "layer-" .. random()
    instance.params = {}
    instance.path = path
    instance.keys = {}
    instance.length = fn_args_length -- todo:shoule only be 3 or 4
    instance.is_end = opts.is_end or false -- is belong to a route?;is the last really to match the path?
    instance.is_start = opts.is_start or false -- is belong to a route?;is the last really to match the path?

    local tmp_pattern = pathRegexp.parse_pattern(path, instance.keys, opts)
    if tmp_pattern == "" or not tmp_pattern then
        instance.pattern = "/"
    else
        instance.pattern = tmp_pattern
    end

    if instance.is_end then
        instance.pattern = instance.pattern .. "$"
    else
        instance.pattern = pathRegexp.clear_slash(instance.pattern .. "/")
    end

    if instance.is_start then
        instance.pattern = "^" .. pathRegexp.clear_slash("/" .. instance.pattern)
    else
        instance.pattern =  instance.pattern
    end

    setmetatable(instance, {
        __index = self,
        __tostring = function(s)
            local ok, result = pcall(function()
                local route_name, is_end = "<nil>", ""
                if s.route then
                    route_name = s.route.name
                end

                if s.is_end then
                    is_end = "true"
                else
                    is_end = "false"
                end

                return "(name:" .. s.name .. "\tpath:" .. s.path .. "\tlength:" .. s.length ..
                        "\t layer.route.name:" .. route_name ..
                        "\tpattern:" .. s.pattern .."\tis_end:" .. is_end .. ")"
            end)

            if ok then
                return result
            else
                return "layer.tostring() error"
            end
        end
    })
    debug("layer.lua#new:", instance)
    return instance
end

function Layer:handle_error(err, req, res, next)
    debug("layer.lua#handel_error:", self, err)
    local fn = self.handle

    -- a property named 'length' to indicate its args length
    if self.length ~= 4 then
        debug("not match handle_error")
        next(err)
        return
    end

    local e
    local ok = xpcall(function() 
        fn(err, req, res, next) 
    end,  function()
        e = (err or "") .. "\n" .. traceback()
    end)
    --print(random() .. "  layer.lua - Layer:handle_error", "ok?", ok, "error:", e, "pcall_error:", e, "layer.name:", self.name)

    if not ok then
        next(e)
    end
end

function Layer:handle_request(req, res, next)
    debug("layer.lua#handle_request:", self)

    local fn = self.handle
    if self.length > 3 then
        debug("---------->not match handle_request")
        next()
        return
    end

    --local trackId = random()
    local e
    local ok, ee = xpcall(function() -- add `ee` for final handler logic
        fn(req, res, next) 
    end, function(msg)
        e = (msg or "") .. "\n" .. traceback()
    end)
    --debug(trackId .. "  layer.lua - Layer:handle_request-", "ok?", ok, "error:", e, "layer.name:", self.name, "middle_type:", self.length)

    if not ok then
        debug("handle_request:call error", ok, e, ee)
        next(e or ee)
    end
end

function Layer:match(path)
    debug("layer.lua#match before:", "path:", path, "layer:", self)
    if not path then
        self.params = nil
        debug("layer.lua#match 1")
        return false
    end

    if self.is_end then
        path = pathRegexp.clear_slash(path)
    else
        path = pathRegexp.clear_slash(path .. "/")
    end


    local match_or_not = pathRegexp.is_match(path, self.pattern)
    if not match_or_not then
        debug("layer.lua#match 3")
        return false
    end

    local m = pathRegexp.parse_path(path, self.pattern, self.keys)
    if m then
        debug("layer.lua#match 4", path, self.pattern, self.keys, m)
    end

    -- store values
    -- self.path = path
    -- self.params = mixin(m, self.params) -- this is only this layer's params
    self.params = m  -- fixbug: the params should not be transfered to next Request.

    debug(function()
        print("layer.lua# print layer.params")
        if self.params then
            for i, v in pairs(self.params) do
                print(i, v)
            end
        end
    end)

    return true
end


return Layer
