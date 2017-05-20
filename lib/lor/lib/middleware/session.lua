local xpcall = xpcall
local traceback = debug.traceback
local ngx_time = ngx.time
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
--            req.session.set({k=k, v=v})
--            -- req.session.set(v)
--            res:send("session saved: " .. k .. "->" .. v)
--        else
--            res:send("null session key")
--        end
--    end)
--
--    local cjson = require "cjson"
--
--    app:get("/session/get", function(req, res, next)
--        local val = req.session.get()
--        if not val then
--            res:send("session data: no session data")
--        else
--            res:send("session data: " .. cjson.encode(val))
--        end
--    end)
--
--    app:get("/session/destroy", function(req, res, next)
--        req.session.destroy()
--    end)
--
--    -- login logout
--    app:get("/auth/login", function(req, res, next)
--        local name = req.query.name
--        local passwd = req.query.passwd
--
--        -- check name and passwd
--
--        -- check pass, set session
--        req.session.set(name)
--        res:send("login success")
--    end)
--
--    app:get("/auth/get_current_user", function(req, res, next)
--        local val = req.session.get()
--        if not val then
--            res:send("not login")
--        else
--            res:send("user data: " .. val)
--        end
--    end)
--
--    app:get("/auth/logout", function(req, res, next)
--        req.session.destroy()
--        res:send("logout success")
--    end)

-- parameter config in server.lua
local session_middleware = function(config)
    return function(req, res, next)
        req.session = {
            set = function(value)
                local s = Session.start(config)
                s.data['_uid'] = value
                s:save()
            end,

            get = function()
                local s = Session.open(config)

                if not s.data['_uid'] then
                    return nil
                end
                s:save()
                return s.data['_uid']
            end,

            destroy = function()
                local s = Session.start(config)
                s:destroy()
            end
        }

        next()
    end
end

return session_middleware
