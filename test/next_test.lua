package.path = "../?.lua;" .. package.path

local lor = require("lor.index")
local Request = require("test.mock_request")
local Response = require("test.mock_response")

local app = lor()

app:use("/abc", function(req, res, next)
    print("use-/abc1")
    next()
    print("after /abc/efg middleware111")
end)

app:use("/abc/error", function(req, res, next)
    print("use-/abc2")
    next()
    print("after /abc/efg middleware")
end)


app:get("/abc/error", function(req, res, next)
    print("shoule be error start ..")
    next("fsdfsdf")
    print("shoule be error end ..")
end)


app:get("/abc/error1", function(req, res, next)
    print("shoule be error start2 ..")
    error("fsdfsdffdfasdfdsafdsfsafsdafsdfsafsafd")
    print("shoule be error end2 ..")
end)

app:erroruse( function(err, req, res, next)
    print("errrrrrrrrrrrrrrrrror middleware", err)
    res:send("ennnnnnnnnnnnnnnnnnnnnnnd with error")
    next(err)
end)
app:erroruse( function(err, req, res, next)
    print("errrrr2", err)
    res:send("ennnnnnnd error2")

end)

print("@@@@@@@@@@@@@@@init middlewares finished@@@@@@@@@@@@@@@@@@@")

local req = Request:new()
local res = Response:new()


print("------------------------------------------------")
req.url = "/abc/error"
req.path = req.url
req.method = "get"
app:handle(req, res)