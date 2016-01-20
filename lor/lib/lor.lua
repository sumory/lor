local Route = require("lor.lib.router.route")
local Router = require("lor.lib.router.router")
local Request = require("lor.lib.request")
local Response = require("lor.lib.response")
local Application = require("lor.lib.application")

LOR_FRAMEWORK_DEBUG = false

local createApplication = function(options)
	if options and options.debug and type(options.debug) == 'boolean' then
		LOR_FRAMEWORK_DEBUG = options.debug
	end

	local app = Application:new()
	local request = Request:new()
	local response = Response:new()

	app.reqeust = request
	app.response = response
	app:init()

	return app
end


return createApplication