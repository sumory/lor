local error = error
local pairs = pairs
local type = type
local setmetatable = setmetatable
local tostring = tostring
local utils = require("lor.lib.utils.utils")
local template = require "resty.template"
local template_helper = require("lor.lib.utils.template_helper")
local template_new = template.new


local View = {}

function View:new(view_config)
    local instance = {}

    instance.view_enable = view_config.view_enable
    if instance.view_enable then
        if ngx.var.template_root then
            ngx.var.template_root =  view_config.views
        else
            ngx.log(ngx.ERR, "$template_root is not set in nginx.conf")
        end
    end

    instance.view_engine = view_config.view_engine
    instance.view_ext = view_config.view_ext
    instance.views = view_config.views
    instance.view_func = view_config.view_func

    setmetatable(instance, {__index = self})
    return instance
end

function View:caching()
end

-- to optimize
function View:render(view_file, data)
    if not self.view_enable then
        ngx.log(ngx.ERR, "view is not enabled. you may need `app:conf('view enable', true)`")
    else
        local view_file_name = view_file .. "." .. self.view_ext

        local t = template_new(view_file_name)

        local view_func = utils.table_merge(template_helper,self.view_func)

        if data and type(data) == 'table' then

            data = utils.table_merge(view_func,data)

            for k,v in pairs(data) do
                t[k] = v
            end

            --
        end

        return tostring(t)
    end
end


return View
