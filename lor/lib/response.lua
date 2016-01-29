local setmetatable = setmetatable
local pairs = pairs
local ipairs = ipairs
local tinsert = table.insert
local tconcat = table.concat

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


function Response:html(data)
    self:setHeader('Content-Type', 'text/html; charset=UTF-8')
    self:_send(data)
end

function Response:json(data)
    self:setHeader('Content-Type', 'application/json; charset=utf-8')
    self:_send(json_encode(data))
end

function Response:redirect(url, code, query)
    if url and not code and not query then -- only one param
        ngx.redirect(url)
    elseif url and code and not query then -- two param
        if type(code) == "number" then
            ngx.redirect(url ,code)
        elseif type(code) == "table" then
            query = code
            local q = {}
            local is_q_exist = false
            if query and type(query) == "table" then
                for i,v in pairs(query) do
                    tinsert(q, i .. "=" .. v)
                    is_q_exist = true
                end
            end

            if is_q_exist then
                url = url .. "?" .. tconcat(q, "&")
            end

            ngx.redirect(url)
        else
            ngx.redirect(url)
        end
    else -- three param
        local q = {}
        local is_q_exist = false
        if query and type(query) == "table" then
           for i,v in pairs(query) do
               tinsert(q, i .. "=" .. v)
               is_q_exist = true
           end
        end

        if is_q_exist then
            url = url .. "?" .. tconcat(q, "&")
        end
        ngx.redirect(url ,code)
    end
end

function Response:location(url, data)
    if data and type(data) == "table" then
        ngx.req.set_uri_args(data)
        ngx.req.set_uri(url, false)
    else
        ngx.say(url)
        ngx.req.set_uri(url, false)
    end
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
