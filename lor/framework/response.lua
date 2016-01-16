local setmetatable = setmetatable
local lor_conf = require 'lor.config'
local json = require 'cjson'

local function json_encode( data, empty_table_as_object )
    local json_value = nil
    if json.encode_empty_table_as_object then
        json.encode_empty_table_as_object(empty_table_as_object or false) -- 空的table默认为array
    end
    if require("ffi").os ~= "Windows" then
        json.encode_sparse_array(true)
    end
    pcall(function (data) json_value = json.encode(data) end, data)
    return json_value
end


local Response = {}

function Response:new()
    ngx.header['X-Powered-By'] = 'lor ' .. lor_conf.version
    ngx.status = ngx.HTTP_OK
    local instance = {
        headers = {},
        body = '--default body. you should not see this by default--',
        view = nil
    }
    
    setmetatable(instance, {__index = self})
    return instance
end

-- todo: optimize-compile before used
function Response:render(view_file, data)
    self:setHeader('Content-Type', 'text/html; charset=UTF-8') 
    local body = self.view:render(view_file, data)
    self:_send(body)
end

function Response:json(data)
    self:setHeader('Content-Type', 'application/json; charset=utf-8')
    self:_send(json_encode(data))
end

function Response:redirect(url)
    ngx.redirect(url)
end

function Response:send(text)
    self:setHeader('Content-Type', 'text/plain; charset=UTF-8') 
    self:_send(text)
end

-- todo:
function Response:sendfile(file)

end

-- todo: should separate error and normal response
-- todo: should not print detail info @production environment
function Response:response(code, msg)
    self:setHeader('Content-Type', 'text/plain; charset=UTF-8') 
    if code ~= nil then
        ngx.status = code
        self:_send(msg)
    else
        self:_send(self.body)
    end    
end


--~=============================================================

function Response:_send(content)
    ngx.say(content)
end

function Response:clearBody()
    self.body = nil
end

function Response:clearHeaders()
    for k,_ in pairs(ngx.header) do
        ngx.header[k] = nil
    end
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
    if status ~= nil then ngx.status = status end
end

function Response:setHeaders(headers)
    if headers ~=nil then
        for header,value in pairs(headers) do
            ngx.header[header] = value
        end
    end
end

function Response:setHeader(key, value)
	ngx.header[key] = value
end

return Response
