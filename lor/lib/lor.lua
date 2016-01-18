local Route = require("lor.lib.router.route")
local Router = require("lor.lib.router.index")
local Request = require("lor.lib.request")
local Response = require("lor.lib.response")
local Application = require("lor.lib.application")


local createApplication = function() 
	local app = Application:new()
	local request = Request:new()
	local response = Response:new()

	app.reqeust = request
	app.response = response
	app:init()

	return app
end







return createApplication