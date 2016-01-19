local _M = {}

function _M:new(fn, length)
    local instance = {}
    instance.length = length
    instance.fn = fn

    if length == 3 then
        setmetatable(instance, {
            __index = self,
            __call = self.handle_request
        })
    elseif length == 4 then
        setmetatable(instance, {
            __index = self,
            __call = self.handle_error
        })
    end

    return instance
end

function _M:handle_request(req, res, next)
    print("this is handle_request")
    self.fn(req, res, next)
end

function _M:handle_error(err, req, res, next)
    print("this is handle_error")
    self.fn(err, req, res, next)
end


return _M