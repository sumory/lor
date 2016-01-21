local error = error
local pairs = pairs
local setmetatable = setmetatable

local Request = {}

-- new request: init args/params/body etc from http request
function Request:new()

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

function Request:getMethod()
    return self.method
end

return Request