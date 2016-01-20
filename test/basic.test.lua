--obj1 = { test = "yes" }
--obj2 = { test = "yes" }
--assert.same(obj1, obj2)
--assert.are_not.same(obj1, obj2)

--assert.is_true(true)  -- Lua keyword chained with _
--assert.is_not_true(false)

--assert.are.equal(1, 1)
--assert.are_not.equals(1, "1")

--assert.has_error(function() error("Yup,  it errored") end)
--assert.has.errors(function() error("this should fail") end)
--assert.has_no.errors(function() end)

--assert.is.truthy("Yes")
--assert.is.falsy(nil)


expose("expose modules", function()
    package.path = '../?.lua;' .. package.path
    _G.lor = require("lor.lib.lor")
    _G.request = require("lor.lib.request")
    _G.response = require("lor.lib.response")
end)

describe("basic test for common usages", function()

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

    it("objects or modules should not be nil.", function()
        assert.is.truthy(lor)
        assert.is.truthy(app)
        assert.is.truthy(Request)
        assert.is.truthy(req)
        assert.is.truthy(Response)
        assert.is.truthy(res)
    end)

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

        req.url = "http://sumory.com/user/123/create"
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

        req.url = "/user/123/create"
        req.path = req.url
        req.method = "get"
        app:handle(req, res)
        assert.is.equals(error_msg, origin_error_msg)
    end)
end)