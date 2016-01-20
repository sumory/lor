local _M = {}

function _M:new(create_app, router, route, request, response)
    local instance = {}
    instance.router = router
    instance.route = route
    instance.request = request
    instance.response = response
    instance.fn = create_app

    setmetatable(instance, {
        __index = self,
        __call = self.createApp
    })

    return instance
end

function _M:createApp(options)
    return self.fn(options)
end

function _M:Router()
    return self.router
end

function _M:Route()
    return self.route
end

function _M:Request()
    return self.Request
end

function _M:Response()
    return self.Response
end


return _M