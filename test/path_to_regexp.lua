local sgsub = string.gsub
local smatch = string.match
local gmatch = string.gmatch
local function tappend(t, v) t[#t+1] = v end

-- pattern或是uri末尾为n个/，均忽略


-- 去除最后的/                         
function remotelast(s)
    s, _ = sgsub(s, "/*$", "")
    return s
end
-- 
function parse_pattern(path, keys, options)
	path = remotelast(path)

    local new_pattern = sgsub(path, "/:([A-Za-z0-9_]+)", function(m)
        tappend(keys, m)
        return "/([A-Za-z0-9_]+)"
    end)

    -- 以*结尾
    local all_pattern = sgsub(new_pattern, "/(%*)", function(m)
		return "/(.*)" -- "/(.)"
	end)
    return all_pattern, keys
end

-- pattern.exec
function parse_path(uri, pattern, keys)
	uri = remotelast(uri)

    local params = {}
    local isEmpty = true
    local match = { smatch(uri, pattern) } -- param values
    if #match > 0 then -- uri match some route
        for j = 1, #match do
            local param_name = keys[j]
            if param_name then
                params[param_name] = match[j]
                isEmpty = false
            end
        end    
    end
    
    if isEmpty then return nil else return params end
end

function is_match(pattern, uri)
	local ok = false


end


function test1()
	local keys = {}
	local p, t = parse_pattern("/foo/:bar/create/:id/done", keys)
	print('pattern: ' .. p)
	for k,v in pairs(t) do
		print(k .. ' ' .. v)
	end
	print("--------------")
	local params = parse_path("/foo/bar_value/create/123/done", p, t)
	for k,v in pairs(params) do
		print(k .. ' ' .. v)
	end
end

function test1_1()
	local keys = {}
	local p, t = parse_pattern("/foo/:bar/create/:id/done/", keys)
	print('pattern: ' .. p)
	for k,v in pairs(t) do
		print(k .. ' ' .. v)
	end
	print("--------------")
	local params = parse_path("/foo/bar_value/create/123/done", p, t)
	for k,v in pairs(params) do
		print(k .. ' ' .. v)
	end
end

function test2()
	local keys = {}
	local p, t = parse_pattern("/foo/:id/*", keys)
	print('pattern: ' .. p)
	for k,v in pairs(t) do
		print(k .. ' ' .. v)
	end
	print("--------------")
	local params = parse_path("/foo/123/ddfd/mmm", p, t)
	for k,v in pairs(params) do
		print(k .. ' ' .. v)
	end
end


function test()
	test1()
	print()
	test1_1()
	print()
	test2()
end

print(string.match("abcdabcd", "%w+i$"))

