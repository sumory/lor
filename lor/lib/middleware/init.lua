local init = function(app)
    return function(req, res, next)
        req.res = res
        req.next = next

        res.req = req
        res:setHeader('X-Powered-By', 'Lor Framework')
        res.locals = res.locals or {}

        -- setmetatable(req, {__index = app.request})
        -- setmetatable(res, {__index = app.response})

        next()
    end
end

return init