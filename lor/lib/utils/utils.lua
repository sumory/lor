local type = type
local pairs = pairs
local type = type
local mrandom = math.random
local sgsub = string.gsub


local _M = {}

function _M.clear_slash(s)
    s, _ = sgsub(s, "(/+)", "/")
    return s
end

function _M.is_table_empty(t)
    if t == nil or _G.next(t) == nil then
        return true
    else
        return false
    end
end

function _M.table_is_array(t)
    if type(t) ~= "table" then return false end
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then return false end
    end
    return true
end

function _M.mixin(a, b)
    if a and b then
        for k, v in pairs(b) do
            a[k] = b[k]
        end
    end
    return a
end

function _M.random()
    return mrandom(0, 1000)
end


return _M