local pcall = pcall
local type = type
local pairs = pairs
local tostring = tostring
local sformat = string.format
local tunpack = table.unpack
local tconcat = table.concat
local tinsert = table.insert
local getmetatable = getmetatable


function serialize(t)
    local mark = {}
    local assign = {}

    local function ser_table(tbl, parent)
        mark[tbl] = parent
        local tmp = {}
        for k, v in pairs(tbl) do
            local key = (type(k) == "number" and "\"[" .. k .. "]\"" or k)
            if type(v) == "table" then
                if getmetatable(v) and type(v.__tostring) == "function" then
                    tinsert(tmp, key .. ":" .. tostring(v))
                else
                    local dotkey = parent .. (type(k) == "number" and key or "." .. key)
                    if mark[v] then
                        tinsert(assign, dotkey .. ":" .. mark[v])
                    else
                        tinsert(tmp, key .. ":" .. ser_table(v,dotkey))
                    end
                end
            else
                if type(v) == "string" then
                    v = sformat("%q", v)
                end
                tinsert(tmp, key .. ":" .. tostring(v))
            end
        end
        return "{" .. tconcat(tmp, ",") .. "}"
    end

    return ser_table(t, "")
end

local function debug(...)
    if not LOR_FRAMEWORK_DEBUG then
        return
    end

    local info = { ... }
    if next(info) then
        if type(info[1]) == 'function' then
            pcall(function() info[1]() end)
        else
            print(serialize(info))
        end
    else
        print("debug not works...")
    end
end

return debug
