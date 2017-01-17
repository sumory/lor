expose("expose modules", function()
    package.path = '../lib/?.lua;' .. '../?.lua;'.. './lib/?.lua;'  .. package.path
    _G.lor = require("lor.index")
    _G.request = require("test.mock_request")
    _G.response = require("test.mock_response")
end)

setup(function()
end)

teardown(function()
end)

before_each(function()
    lor = _G.lor
    app = lor({
        debug = false
    })
    Request = _G.request
    Response = _G.response
    req = Request:new()
    res = Response:new()
end)

after_each(function()
    lor = nil
    app = nil
    Request = nil
    Response = nil
    req = nil
    res = nil
end)

describe("not found test", function()
    it("test case 1", function()
        local count = 0
        local errorMsg = "an error occurs."
        local userRouter = lor:Router()
        print("-------", userRouter.id, type(userRouter.get))

        userRouter:get("/find/:id", function(req, res, next)
            count = 1
            error(errorMsg)
        end)

        userRouter:post("/create/:id", function(req, res, next)
            count = 2
            next(errorMsg) -- has one param, so this will pass to an error middleware
        end)

        userRouter:post("/edit/:id", function(req, res, next)
            count = 3
        end)

        app:use("/user", userRouter())


        app:use(function(req, res, next)
            count = 404
        end)

        app:erroruse("/user", function(err, req, res, next)
            count = err
            req.params.id = "22222"
            next(err) -- 继续传递，只会被下一个erroruse覆盖
        end)

        app:erroruse(function(err, req, res, next)
            --print("common error middleware", err)
            if err then -- double check
                count = err
                req.params.id = "11111111"
            end
        end)

        req.path = "/user/find/456"
        req.method = "get"
        app:handle(req, res)
        assert.is.equals(req.params.id, "11111111")
        assert.is.truthy(string.match(count, errorMsg))

        req.url = "/notfound"
        req.path = req.url
        req.method = "post"
        app:handle(req, res, function(err)
            if err then
                print(err)
            end
        end)
        assert.is.equals(404, count)
    end)

    it("test case 2", function()
        local count = 0
        local errorMsg = "an error occurs."
        local userRouter = lor:Router()

        userRouter:get("/find/:id", function(req, res, next)
            count = 1
        end)

        app:use("/user", userRouter())

        app:use(function(req, res, next)
            if req:is_found() ~= true then
                count = 404
            end
        end)

        app:erroruse(function(err, req, res, next)
            count = 500
        end)

        req.path = "/user/find/456"
        req.method = "get"
        app:handle(req, res)
        assert.is_not.equals(404, count)-- should not be 404

        req.path = "/notfound"
        req.method = "post"
        app:handle(req, res, function(err)
            if err then
                print(err)
            end
        end)
        assert.is.equals(1, count)
    end)
end)
