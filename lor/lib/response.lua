local setmetatable = setmetatable

local Response = {}

function Response:new()
    local instance = {
        headers = {},
        body = '--default body. you should not see this by default--',
        view = nil
    }
    
    setmetatable(instance, {__index = self})
    return instance
end


function Response:json(data)
    self:setHeader('Content-Type', 'application/json; charset=utf-8')
    self:_send(data)
end

function Response:redirect(url)
    ngx.redirect(url)
end

function Response:send(text)
    self:setHeader('Content-Type', 'text/plain; charset=UTF-8') 
    self:_send(text)
end



--~=============================================================

function Response:_send(content)
    print(content)
end



function Response:getBody()
    return self.body
end

function Response:getHeader()
    return self.headers
end

function Response:setBody(body)
    if body ~= nil then self.body = body end
end

function Response:setStatus(status)
   
end

function Response:setHeaders(headers)
 
end

function Response:setHeader(key, value)
	
end

return Response
