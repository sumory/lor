local tonumber = tonumber
local random = require "resty.random".bytes
local var = ngx.var

local defaults = {
    length = tonumber(var.session_random_length) or 16
}

return function(config)
    local c = config.random or defaults
    local l = c.length or defaults.length
    return random(l, true) or random(l)
end