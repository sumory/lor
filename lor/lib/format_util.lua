local M = {}

local color = {
    r = "\27[1;31m",
    g = "\27[1;32m",
    y = "\27[1;33m",
    b = "\27[1;34m",
    p = "\27[1;35m"
}

-- type to color
local ttc = {
    ['nil']      = 'r',
    ['boolean']  = 'y',
    ['number']   = 'g',
    ['string']   = 'b',
    ['function'] = 'p'
}

local cn = "\27[0m"

--- print the indent
local function pi(indent)
    return string.rep("  ", indent)
end

--- print next line
local function pl()
    return "\n"
end

--- print the variable
local function pv(var, c)
    if c and color[c] then
        return color[c] .. tostring(var) .. cn
    else
        return tostring(var)
    end
end

--- print the table
local function pt(var, indent)
    local result = pv('{') .. pl()

    for k, v in pairs(var) do
        result = result .. pi(indent + 1) .. pv('[') .. pv(k, ttc[type(k)]) .. pv(']   ')

        local t = type(v)
        if t == 'table' then
            result = result .. pt(v, indent + 1)
        else
            result = result .. pv(v, ttc[t]) .. pl()
        end
    end

    result = result .. pi(indent) .. pv('}') .. pl()
    return result
end

function M.p(var)
    local t = type(var)

    if t == 'table' then
        return pt(var, 0)
    else
        return pv(var, ttc[t]) .. pl()
    end
end

return M