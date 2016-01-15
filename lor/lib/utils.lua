local pcall = pcall
local pairs = pairs
local require = require
local type = type
local iopen = io.open
local sfind = string.find
local sgsub = string.gsub
local smatch = string.match
local ssub = string.sub
local append = table.insert
local concat = table.concat

local format_util = require 'lor.lib.format_util'

local Utils = {}

-- read file
function Utils.read_file(file_path)
    local f = iopen(file_path, "rb")
    local content = f:read("*a")
    f:close()
    return content
end


local function require_module(module_name)
    return require(module_name)
end


-- try to require
function Utils.try_require(module_name, default)
    local ok, module_or_err = pcall(require_module, module_name)

    if ok == true then return module_or_err end

    if ok == false and smatch(module_or_err, "'" .. module_name .. "' not found") then
        return default
    else
        error(module_or_err)
    end
end


function Utils.print(var)
    print(format_util.p(var))
end

function Utils.format_var(var)
    return format_util.p(var)
end


function Utils.dirname(str)
    if str:match(".-/.-") then
        local name = string.gsub(str, "(.*/)(.*)", "%1")
        return name
    else
        return ''
    end
end

return Utils