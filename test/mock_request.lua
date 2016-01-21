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

function Request:isFound()
    return self.found
end

function Request:setFound(isFound)
    self.found = isFound
end


return Request