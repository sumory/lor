local setmetatable = setmetatable
local pairs = pairs
local type = type
local string_format = string.format
local string_lower = string.lower

local supported_http_methods = require("lor.lib.methods")
local debug = require("lor.lib.debug")
local utils = require("lor.lib.utils.utils")
local random = utils.random
local clone = utils.clone

local Group = {}

function Group:new()
    local group = {}

    group.id = random()
    group.name =  "group-" .. group.id
    group.is_group = true
    group.apis = {}
    self:build_method()

    setmetatable(group, {
        __index = self,
        __call = self._call,
        __tostring = function(s)
            return s.name
        end
    })

    return group
end

--- a magick for usage like `lor:Router()`
-- generate a new group for different routes group
function Group:_call()
    local cloned = clone(self)
    cloned.id = random()
    cloned.name = cloned.name .. ":clone-" .. cloned.id
    return cloned
end

function Group:get_apis()
    return self.apis
end

function Group:set_api(path, method, func)
    if not path or not method or not func then
        return error("params should not be nil.")
    end

    if type(path) ~= "string" or type(method) ~= "string" or type(func) ~= "function" then
        return error("params type error.")
    end

    method = string_lower(method)
    if not supported_http_methods[method] then
        return error(string_format("[%s] method is not supported yet.", method))
    end

    self.apis[path] = self.apis[path] or {}
    self.apis[path][method] = func
end

function Group:build_method()
    for m, _ in pairs(supported_http_methods) do
        m = string_lower(m)
        Group[m] = function(myself, path, func)
            Group.set_api(myself, path, m, func)
        end
    end
end

function Group:clone()
    local cloned = clone(self)
    cloned.id = random()
    cloned.name = cloned.name .. ":clone-" .. cloned.id
    return cloned
end

return Group
