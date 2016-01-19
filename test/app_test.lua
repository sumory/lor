local lor = require("lor.lib.lor")
local Request = require("lor.lib.request")
local Response = require("lor.lib.response")

local app = lor()

app:use("/abc", function(req, res, next)
	print("use-/abc")
    next()
    print("after /abc middleware")
end)

app:use("/abc/efg", function(req, res, next)
    print("use-/abc2")
    next()
    print("after /abc/efg middleware")
end)



app:get("/abc/efg", function(req, res, next)
	print("app.get")
	res:send("abc")
end)

app:post("/abc/efg", function(req, res, next)
    print("app.post")
    res:send("abc")
end)

app:all("/abc/efg", function(req, res, next)
    print("app.all")
    res:send("abc")
end)


app:post("/abc/post", function(req, res, next)
    print("app.post")
    res:send("efg")
end)

app:get("/abc/error", function(req, res, next)
    print("shoule be error")
    next('fsdfdsf')
end)

app:erroruse(function(err, req, res, next)
    print("errrrrrrrrrrrrrrrrror middleware", err)
    --    for k,v in pairs(err) do
    --        print(k, v)
    --    end

    res.send("ennnnnnnnnnnnnnnnnnnnnnnd with error")
end)

print("@@@@@@@@@@@@@@@中间件初始化完毕@@@@@@@@@@@@@@@@@@@")

local req = Request:new()
req.url = "/abc/efg"
req.path = req.url
local res = Response:new()

print("------------------------------------------------")
req.method = "get"
app:handle(req, res)
--print("------------------------------------------------")
--req.method = "post"
--app:handle(req, res)
--print("------------------------------------------------")
--req.method = "all"
--app:handle(req, res)
--print("------------------------------------------------")

print("------------------------------------------------")
req.url = "/abc/error"
req.path = req.url
req.method = "get"
app:handle(req, res)