local setmetatable = setmetatable

local Request = {}

function Request:new()
    local body = {} -- body params

    local params = {}

    local instance = {
        method = "",
        query = {},
        params = {},
        body = body,
        path = "",
        url = "",
        uri = "",
        req_args = {},
        baseUrl = "",
        found = false
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