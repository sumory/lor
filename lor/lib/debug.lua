local pcall = pcall
local type = type
local pairs = pairs
local ipairs = ipairs

local function table_is_array(t)
    if type(t) ~= "table" then return false end
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then return false end
    end
    return true
end

local function debug(...)
    if not LOR_FRAMEWORK_DEBUG then
        return
    end

    local info = { ... }
    if info and type(info[1]) == 'function' then
        pcall(function() info[1]() end)
    elseif info and type(info[1]) == 'table' then
        for i, v in pairs(info[1]) do
            print(i, v)
        end
    elseif ... ~= nil then
        print(...)
    else
        print("debug not works...")
    end
end

return debug