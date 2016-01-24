local ck = require("resty.cookie")

local cookie_middleware = function(req, res, next)
    local cookie, err = ck:new()

    if not cookie then
        ngx.log(ngx.ERR, err)
        req.cookie = {} -- all cookies
        res._cookie = nil
    else
        local fields, err = cookie:get_all()
        if not fields then
            fields = {}
        end

        req.cookie = fields
        res._cookie = cookie
    end

    next()
end

return cookie_middleware