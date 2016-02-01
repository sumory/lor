expose("expose modules", function()
    package.path = '../?.lua;' .. package.path
    _G.lor = require("lor.lib.lor")
    _G.request = require("test.mock_request")
    _G.response = require("test.mock_response")
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

    describe("path variables should be correctly parsed when the next request comes", function()
        it("test case 1.", function()
            app:use("/todo", function(req, res, next)
                req.params.id = '2'
                next()
            end)

            app:post("/todo/delete/:id", function(req, res, next)
            end)


            req.url = "/todo/delete/33"
            req.path = req.url
            req.method = "post"
            app:handle(req, res)
            assert.is.equals('33', req.params.id)


            req.url = "/todo/delete/44"
            req.path = req.url
            req.method = "post"
            app:handle(req, res)
            assert.is.equals('44', req.params.id)

            req.url = "/todo/delete/55"
            req.path = req.url
            req.method = "post"
            app:handle(req, res)
            assert.is.equals('55', req.params.id)
        end)

        it("test case 2.", function()
            app:use("/todo", function(req, res, next)
                req.params.id = '2'
                next()
            end)

            app:post("/todo/view/:id/:name", function(req, res, next)
            end)


            req.url = "/todo/view/44/two"
            req.path = req.url
            req.method = "post"
            app:handle(req, res)
            assert.is.equals('44', req.params.id)
            assert.is.equals('two', req.params.name)


            req.url = "/todo/view/55/three"
            req.path = req.url
            req.method = "post"
            app:handle(req, res)
            assert.is.equals('55', req.params.id)
            assert.is.equals('three', req.params.name)
        end)
    end)
end)