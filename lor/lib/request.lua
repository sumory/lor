local error = error
local sfind = string.find
local pairs = pairs
local ipairs = ipairs
local type = type
local setmetatable = setmetatable

local Request = {}

-- new request: init args/params/body etc from http request
function Request:new()
    local body = {} -- body params
    local headers = ngx.req.get_headers()

    local header = headers['Content-Type']
    if header then
        local is_multipart = sfind(header, "multipart")
        if is_multipart and is_multipart>0 then
            -- upload request, should not invoke ngx.req.read_body()
        else
            ngx.req.read_body()
            local post_args = ngx.req.get_post_args()
            if post_args and type(post_args) == "table" then
                for k,v in pairs(post_args) do
                    body[k] = v
                end
            end
        end
    else
        ngx.req.read_body()
        local post_args = ngx.req.get_post_args()
        if post_args and type(post_args) == "table" then
            for k,v in pairs(post_args) do
                body[k] = v
            end
        end
    end

    local instance = {
        path = ngx.var.uri, -- uri
        method = ngx.req.get_method(),
        query = ngx.req.get_uri_args(),
        params = {},
        body = body,
        body_raw = ngx.req.get_body_data(),
        url = ngx.var.request_uri,
        origin_uri = ngx.var.request_uri,
        uri = ngx.var.request_uri,
        headers = headers, -- request headers

        req_args = ngx.var.args,
        found = false -- 404 or not
    }
    setmetatable(instance, { __index = self })
    return instance
end

function Request:is_found()
    return self.found
end

function Request:set_found(found)
    self.found = found
end

return Request