local Session = require("resty.session")

local session_middleware = function(sessionConfig)
    return function(req, res, next)

        local config = sessionConfig or {}
        config.storage = config.storage or "cookie" -- default is “cookie”

        -- local session = Session.new(config)
        --ngx.print(session.id)
        req.session = {
            setv = function(key, value)
                local s = Session.start({
                    secret = "7su3k78hjqw90fvj480fsdi934j7ery3n59ljf295d"
                })
                s.data[key] = value
                s:save()
            end,

            getv = function(key)
                local s = Session.open()
                return s.data[key] or ""
            end
        }
        next()
    end
end




return session_middleware