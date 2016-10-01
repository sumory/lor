-- do something before handling every request
local params_middleware = function(req, res, next)
    req.query = req.query
    req.params = req.params
    req.body = req.body
    next()
end


return params_middleware