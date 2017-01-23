before_each(function()
    lor = _G.lor
    app = lor({
        debug = true
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

describe("not found test, error middleware and final handler should be reached correctly.", function()
    it("test case 1", function()
        local count = 0
        local errorMsg = "an error occurs."

        local userRouter = lor:Router()
        userRouter:get("/find/:id", function(req, res, next)
            count = 1
            error(errorMsg)
        end)
        app:use("/user", userRouter())

        app:erroruse("/user", function(err, req, res, next)
            count = err
            req.params.id = "2222"
            next(err)
        end)

        app:erroruse(function(err, req, res, next)
            count = err
            req.params.id = "1111"
        end)

        req.path = "/user/find/456"
        req.method = "get"
        app:handle(req, res)
        assert.is.equals(req.params.id, "1111")
        assert.is.equals(true, string.find(count, errorMsg) > 1)
    end)

    it("test case 2", function()
        local count = 0
        local errorMsg = "an error occurs."

        local userRouter = lor:Router()
        userRouter:get("/find/:id", function(req, res, next)
            count = 1
            error(errorMsg)
        end)
        app:use("/user", userRouter())

        app:erroruse("/user", function(err, req, res, next)
            count = err
            req.params.id = "2222"
            next(err)
        end)

        app:erroruse(function(err, req, res, next)
            count = "stop exec final handler"
            req.params.id = "1111"
            -- next(err) -- not invoke it, the final handler will not be reached!
        end)

        req.params.id = nil --empty it
        req.path = "/user/notfound"
        req.method = "post"
        app:handle(req, res, function(err)
            if err then
                count = "not found error catched"
            end
        end)

        assert.is.equals(404, res.http_status)
        assert.is.equals(req.params.id, "1111")
        assert.is.equals("stop exec final handler", count)
    end)

    it("test case 3", function()
        local count = 0
        local errorMsg = "an error occurs."

        local userRouter = lor:Router()
        userRouter:get("/find/:id", function(req, res, next)
            count = 1
            error(errorMsg)
        end)
        app:use("/user", userRouter())

        app:erroruse("/user", function(err, req, res, next)
            count = err
            req.params.id = "2222"
            next(err)
        end)

        app:erroruse(function(err, req, res, next)
            count = "stop exec final handler"
            req.params.id = "1111"
            next(err) -- invoke it, the final handler will be reached!
        end)

        req.params.id = nil --empty it
        req.path = "/notfound"
        req.method = "post"
        app:handle(req, res, function(err)
            req.params.id = "3333"
            if err then
                count = "not found error catched"
            end
        end)
        --print(app.router.trie:gen_graph())
        assert.is.equals(404, res.http_status)
        assert.is.equals(req.params.id, "3333")
        assert.is.equals("not found error catched", count)
    end)
end)
