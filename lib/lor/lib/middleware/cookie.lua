local ck = require("resty.cookie")

-- Mind:
-- base on 'lua-resty-cookie', https://github.com/cloudflare/lua-resty-cookie
-- this is the default `cookie` middleware
-- you're recommended to define your own `cookie` middleware.

-- usage example:
--    app:get("/cookie", function(req, res, next)
--        res.cookie.set({key = "c2", value = "c2_value"})
--        res.cookie.set("c1", "c1_value")
--    end)

local cookie_middleware = function(cookieConfig)
    return function(req, res, next)
		        local COOKIE, err = ck:new()
		         
		        if not COOKIE then 
		            req.cookie = {} -- all cookies
		            res._cookie = nil
		        else  
			        req.cookie = { 
			                set = function(...)
			                    local _cookie = COOKIE
			                    if not _cookie then
			                      return  ngx.log(ngx.ERR, "response#none _cookie found to write") 
			                    end
			
			                    local p = ...
			                    if type(p) == "table" then
			                        local ok, err = _cookie:set(p)
			                        if not ok then
			                           return ngx.log(ngx.ERR, err)
			                        end
			                    else
			                        local params = { ... }
			                        local ok, err = _cookie:set({
			                            key = params[1],
			                            value = params[2] or "",
			                        })
			                        if not ok then
			                          return  ngx.log(ngx.ERR, err)
			                        end
			                    end
			                end,
			                
			                get = function (name) 
			                      local _cookie = COOKIE
			                      local field, err = _cookie:get(name)
			                        
					              if not field then 
					                  return nil
					              else   
					                  return field
					              end 
			                end,
			                 
			                get_all = function ()
			                       local _cookie = COOKIE;
			                       local fields, err = _cookie:get_all();
			                       
			                       local t = {};
			                       if not fields then  
					                    return nil;
					                else 
						                for k, v in pairs(fields) do 
						                    if k and v then
						                        t[k] = v;
						                    end
						                end 
						                return t;
					                end  
			                end 
			         }
		        end
		
		        next()
      end
end

return cookie_middleware