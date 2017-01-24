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
                assert.is.equals("3", req.params.id)
                next()
            end)

            app:get("/user/:id/visit", function(req, res, next)
                req.params.id = 5
                next()
            end)

            req.path = "/user/3/visit"
            req.method = "get"

            app:handle(req, res)
            assert.is.equals(5, req.params.id)
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

    describe("path variables should be correctly parsed when the next request comes", function()
        it("test case 1.", function()
            app:use("/todo", function(req, res, next)
                if req.params.id == "33" then
                    req.params.id = '3'
                elseif req.params.id == "44" then
                    req.params.id = "4"
                elseif req.params.id == "55" then
                    req.params.id = "5"
                end
                next()
            end)

            app:post("/todo/delete/:id", function(req, res, next)
                --print(req.params.id)
            end)

            req.path = "/todo/delete/33"
            req.method = "post"
            app:handle(req, res)
            assert.is.equals('3', req.params.id)

            req.path = "/todo/delete/44"
            req.method = "post"
            app:handle(req, res)
            assert.is.equals('4', req.params.id)

            req.url = "/todo/delete/55"
            req.path = req.url
            req.method = "post"
            app:handle(req, res)
            assert.is.equals('5', req.params.id)
        end)

        it("test case 2.", function()
            app:use("/todo", function(req, res, next)
                next()
            end)

            app:post("/todo/view/:id/:name", function(req, res, next)
            end)

            req.path = "/todo/view/44/two"
            req.method = "post"
            app:handle(req, res)
            assert.is.equals('44', req.params.id)
            assert.is.equals('two', req.params.name)

            req.path = "/todo/view/55/three"
            req.method = "post"
            app:handle(req, res)
            assert.is.equals('55', req.params.id)
            assert.is.equals('three', req.params.name)
        end)
    end)
end)
