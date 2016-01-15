local error = error
local pairs = pairs
local setmetatable = setmetatable
local sgsub = string.gsub
local smatch = string.match
local tostring = tostring
local type = type
local function tappend(t, v) t[#t+1] = v end


local supported_http_methods = {
    get = true,
    post = true,
    head = true,
    options = true,
    put = true,
    patch = true,
    delete = true,
    trace = true
}

local Routes = {}

function Routes:new()

    local instance = {
        name = 'global_routes',
        routes = {}  -- routes array
    }

    self:init()
    setmetatable(instance, {__index = Routes})
    return instance
end

-- invoke's pattern is like "$module_path:$method", such as 'application.user_controller:getUser'
function Routes:add(method, pattern, invoke)
    local pattern, params = self:parse_path(pattern)
    pattern = "^" .. pattern .. "/???$"

    tappend(self.routes, { 
        pattern = pattern, 
        [method] = {
            invoke = invoke,
            params = params
        }
    })
end

-- parse pattern, for example: 
-- /user/:id/info
-- /user/1
-- /test/(.*)
function Routes:parse_path(pattern)
    local params = {}
    local new_pattern = sgsub(pattern, "/:([A-Za-z0-9_]+)", function(m)
        tappend(params, m)
        return "/([A-Za-z0-9_]+)"
    end)
    return new_pattern, params
end

function Routes:init()
    for http_method, _ in pairs(supported_http_methods) do
        self[http_method] = function(self, pattern, route_info)
            self:add(http_method, pattern, route_info)
        end
    end
    return self
end


return Routes
