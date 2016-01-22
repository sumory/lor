local pcall = pcall
local ostime = os.time
local pathRegexp = require("lor.lib.utils.path_to_regexp")
local utils = require("lor.lib.utils.utils")
local is_table_empty = utils.is_table_empty
local mixin = utils.mixin
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
    local tmp_pattern = pathRegexp.parse_pattern(path, instance.keys, opts)
    if tmp_pattern == "" or not tmp_pattern then
        instance.pattern = "/"
    else
        instance.pattern = tmp_pattern
    end

    setmetatable(instance, {
        __index = self,
        __tostring = function(s)
            local ok, result = pcall(function()
                local route_name = "<nil>"
                if s.route then
                    route_name = s.route.name
                end

                return "(name:" .. s.name .. "\tpath:" .. s.path .. "\tlength:" .. s.length ..
                        "\t layer.route.name:" .. route_name .. "\tpattern:" .. s.pattern .. ")"
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


function Layer:handle_error(error, req, res, next)
    debug("layer.lua#handel_error:", self, error)
    local fn = self.handle
    -- fn should pin a property named 'length' to indicate its args length
    if self.length ~= 4 then
        debug("not match handle_error")
        next(error)
        return
    end

    local ok, e = pcall(function() fn(error, req, res, next) end)
    --print(random() .. "  layer.lua - Layer:handle_error", "ok?", ok, "error:", e, "pcall_error:", e, "layer.name:", self.name)

    if not ok then
        next(e)
    end
end


function Layer:handle_request(req, res, next)
    debug("layer.lua#handel_request:", self)

    local fn = self.handle
    if self.length > 3 then
        debug("---------->not match handle_request")
        next()
        return
    end

    --local trackId = random()
    local ok, e = pcall(function() fn(req, res, next) end);
    --debug(trackId .. "  layer.lua - Layer:handle_request-", "ok?", ok, "error:", e, "layer.name:", self.name, "middle_type:", self.length)

    if not ok then
        --debug("handle_request:pcall error", ok, e)
        next(e)
    end
end

-- req's fullpath
function Layer:match(path)
    debug("layer.lua#match before:", "path:", path, "pattern:", self.pattern)
    if not path then
        self.params = nil
        self.path = nil
        debug("layer.lua#match 1")
        return false
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
    self.path = path
    self.params = mixin(m, self.params) -- this is only this layer's params

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