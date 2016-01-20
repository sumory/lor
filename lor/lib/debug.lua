local pcall = pcall
local type = type

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
    elseif table_is_array(info) then
        for i, v in ipairs(info)
        do
            print( v)
        end
    else
        print('debug function not works.')
    end
end

return debug