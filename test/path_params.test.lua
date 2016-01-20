expose("expose modules", function()
    package.path = '../?.lua;' .. package.path
    _G.lor = require("lor.lib.lor")
    _G.request = require("lor.lib.request")
    _G.response = require("lor.lib.response")
end)

describe("test about variables parsed from path", function()

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

    it("path variables should be correct after parsed.", function()
        local id = 0
        app:use("/user", function(req, res, next)
            id = 1
            next()
        end)


        app:get("/user/:id/visit", function(req, res, next)
            next()
        end)

        req.url = "/user/123/visit"
        req.path = req.url
        req.method = "get"
        app:handle(req, res)
        --assert.is.equals(123, req.params)
    end)
end)