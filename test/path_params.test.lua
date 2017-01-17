expose("expose modules", function()
    package.path = '../lib/?.lua;' .. '../?.lua;'.. './lib/?.lua;'  .. package.path
    _G.lor = require("lor.index")
    _G.request = require("test.mock_request")
    _G.response = require("test.mock_response")
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

describe("test about variables parsed from path", function()
    describe("path variables should be correct after parsed", function()
        it("test case 1.", function()
            app:use("/user", function(req, res, next)
                req.params.default_var = "user"
                next()
            end)

            app:get("/user/:id/visit", function(req, res, next)
                next()
            end)

            req.path = "/user/3/visit"
            req.method = "get"
            app:handle(req, res)

            assert.is.equals('3', req.params.id)
            assert.is.equals("user", req.params.default_var)
        end)

        it("test case 2.", function()
            app:use("/user", function(req, res, next)
                assert.is.equals(nil, req.params.id)
                next()

                assert.is.equals(2, req.params.id)
            end)

            app:get("/user/:id/visit", function(req, res, next)
                    print("___________")
                assert.is.equals(3, req.params.id)
                req.params.id = 2
            end)

            req.path = "/user/3/visit"
            req.method = "get"

            app:handle(req, res)
            assert.is.equals(2, req.params.id)
        end)

        it("test case 3.", function()
            app:get("/user/:id/visit", function(req, res, next)
                error("error occurs")
                req.params.id = '2'
            end)

            app:erroruse("/user/:id/visit", function(err, req, res, next)
                assert.is_not_nil(err)
                req.params.id = 'error'
            end)

            req.path = "/user/3/visit"
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

            req.path = "/user/3/visit"
            req.method = "get"

            app:handle(req, res)
            assert.is.equals('return', req.params.id)
        end)

        it("test case 5.", function()
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

            req.path = "/user/3/visit"
            req.method = "get"
            app:handle(req, res, function(err)
                req.params.id = "from final handler"
            end)
            assert.is.equals('return', req.params.id)
        end)
    end)
end)
