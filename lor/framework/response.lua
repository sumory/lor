local setmetatable = setmetatable
local json = require("cjson")

local function json_encode( data, empty_table_as_object )
  --Lua的数据类型里面，array和dict是同一个东西。对应到json encode的时候，就会有不同的判断
  --对于linux，我们用的是cjson库：A Lua table with only positive integer keys of type number will be encoded as a JSON array. All other tables will be encoded as a JSON object.
  --cjson对于空的table，就会被处理为object，也就是{}
  --dkjson默认对空table会处理为array，也就是[]
  --处理方法：对于cjson，使用encode_empty_table_as_object这个方法。文档里面没有，看源码
  --对于dkjson，需要设置meta信息。local a= {}；a.s = {};a.b='中文';setmetatable(a.s,  { __jsontype = 'object' });ngx.say(comm.json_encode(a))

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
    --ngx.header['Content_type'] = 'text/html; charset=UTF-8'
    ngx.status = ngx.HTTP_OK
    local instance = {
        headers = {},
        body = '--default body. you should not see this by default--',
        view = nil
    }
    
    setmetatable(instance, {__index = self})
    return instance
end

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
