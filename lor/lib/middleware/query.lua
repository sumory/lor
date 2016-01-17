local query = function()
	return function q(req, res, next)
		req.query = req.query -- parse query strings
		next()
	end
end

return query