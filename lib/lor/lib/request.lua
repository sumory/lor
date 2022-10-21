local sfind = string.find
local pairs = pairs
local type = type
local setmetatable = setmetatable
local utils = require("lor.lib.utils.utils")

local Request = {}

-- new request: init args/params/body etc from http request
function Request:new()
    local body = {} -- body params
    local headers = ngx.req.get_headers()

    local header = headers['Content-Type']
    -- the post request have Content-Type header set
    if header then
        if sfind(header, "application/x-www-form-urlencoded", 1, true) then
            ngx.req.read_body()
            local post_args = ngx.req.get_post_args()
            if post_args and type(post_args) == "table" then
                for k,v in pairs(post_args) do
                    body[k] = v
                end
            end
        elseif sfind(header, "application/ljpack", 1, true) then
            ngx.req.read_body()
            local sb_str = ngx.req.get_body_data()
            body = utils.ljpack_decode(sb_str)
        elseif sfind(header, "application/json", 1, true) then
            ngx.req.read_body()
            local json_str = ngx.req.get_body_data()
            body = utils.json_decode(json_str)
        -- form-data request
        elseif sfind(header, "multipart", 1, true) then
            -- upload request, should not invoke ngx.req.read_body()
        -- parsed as raw by default
        else
            ngx.req.read_body()
            body = ngx.req.get_body_data()
        end
    -- the post request have no Content-Type header set will be parsed as x-www-form-urlencoded by default
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
