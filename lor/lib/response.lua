local setmetatable = setmetatable
local json = require("cjson")


local function json_encode(data, empty_table_as_object)
    local json_value = nil
    if json.encode_empty_table_as_object then
        json.encode_empty_table_as_object(empty_table_as_object or false) -- 空的table默认为array
    end
    if require("ffi").os ~= "Windows" then
        json.encode_sparse_array(true)
    end
    pcall(function(data) json_value = json.encode(data) end, data)
    return json_value
end


local Response = {}

function Response:new()
    ngx.header['X-Powered-By'] = 'Lor Framework'
    ngx.status = 200

    local instance = {
        headers = {},
        body = '--default body. you should not see this by default--',
        view = nil
    }

    setmetatable(instance, { __index = self })
    return instance
end

-- todo: optimize-compile before used
function Response:render(view_file, data)
    self:setHeader('Content-Type', 'text/html; charset=UTF-8')
    local body = self.view:render(view_file, data)
    self:_send(body)
end

function Response:setCookie(...)
    local cookie = self._cookie
    if not cookie then
        ngx.log(ngx.ERR, "response.lua#none _cookie found to write")
        return
    end

    local p = ...
    if type(p) == "table" then
        local ok, err = cookie:set(p)
        if not ok then
            ngx.log(ngx.ERR, err)
        end
    else
        local params = {... }
        local ok, err = cookie:set({
            key = params[1], value = params[2] or "",
        })
        if not ok then
            ngx.log(ngx.ERR, err)
        end
    end
end

function Response:html(data)
    self:setHeader('Content-Type', 'text/html; charset=UTF-8')
    self:_send(data)
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



--~=============================================================

function Response:_send(content)
    ngx.say(content)
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

function Response:status(status)
    ngx.status = status
    return self
end

function Response:setHeader(key, value)
    ngx.header[key] = value
end

return Response
