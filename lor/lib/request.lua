-- perf
local error = error
local pairs = pairs
local setmetatable = setmetatable

local Request = {}

-- new request: init args/params/body etc from http request
function Request:new()

    local query = {} -- uri params
    local body = {} -- body params
    
    local instance = {
        controller_name = '',
        action_name = '',
        uri = "",


        path = { -- path variables, init when `route`
            params = {
            }
        },
        query = query,
        body = body,
        
        method = "get"
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