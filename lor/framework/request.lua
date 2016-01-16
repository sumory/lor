-- perf
local error = error
local pairs = pairs
local setmetatable = setmetatable

local Request = {}

-- new request: init args/params/body etc from http request
function Request:new()
    ngx.req.read_body()
    local query = ngx.req.get_uri_args() -- uri params
    local body = {} -- body params
    for k,v in pairs(ngx.req.get_post_args()) do
        body[k] = v
    end

    local instance = {
        controller_name = '',
        action_name = '',
        uri = ngx.var.uri,
        req_uri = ngx.var.request_uri,
        req_args = ngx.var.args,

        path = { -- path variables, init when `route`
            params = {
            }
        },
        query = query,
        body = body,
        
        method = ngx.req.get_method(),
        headers = ngx.req.get_headers(),
        body_raw = ngx.req.get_body_data()
    }
    setmetatable(instance, {__index = self})
    return instance
end

function Request:getControllerName()
    return self.controller_name
end

function Request:getActionName()
    return self.action_name
end

function Request:getMethod()
    return self.method
end

return Request