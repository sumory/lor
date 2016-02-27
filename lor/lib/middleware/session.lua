local Session = require("resty.session")

-- Mind:
-- base on 'lua-resty-session'
-- this is the default `session` middleware which uses storage `cookie`
-- you're recommended to define your own `session` middleware.
-- you're strongly recommended to set your own session.secret

-- usage example:
--    app:get("/session/set", function(req, res, next)
--        local k = req.query.k
--        local v = req.query.v
--        if k then
--            req.session.set(k,v)
--            res:send("session saved: " .. k .. "->" .. v)
--        else
--            res:send("null session key")
--        end
--    end)
--
--    app:get("/session/get/:key", function(req, res, next)
--        local k = req.params.key
--        if not k then
--            res:send("please input session key")
--        else
--            res:send("session data: " .. req.session.get(k))
--        end
--    end)
--
--    app:get("/session/destroy", function(req, res, next)
--        req.session.destroy()
--    end)
local session_middleware = function(sessionConfig)
    sessionConfig = sessionConfig or {}
    return function(req, res, next)
        -- local config = sessionConfig or {}
        -- config.storage = config.storage or "cookie" -- default is “cookie”
        -- local session = Session.new(config)
        req.session = {
            set = function(key, value)
                local s = Session.start({
                    secret = sessionConfig.secret or "7su3k78hjqw90fvj480fsdi934j7ery3n59ljf295d"
                })
                s.data[key] = value
                s:save()
            end,

            get = function(key)
                local s = Session.open({
                    secret = sessionConfig.secret or "7su3k78hjqw90fvj480fsdi934j7ery3n59ljf295d"
                })
                return s.data[key] or ""
            end,

            destroy = function()
                local session = Session.start({
                    secret = sessionConfig.secret or "7su3k78hjqw90fvj480fsdi934j7ery3n59ljf295d"
                })
                session:destroy()
            end
        }
        next()
    end
end




return session_middleware