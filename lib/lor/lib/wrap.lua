local error = error
local pairs = pairs
local type = type
local setmetatable = setmetatable
local tostring = tostring


local _M = {}

function _M:new(create_app, Router, Route, Request, Response)
    local instance = {}
    instance.router = Router
    instance.route = Route
    instance.request = Request
    instance.response = Response
    instance.fn = create_app
    instance.app = nil

    setmetatable(instance, {
        __index = self,
        __call = self.create_app
    })

    return instance
end

-- Generally, this shouled only be used for `lor` framework itself.
function _M:create_app(options)
    self.app = self.fn(options)
    return self.app
end

function _M:Router(options)
    options = options or {}
    options.group_router = true
    return self.router:new(options)
end

function _M:Route(path)
    return self.route:new(path)
end

function _M:Request()
    return self.request:new()
end

function _M:Response()
    return self.response:new()
end


return _M