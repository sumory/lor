local sgsub = string.gsub
local smatch = string.match
local gmatch = string.gmatch
local function tappend(t, v) t[#t+1] = v end
local debug = require("lor.lib.debug")

-- pattern或是uri末尾为n个/，均忽略
local _M = {}

-- 去除多余的/
function _M.clear_slash(s)
    s, _ = sgsub(s, "(/+)", "/")
    return s
end
--
function _M.parse_pattern(path, keys, options)
    path = _M.clear_slash(path)

    local new_pattern = sgsub(path, "/:([A-Za-z0-9._-]+)", function(m)
        tappend(keys, m)
        return "/([A-Za-z0-9._-]+)"
    end)

    -- 以*结尾
    local all_pattern = sgsub(new_pattern, "/(%*)", function(m)
        return "/(.*)" -- "/(.)"
    end)
    return all_pattern
end

function _M.parse_path(uri, pattern, keys)
    uri = _M.clear_slash(uri)

    local params = {}
    local match = { smatch(uri, pattern) } -- param values
    if #match > 0 then -- uri match some route
        for j = 1, #match do
            if match[j] then
                local param_name = keys[j]
                if param_name then
                    params[param_name] = match[j]
                end
            end
        end
    else
        debug("path_to_regexp.lua#parse_path not match", uri, pattern)
    end
    return params
end

function _M.is_match(uri, pattern)
    debug("path_to_regexp.lua#is_match, uri:", uri, "pattern:", pattern)
    if not pattern then
        debug("empty pattern")
        return false
    end

    local ok = smatch(uri, pattern)
    if ok then return true else return false end
end


return _M

