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


describe("group index route: basic usages", function()
    it("should be error when giving wrong params", function()
        local flag = 0
        local test_router = lor:Router()

        assert.has_error(function() test_router:get() end, "params should not be nil or empty")
        assert.has_error(function() test_router:get({}) end, "params should not be nil or empty")

        assert.has_error(function() test_router:get("/test") end, "it must be an function if there's only one param")
        assert.has_error(function() test_router:get("/test", "abc") end)
    end)

    it("uri should mathed", function()
        local flag = 0

        local test_router = lor:Router()
        test_router:get(function(req, res, next)
            flag = 1
        end)

        app:use("/test", test_router())

        req.path = "/test"
        req.method = "get"
        app:handle(req, res)
        assert.is.equals(1, flag)
    end)

    it("uri should not mathed", function()
        local flag = 0

        local test_router = lor:Router()
        test_router:get(function(req, res, next)
            flag = 1
        end)

        app:use("/test", test_router())
        app:erroruse(function(err, req, res, next) -- 404 error
            assert.is.truthy(err)
            assert.is.equals(false, req:is_found())
            flag = 999
        end)

        req.path = "/test/"
        req.method = "get"
        app:handle(req, res)
        assert.is.equals(999, flag)
    end)
end)


describe("group index route: multi funcs", function()
    it("array params", function()
        local flag = 0
        local test_router = lor:Router()
        local func1 = function(req, res, next)
            flag = 1
            next()
        end
        local func2 = function(req, res, next)
            flag = 2
            next()
        end
        local last_func = function(req, res, next)
            flag = 3
        end
        test_router:post({func1, func2, last_func})
        app:use("/test", test_router())

        req.path = "/test"
        req.method = "post"
        app:handle(req, res)
        assert.is.equals(3, flag)
    end)

    it("unpacked params", function()
        local flag = 0
        local test_router = lor:Router()
        local func1 = function(req, res, next)
            flag = 1
            next()
        end
        local func2 = function(req, res, next)
            flag = 2
            next()
        end
        local last_func = function(req, res, next)
            flag = 3
        end
        test_router:put(func1, func2, last_func)
        app:use("/test", test_router())

        req.path = "/test"
        req.method = "put"
        app:handle(req, res)
        assert.is.equals(3, flag)
    end)

    it("mixed params, case1", function()
        local flag = 0
        local test_router = lor:Router()
        local func1 = function(req, res, next)
            flag = 1
            next()
        end
        local func2 = function(req, res, next)
            flag = 2
            next()
        end
        local last_func = function(req, res, next)
            flag = 3
        end
        test_router:get({func1, func2}, last_func)
        app:use("/test", test_router())

        req.path = "/test"
        req.method = "get"
        app:handle(req, res)
        assert.is.equals(3, flag)
    end)

    it("mixed params, case2", function()
        local flag = 0
        local test_router = lor:Router()
        local func1 = function(req, res, next)
            flag = 1
            next()
        end
        local func2 = function(req, res, next)
            flag = 2
            next()
        end
        local last_func = function(req, res, next)
            flag = 3
        end
        test_router:put({func1}, func2, {last_func})
        app:use("/test", test_router())

        req.path = "/test"
        req.method = "put"
        app:handle(req, res)
        assert.is.equals(3, flag)
    end)
end)
