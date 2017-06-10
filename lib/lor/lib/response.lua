local pairs = pairs
local type = type
local setmetatable = setmetatable
local tinsert = table.insert
local tconcat = table.concat
local utils = require("lor.lib.utils.utils")

local Response = {}

function Response:new()
    --ngx.status = 200
    local instance = {
        http_status = nil,
        headers = {},
        locals = {},
        body = '--default body. you should not see this by default--',
        view = nil
    }

    setmetatable(instance, { __index = self })
    return instance
end

-- todo: optimize-compile before used
function Response:render(view_file, data)
    if not self.view then
        ngx.log(ngx.ERR, "`view` object is nil, maybe you disabled the view engine.")
        error("`view` object is nil, maybe you disabled the view engine.")
    else
        self:set_header('Content-Type', 'text/html; charset=UTF-8')
        data = data or {}
        data.locals = self.locals -- inject res.locals

        local body = self.view:render(view_file, data)
        self:_send(body)
    end
end


function Response:html(data)
    self:set_header('Content-Type', 'text/html; charset=UTF-8')
    self:_send(data)
end

function Response:json(data, empty_table_as_object)
    self:set_header('Content-Type', 'application/json; charset=utf-8')
    self:_send(utils.json_encode(data, empty_table_as_object))
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
    self:set_header('Content-Type', 'text/plain; charset=UTF-8')
    self:_send(text)
end

--~=============================================================

function Response:_send(content)
    ngx.status =  self.http_status or 200
    ngx.say(content)
end

function Response:get_body()
    return self.body
end

function Response:get_headers()
    return self.headers
end

function Response:get_header(key)
    return self.headers[key]
end

function Response:set_body(body)
    if body ~= nil then self.body = body end
end

function Response:status(status)
    ngx.status = status
    self.http_status = status
    return self
end

function Response:set_header(key, value)
    ngx.header[key] = value
end

return Response
