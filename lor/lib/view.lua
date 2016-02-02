local error = error
local pairs = pairs
local type = type
local setmetatable = setmetatable
local tostring = tostring
local template = require "resty.template"
local template_new = template.new


local View = {}

function View:new(view_config)
    ngx.var.template_root =  view_config.views
    local instance = {}
    instance.view_engine = view_config.view_engine
    instance.view_ext = view_config.view_ext
    instance.views = view_config.views

    setmetatable(instance, {__index = self})
    return instance
end

function View:caching()
end

-- to optimize
function View:render(view_file, data)
    local view_file_name = view_file .. "." .. self.view_ext

    local t = template_new(view_file_name)
    if data and type(data) == 'table' then
        for k,v in pairs(data) do
            t[k] = v
        end
    end

    return tostring(t)
end


return View