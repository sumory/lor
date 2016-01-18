
local init = function(app)
    return function(req, res, next)
        --if (app.enabled('x-powered-by')) 

        res.setHeader('X-Powered-By', 'Lor Framework')
        req.res = res
        res.req = req
        req.next = next

        setmetatable(req, {__index = app.request})
        setmetatable(res, {__index = app.response})

        res.locals = res.locals or {}

            pcall(next)
    end
end


return init