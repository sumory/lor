-- do something before handling every request
local handle_params = function(req, res, next)
    req.query = req.query
    req.params = req.params
    req.body = req.body
    next()
end


return handle_params