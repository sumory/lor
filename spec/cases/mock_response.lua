local setmetatable = setmetatable

local Response = {}

function Response:new()
    local instance = {
        headers = {},
        body = '--default body. you should not see this by default--',
        view = nil,
    }

    setmetatable(instance, {__index = self})
    return instance
end

function Response:json(data)
    self:_send(data)
end

function Response:send(text)
    self:_send(text)
end

function Response:_send(content)
    print(content)
end

function Response:setHeader(key, value)
end

function Response:status(code)
    self.http_status = code
    return self
end

return Response
