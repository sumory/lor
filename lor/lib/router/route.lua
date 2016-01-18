local  tinsert = table.insert
local Layer = require("lor.lib.router.layer")
local supported_http_methods = require("lor.lib.methods")

local Route = {}

function Route:new(path)

	local instance = {}
	instance.path = path
	instance.stack = {}
	instance.methods = {}

	
	setmetatable(instance, {__index = self})
	instance:initMethod()
	return instance
end

function Route:_handles_method(method)
	if self.methods._all then
		return true
	end

	local name = string.lower(method)

	if self.methods[name] then 
		return true
	else
		return false
	end
end

function Route:dispatch(req, res, done)
	local idx = 0
	local stack = self.stack
	if #stack == 0 then
		done()
		return
	end

	local method = string.lower(req.method)

	req.route = self

	next()

	function next(err)
		if err then
			done()
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
end



function Route:initMethod()
    for http_method, _ in pairs(supported_http_methods) do
        self[http_method] = function(self, fn)
        	local layer = Layer:new("/", {}, fn)
			layer.method = http_method
			self.methods[http_method] = true
			tinsert(self.stack, layer)
        end
    end
end


function Route:all(fn)
	local layer = Layer:new("/", {}, fn)
	layer.method = nil

	self.methods._all = true
	tinsert(self.stack, layer)

    return self
end


return Route