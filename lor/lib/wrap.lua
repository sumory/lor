local _M = {}

function _M:new(create_app, router)
    local instance = {}
    instance.router = router
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


return _M