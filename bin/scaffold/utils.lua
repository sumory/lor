local pcall = pcall
local require = require
local iopen = io.open
local smatch = string.match

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

function Utils.dirname(str)
    if str:match(".-/.-") then
        local name = string.gsub(str, "(.*/)(.*)", "%1")
        return name
    else
        return ''
    end
end

return Utils
