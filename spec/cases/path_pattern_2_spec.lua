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
    match = 1

    app:get("/all", function(req, res, next)
        count = 1
    end)

    local testRouter = lor:Router()
    testRouter:get("/all", function(req, res, next)
        count = 6
        match = 2
        next()
    end)
    testRouter:get("/find/:type", function(req, res, next)
        count = 7
        next()
    end)
    app:use("/test", testRouter())

end)

after_each(function()
    lor = nil
    app = nil
    Request = nil
    Response = nil
    req = nil
    res = nil
    match = nil
end)

describe("path match test", function()
    it("test case 1", function()
        req.path = "/test/all"
        req.method = "get"
        app:handle(req, res)
        assert.is.equals(2, match)
        assert.is.equals(6, count)
    end)

    it("test case 2", function()
        req.path = "/test/find/all"
        req.method = "get"
        app:handle(req, res)
        assert.is.equals(1, match) -- should not match "/test/all"
        assert.is.equals(7, count)
    end)

    it("test case 3", function()
        req.path = "/test/find/all/1"
        req.method = "get"
        app:erroruse(function(err, req, res, next) -- 404 error
            assert.is.truthy(err)
            assert.is.equals(false, req:is_found())
        end)
        app:handle(req, res)
        assert.is.equals(1, match)
        assert.is.equals(0, count)
    end)
end)
