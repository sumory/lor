expose("expose modules", function()
    package.path = '../../?.lua;' .. package.path
    _G.lor = require("lor.index")
    _G.request = require("test.mock_request")
    _G.response = require("test.mock_response")
end)

describe("next function usages test", function()

    setup(function()
    end)

    teardown(function()
    end)

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


    it("test case 1", function()

        app:use("/", function(req, res, next)
            next()
        end)

        app:use("/user", function(req, res, next)
            next()
        end)
        app:use("/user/:id/view", function(req, res, next)
            next()
        end)
        app:get("/user/123/view", function(req, res, next)
            next()
        end)

        app:post("/book" , function(req, res, next)
            next()
        end)


        local testRouter = lor:Router() -- 一个新的router，区别于主router
        testRouter:get("/get", function(req, res, next)
            next()
        end)
        testRouter:post("/foo/bar", function(req, res, next)
            next()
        end)
        app:use("/test", testRouter())


        app:erroruse(function(err, req, res, next)
            assert.is_not.null(err)
        end)


        -- start test...
        req.path = "/user/123/view"
        req.method = "get"
        app:handle(req, res)
    end)
end)
