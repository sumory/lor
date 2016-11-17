local pcall = pcall
local type = type
local pairs = pairs


local function debug(...)
    if not LOR_FRAMEWORK_DEBUG then
        return
    end

    local info = { ... }
    if next(info) then
        if type(info[1]) == 'function' then
            pcall(function() info[1]() end)
        elseif type(info[1]) == 'table' then
            for i, v in pairs(info[1]) do
                print(i, v)
            end
        else
            print(...)
        end
    else
        print("debug not works...")
    end
end

return debug