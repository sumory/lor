expose("expose modules", function()
    package.path = '../?.lua;' .. package.path
    _G.lor = require("lor.lib.lor")
    _G.request = require("test.mock_request")
    _G.response = require("test.mock_response")
end)

describe("error middleware test", function()

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

        req.url = "/user/123/create"
        req.path = req.url
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

        req.url = "/user/123/create"
        req.path = req.url
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

            req.url = "/user/123/create"
            req.path = req.url
            req.method = "get"
            app:handle(req, res, function(err)
                count = 111
            end)
            assert.is.equals(count, 111)
        end)
    end)
end)