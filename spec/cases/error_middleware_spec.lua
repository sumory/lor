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


describe("error middleware test:", function()
    it("error middleware should stop the left error middlewares if has no `next`.", function()
        local count = 1
        app:use("/user", function(req, res, next)
            count = 2
            next()
        end)

        app:use("/user/123", function(req, res, next)
            count = 3
            next()
        end)

        app:get("/user/123/create", function(req, res, next)
            count = 4
            error("an error occurs")
        end)

        app:erroruse(function(err, req, res, next)
            count = 5
        end)

        app:erroruse(function(err, req, res, next)
            count = 100
        end)

        req.path = "/user/123/create"
        req.method = "get"
        app:handle(req, res)
        assert.is.equals(count, 5)
    end)

    it("error middleware should continue the left error middlewares if has `next`.", function()
        local count = 1
        app:use("/user", function(req, res, next)
            count = 2
            next()
        end)

        app:use("/user/123", function(req, res, next)
            count = 3
            next()
        end)

        app:get("/user/123/create", function(req, res, next)
            count = 4
            error("an error occurs")
        end)

        app:erroruse(function(err, req, res, next)
            count = 5
            next(err)
        end)

        app:erroruse(function(err, req, res, next)
            assert.is.truthy(err)
            count = 100
        end)

        req.path = "/user/123/create"
        req.method = "get"
        app:handle(req, res)
        assert.is.equals(count, 100)
    end)

    describe("if finall handler defined, it will always be executed", function()
        it("error middleware should continue the left error middlewares if has `next`.", function()
            local count = 1
            app:use("/user", function(req, res, next)
                count = 2
                next()
            end)

            app:use("/user/123", function(req, res, next)
                count = 3
                next()
            end)

            req.path = "/user/123/create"
            req.method = "get"
            app:handle(req, res, function(err)
                count = 111
            end)
            assert.is.equals(count, 111)
        end)
    end)
end)
