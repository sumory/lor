local type = type
local pairs = pairs
local type = type
local mrandom = math.random
local sgsub = string.gsub
local json = require("cjson")


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

function _M.json_encode(data, empty_table_as_object)
    local json_value
    if json.encode_empty_table_as_object then
        json.encode_empty_table_as_object(empty_table_as_object or false) -- ¿ÕµÄtableÄ¬ÈÏÎªarray
    end
    if require("ffi").os ~= "Windows" then
        json.encode_sparse_array(true)
    end
    pcall(function(data) json_value = json.encode(data) end, data)
    return json_value
end

function _M.json_decode(str)
    local ok, data = pcall(json.decode, str)
    if ok then
        return data
    end
end

return _M