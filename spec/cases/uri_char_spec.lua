before_each(function()
    lor = _G.lor
    app = lor({
        debug = false
    })
    Request = _G.request
    Response = _G.response
    req = Request:new()
    res = Response:new()

    flag = 0
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

describe("uri should support `-`", function()
    it("test case 1", function()
        req.path = "/a-b-c"
        req.method = "get"
        app:get("/a-b-c", function(req, res, next)
            flag = 1
        end)
        app:handle(req, res)
        assert.is.equals(1, flag)
    end)

    it("test case 2", function()
        req.path = "/a_-b-/cde/-f"
        req.method = "get"
        app:get("/a_-b-/cde/-f", function(req, res, next)
            flag = 2
        end)
        app:handle(req, res)
        assert.is.equals(2, flag)
    end)

    it("test case 3", function()
        req.path = "/a_-b-%"
        req.method = "get"
        app:get("/a_-b-%", function(req, res, next)
            flag = 3
        end)
        app:handle(req, res)
        assert.is.equals(3, flag)
    end)
end)
