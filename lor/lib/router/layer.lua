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


function Layer:new(path, options, fn)
	local  opts = options or {}
	local instance = {}
	instance.handle = fn
	instance.name = "default_fn_name" --fn and fn.name and (fn.name or '<anonymous>')
	instance.params = nil
	instance.path = nil
	instance.keys = {}
	instance.regexp = {
		pattern = pathRegexp.parse_pattern(path, instance.keys, opts),
		fast_slash = false
	}

	print("regexp:" .. instance.regexp.pattern)

	if path == '/' and opts.is_end ==false then
		instance.regexp.fast_slash = true
	end

	setmetatable(instance, {__index = self})
	return instance
end


function Layer:handle_error(error, req, res, next)
	local fn = self.handle

	-- fn should pin a property named 'length' to indicate its args length
	if fn.length ~=4 then
		next(error)
		return
	end

	local ok, e =pcall(function() fn(error, req, res, next) end)
	if not ok then
		next(e)
	end
end

function Layer:handle_request(req, res, next)
	local fn = self.handle
	-- if fn.length > 3 then
	-- 	next()
	-- 	return
	-- end

	

	local ok, e = pcall(function() fn(req, res, next) end)

	print("Layer:handle_request", ok, e)

	if not ok then
		next(e)
	end
end


function Layer:match(path) 
	print("Layer:match before", path, self.regexp.pattern,self.path, self.regexp.fast_slasha)
	if not path then
		self.params = nil
		self.path = nil
		return false
	end

	if self.regexp.fast_slash then
		self.params = {}
		self.path = ''
		return true
	end

	local m = pathRegexp.parse_path(path, self.regexp.pattern, self.keys)
	if not m then
		self.params = nil
		self.path = nil
		return false
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

    print("Layer:match after", path, self.path)

    return true
end





return Layer