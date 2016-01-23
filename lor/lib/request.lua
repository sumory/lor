local error = error
local pairs = pairs
local setmetatable = setmetatable

local Request = {}

-- new request: init args/params/body etc from http request
function Request:new()
    ngx.req.read_body()

    local body = {} -- body params
    for k,v in pairs(ngx.req.get_post_args()) do
        body[k] = v
    end

    local instance = {
        path = ngx.var.uri, -- uri
        method = ngx.req.get_method(),
        query = ngx.req.get_uri_args(),
        params = {},
        body = body,
        body_raw = ngx.req.get_body_data(),
        url = ngx.var.request_uri,
        uri = ngx.var.request_uri,
        req_args = ngx.var.args,
        found = false --标识404错误
    }
    setmetatable(instance, { __index = self })
    return instance
end

function Request:mock()
    local query = {} -- uri params
    local body = {} -- body params
    local params = {}

    local instance = {
        method = "get",
        query = {},
        params = {},
        body = {},
        path = "",
        uri = "",
        baseUrl = "",
    }
    setmetatable(instance, { __index = self })
    return instance
end

function Request:isFound()
    return self.found
end

function Request:setFound(isFound)
    self.found = isFound
end

return Request