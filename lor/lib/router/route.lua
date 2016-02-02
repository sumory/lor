local tinsert = table.insert
local utils = require("lor.lib.utils.utils")
local random = utils.random
local slower = string.lower
local pairs = pairs
local ipairs = ipairs
local type = type
local setmetatable = setmetatable

local supported_http_methods = require("lor.lib.methods")
local Layer = require("lor.lib.router.layer")
local debug = require("lor.lib.debug")


local Route = {}

function Route:new(path)
    local instance = {}
    instance.path = path
    instance.stack = {}
    instance.methods = {}
    instance.name = "route-" .. random()

    setmetatable(instance, {
        __index = self,
        __call = self.dispatch, -- important: a magick to supply `route:dispatch`
        __tostring = function(s)
            local ok, result = pcall(function()
                return "(name:" .. s.name .. "\tpath:" .. s.path .. "\tstack_length:" .. #s.stack .. ")"
            end)
            if ok then
                return result
            else
                return "route.tostring() error"
            end
        end
    })
    instance:initMethod()

    debug("route.lua#new:", instance)
    return instance
end

function Route:_handles_method(method)
    if self.methods._all then
        return true
    end

    local name = slower(method)

    if self.methods[name] then
        return true
    else
        return false
    end
end

function Route:dispatch(req, res, done)
    --debug("route.lua#dispatch", req, res, done)
    local idx = 0
    local stack = self.stack
    if #stack == 0 then
        done("empty route stack")
        return
    end

    local method = slower(req.method)
    req.route = self

    local function next(err)
        --debug("route.lua#next err:", err)

        if err then
            done(err)
            return
        end

        idx = idx + 1
        local layer = stack[idx]
        if not layer then
            done(err)
            return
        end

        if layer.method and layer.method ~= method then
            next(err)
            return
        end

        if err then
            layer:handle_error(err, req, res, next)
        else
            layer:handle_request(req, res, next)
        end
    end

    next()
end


function Route:initMethod()
    for http_method, _ in pairs(supported_http_methods) do
        self[http_method] = function(self, fn)
            local layer = Layer:new("/", {
                is_end = true
            }, fn, 3)
            layer.method = http_method
            self.methods[http_method] = true
            tinsert(self.stack, layer)

            debug("route.lua# now the route(" ..  self.name .. ") stack is:")
            debug(function()
                for i, v in ipairs(self.stack) do
                    print(i, v)
                end
            end)
            debug("route.lua# now the route(" ..  self.name .. ") stack is~~~~~~~~~~~~\n")
        end
    end
end


function Route:all(fn)
    local layer = Layer:new("/", {}, fn, 3)
    layer.method = nil

    self.methods._all = true
    tinsert(self.stack, layer)

    return self
end


return Route