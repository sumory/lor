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

    app:get("/hello", function(req, res, next)
        count = 1
        match = 2
    end)

    local testRouter = lor:Router()
    testRouter:get("/hello", function(req, res, next)
        match = 3
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
        req.path = "/test/hello"
        req.method = "get"
        app:handle(req, res)
        assert.is.equals(3, match)
        assert.is.equals(0, count)
    end)

    it("test case 2", function()
        req.path = "/hello"
        req.method = "get"
        app:handle(req, res)
        assert.is.equals(2, match)
    end)
end)
