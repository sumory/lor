-- do something before handling every request
local handle_params = function()
    return function(req, res, next)
        req.query = req.query
        req.params = req.params
        req.body = req.body
        next()
    end
end

return handle_params