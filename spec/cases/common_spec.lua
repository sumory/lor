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

describe("basic test for common usages", function()
    it("use middleware should works.", function()
        local count = 1
        app:use("/user", function(req, res, next)
            count = 2
            next()
            count = 5
        end)

        app:use("/user/123", function(req, res, next)
            count = 3
            next()
        end)

        app:get("/user/:id/create", function(req, res, next)
            count = 4
        end)

        req.path ="/user/123/create"
        req.method = "get"
        app:handle(req, res)
        assert.is.equals(count, 5)
    end)

    it("error middleware should work.", function()
        local origin_error_msg, error_msg = "this is an error", ""
        app:use("/user", function(req, res, next)
            next()
        end)

        app:get("/user/123/create", function(req, res, next)
            next(origin_error_msg) -- let other handlers continue...
        end)

        app:erroruse(function(err, req, res, next)
            error_msg = err
        end)

        req.path = "/user/123/create"
        req.method = "get"
        app:handle(req, res)
        assert.is.equals(error_msg, origin_error_msg)
    end)
end)
