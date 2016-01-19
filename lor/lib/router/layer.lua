local pcall = pcall
local pathRegexp = require("lor.lib.utils.path_to_regexp")


local function isTableEmpty(t)
    if t == nil or _G.next(t) == nil then
        return true
    else
        return false
    end
end


local Layer = {}


function Layer:new(path, options, fn, fn_args_length)
    local opts = options or {}
    local instance = {}
    instance.handle = fn
    instance.name = path -- "default_fn_name" --fn and fn.name and (fn.name or '<anonymous>')
    instance.params = nil
    instance.path = nil
    instance.keys = {}
    instance.length = fn_args_length -- todo:shoule only be 3 or 4
    instance.regexp = {
        pattern = pathRegexp.parse_pattern(path, instance.keys, opts),
        fast_slash = false
    }

    print("layer.lua#new - path:" .. path .. "\tpattern:" .. instance.regexp.pattern)

    if path == '/' and opts.is_end == false then
        instance.regexp.fast_slash = true
    end

    setmetatable(instance, { __index = self })
    return instance
end


function Layer:handle_error(error, req, res, next)
    local fn = self.handle

    -- fn should pin a property named 'length' to indicate its args length
    if self.length ~= 4 then
        next(error)
        return
    end

    local ok, e = pcall(function() fn(error, req, res, next) end)
    print("layer.lua - Layer:handle_error", "ok?", ok, "error:", e, "pcall_error:", e, "layer.name:", self.name)

    if not ok then
        next(erorr({ msg = e }), req, res, next)
    end
end

local function doAfterError(err)
    print("---------------------------------------- TRACK BEGIN ----------------------------------------");
    print("LUA PCALL ERROR:", err);
    print("---------------------------------------- TRACK  END  ----------------------------------------");
    return false;
end

function Layer:handle_request(req, res, next)
    local fn = self.handle
    if self.length > 3 then
        next()
        return
    end


    --  local result = xpcall(function() fn(req, res, next) end, doAfterError);
    --	if not result then
    --		next(error(e))
    --	end

    local ok, e = pcall(function() fn(req, res, next) end);
    print("layer.lua - Layer:handle_request", "ok?", ok, "error:", e, "layer.name:", self.name)

    if not ok then
        next(error(e))
    end
end


function Layer:match(path)
    print("layer.lua#match before:", "path:", path, "pattern:", self.regexp.pattern, "self.path:", self.path, "fast_slash:", self.regexp.fast_slash)
    if not path then
        self.params = nil
        self.path = nil
        print("layer.lua#match 1")
        return false
    end

    if self.regexp.fast_slash then
        self.params = {}
        self.path = ''
        print("layer.lua#match 2")
        return true
    end

    if not pathRegexp.is_match(path, self.regexp.pattern) then
        print("layer.lua#match 3")
        return false
    end

    local m = pathRegexp.parse_path(path, self.regexp.pattern, self.keys)
    if m then
        print("layer.lua#match 4", path, self.regexp.pattern, self.keys, m)
    end

    -- store values
    self.params = {}
    self.path = path

    local keys = self.keys
    local params = self.params

    for j = 1, #keys do
        local param_name = keys[j]
        if param_name then
            if m[j] then
                params[param_name] = m[j] -- todo: 添加和覆盖规则
            end
        end
    end

    print("layer.lua#match after", path, self.path)

    print("layer.lua#match 4")
    return true
end





return Layer