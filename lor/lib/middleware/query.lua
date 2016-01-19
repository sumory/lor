local query = function()
    return function(req, res, next) -- next 为index.lua里的next
        req.query = req.query -- parse query strings
        print("query.lua#run",req.url,  next)
        next()
    end
end

return query