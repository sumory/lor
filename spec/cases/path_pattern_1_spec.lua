before_each(function()
    lor = _G.lor
    app = lor({
        debug = false
    })
    Request = _G.request
    Response = _G.response
    req = Request:new()
    res = Response:new()

    count = 0

    app:use("/", function(req, res, next)
        count = 1
        next()
    end)

    app:use("/user/", function(req, res, next)
        count = 2
        next()
    end)
    app:use("/user/:id/view", function(req, res, next)
        count = 3
        next()
    end)
    app:get("/user/123/view", function(req, res, next)
        count = 4
        next()
    end)

    app:post("/book" , function(req, res, next)
        count = 5
        next()
    end)

    local testRouter = lor:Router() -- 一个新的router，区别于主router
    testRouter:get("/get", function(req, res, next)
        count = 6
        next()
    end)
    testRouter:post("/foo/bar", function(req, res, next)
        count = 7
        next()
    end)
    app:use("/test", testRouter())

    app:erroruse(function(err, req, res, next)
        count = 999
    end)
end)

after_each(function()
    lor = nil
    app = nil
    Request = nil
    Response = nil
    req = nil
    res = nil
end)

describe("next function usages test", function()
    it("test case 1", function()
        req.path = "/user/123/view"
        req.method = "get"
        app:handle(req, res, function(err)
            assert.is_true(req:is_found())
        end)

        assert.is.equals(4, count)
        assert.is.equals(nil, req.params.id)
    end)

    it("test case 2", function() -- route found
        app:conf("strict_route", false) -- 设置为非严格匹配
        req.path = "/user/123/view/" -- match app:get("/user/123/view", fn())
        req.method = "get"
        app:handle(req, res, function(err)
            assert.is_true(req:is_found())
        end)

        assert.is.equals(4, count)
        assert.is.equals(nil, req.params.id)
    end)

    it("test case 3", function()
        req.path = "/book"
        req.method = "get"
        app:handle(req, res)

        assert.is.equals(999, count)
        assert.is_nil( req.params.id)

        req.method = "post" -- post match
        app:handle(req, res, function(err)
            assert.is_true(req:is_found())
        end)

        assert.is.equals(5, count)
        assert.is_nil( req.params.id)
    end)

    it("test case 4", function()
        req.path = "/notfound"
        req.method = "get"
        app:handle(req, res, function(err)
            assert.is_not_true(req:is_found())
            assert.is_nil(err)
        end)

        assert.is.equals(999, count)
        assert.is_nil(req.params.id)
    end)
end)
