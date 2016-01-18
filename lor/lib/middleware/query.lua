local query = function()
    return function(req, res, next)
        req.query = req.query -- parse query strings
       	pcall(next)
    end
end

return query