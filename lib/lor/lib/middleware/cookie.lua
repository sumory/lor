local ck = require("resty.cookie")

-- Mind:
-- base on 'lua-resty-cookie', https://github.com/cloudflare/lua-resty-cookie
-- this is the default `cookie` middleware
-- you're recommended to define your own `cookie` middleware.

-- usage example:
--    app:get("/cookie", function(req, res, next)
--        res.cookie.set({key = "c2", value = "c2_value"})
--        res.cookie.set("c1", "c1_value")
--    end)
local cookie_middleware = function(cookieConfig)
    return function(req, res, next)
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
            res.cookie = {
                set = function(...)
                    local _cookie = cookie
                    if not _cookie then
                        ngx.log(ngx.ERR, "response#none _cookie found to write")
                        return
                    end

                    local p = ...
                    if type(p) == "table" then
                        local ok, err = _cookie:set(p)
                        if not ok then
                            ngx.log(ngx.ERR, err)
                        end
                    else
                        local params = { ... }
                        local ok, err = _cookie:set({
                            key = params[1],
                            value = params[2] or "",
                        })
                        if not ok then
                            ngx.log(ngx.ERR, err)
                        end
                    end
                end
            }
        end

        next()
    end
end

return cookie_middleware
