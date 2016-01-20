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

    describe("path variables should be correct after parsed", function()
        it("test case 1.", function()
            app:use("/user", function(req, res, next)
                req.params.id = '1'
                next()
            end)

            app:get("/user/:id/visit", function(req, res, next)
                next()
            end)

            req.url = "/user/3/visit"
            req.path = req.url
            req.params = {
                trackId = 1
            }
            req.method = "get"
            app:handle(req, res)
            assert.is.equals('3', req.params.id)
        end)

        it("test case 2.", function()
            app:use("/user", function(req, res, next)
                req.params.id = '1'
                next()
            end)

            app:get("/user/:id/visit", function(req, res, next)
                next()
                req.params.id = '2'
            end)

            req.url = "/user/3/visit"
            req.path = req.url
            req.params = {
                trackId = 1
            }
            req.method = "get"
            app:handle(req, res)
            assert.is.equals('2', req.params.id)
        end)

        it("test case 3.", function()
            app:use("/user", function(req, res, next)
                req.params.id = '1'
                next()
            end)

            app:get("/user/:id/visit", function(req, res, next)
                error("error occurs")
                req.params.id = '2'
            end)


            app:erroruse("/user/:id/visit", function(err, req, res, next)
                req.params.id = 'error'
            end)

            req.url = "/user/3/visit"
            req.path = req.url
            req.method = "get"
            app:handle(req, res)
            assert.is.equals('error', req.params.id)
        end)

        it("test case 4.", function()
            app:use("/user", function(req, res, next)
                req.params.id = '1'
                next()
                req.params.id = 'return'
            end)

            app:get("/user/:id/visit", function(req, res, next)
                error("error occurs")
                req.params.id = '2'
            end)


            app:erroruse("/user/:id/visit", function(err, req, res, next)
                req.params.id = 'error'
            end)

            req.url = "/user/3/visit"
            req.path = req.url
            req.method = "get"
            app:handle(req, res)
            assert.is.equals('return', req.params.id)
        end)

    end)
end)