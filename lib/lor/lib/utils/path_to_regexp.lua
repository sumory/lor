local sgsub = ngx.re.gsub
local smatch = ngx.re.match
local type = type
local function tappend(t, v) t[#t+1] = v end
local debug = require("lor.lib.debug")


local _M = {}

-- 去除多余的/
function _M.clear_slash(s)
    s, _ = sgsub(s, "(/+)", "/", "io")
    return s
end

--
function _M.parse_pattern(path, keys, options)
    path = _M.clear_slash(path)

    local new_pattern = sgsub(path, "/:([A-Za-z0-9._-]+)", function(m)
        if m and type(m) == 'table' then
            -- for i, v in pairs(m) do
            -- 	ngx.say(i .. " * ".. v)
            -- end
            tappend(keys, m[1])
        end

        return "/([A-Za-z0-9._-]+)"
    end, "io")

    -- 以*结尾
    local all_pattern = sgsub(new_pattern, "/[%*]+", function(m)
        return "/(.*)" -- "/(.)"
    end, "io")
    return all_pattern
end

function _M.parse_path(uri, pattern, keys)
    uri = _M.clear_slash(uri)

    local params = {}
    local match, err =  smatch(uri, pattern, "io")  -- match is nil or array, param values
    if match then
        for j = 1, #match do
            if match[j] then
                local param_name = keys[j]
                if param_name then
                    params[param_name] = match[j]
                end
            end
        end
    else
        if err then
            ngx.log(ngx.ERR, "parse_path error: ", uri, " " , pattern)
        end
    end

    return params
end

function _M.is_match(uri, pattern)
    if not uri or not pattern then
        return false
    end

    local ok, err = smatch(uri, pattern, "io")
    if ok then
        -- for i,v in ipairs(ok) do
        -- 	ngx.say(#ok , " ", ok[0] .. " " .. i .. " |-> " .. v)
        -- end
        return true
    else
        if err then
            ngx.log(ngx.ERR, "is_match error: ", uri, " ", pattern, " ",  err)
        end
        return false
    end
end


return _M

