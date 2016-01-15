local error = error
local pairs = pairs
local setmetatable = setmetatable

local template = require "lor.thirdparty.resty.template"

local View = {}

function View:new(view_config)
    ngx.var.template_root = view_config.path 
    local instance = {
        view_config = view_config,
    }
    setmetatable(instance, {__index = self})
    return instance
end

function View:caching()
end

-- to optimize
function View:render(view_file, data)

	local view_file_name = view_file .. self.view_config.suffix

    local t = template.new(view_file_name)
    if type(data) == 'table' then
        for k,v in pairs(data) do
            t[k] = v
        end
    end
  
    return tostring(t)
end

return View