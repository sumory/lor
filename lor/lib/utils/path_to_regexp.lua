local sgsub = string.gsub
local smatch = string.match
local gmatch = string.gmatch
local function tappend(t, v) t[#t+1] = v end

-- pattern或是uri末尾为n个/，均忽略
local _M = {}

-- 去除最后的/                         
function remotelast(s)
    s, _ = sgsub(s, "/*$", "")
    return s
end
-- 
function _M.parse_pattern(path, keys, options)
    path = remotelast(path)

    local new_pattern = sgsub(path, "/:([A-Za-z0-9_]+)", function(m)
        tappend(keys, m)
        return "/([A-Za-z0-9_]+)"
    end)

    -- 以*结尾
    local all_pattern = sgsub(new_pattern, "/(%*)", function(m)
        return "/(.*)" -- "/(.)"
    end)
    return all_pattern
end

function _M.parse_path(uri, pattern, keys)
    uri = remotelast(uri)

    local params = {}
    local isEmpty = true
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

    end
    
    return params
end

function _M.is_match(uri, pattern)
    -- print("======",  uri,pattern)
    local ok = smatch(uri, pattern)
    return ok
end


return _M

