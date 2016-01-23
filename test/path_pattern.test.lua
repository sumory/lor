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
            debug = false
        })
        Request = _G.request
        Response = _G.response
        req = Request:new()
        res = Response:new()

        count = 0

        app:use("/", function(req, res, next)
            count = 1
            next()
        end)

        app:use("/user/", function(req, res, next)
            count = 2
            next()
        end)
        app:use("/user/:id/view", function(req, res, next)
            count = 3
            next()
        end)
        app:get("/user/123/view", function(req, res, next)
            count = 4
            next()
        end)

        app:post("/book" , function(req, res, next)
            count = 5
            next()
        end)


        local testRouter = lor:Router() -- 一个新的router，区别于主router
        testRouter:get("/get", function(req, res, next)
            count = 6
            next()
        end)
        testRouter:post("/foo/bar", function(req, res, next)
            count = 7
            next()
        end)
        app:use("/test", testRouter())


        app:erroruse(function(err, req, res, next)
            assert.is_not_nil(err)
            count = 999
        end)

--        print("middleware has been initialized.")
--
--        print("testRouter's stack:")
--        local s1 = testRouter.stack
--        for i, v in ipairs(s1) do
--            print(i, v)
--        end
--
--        print("app.router's stack:")
--        local s2 = app.router.stack
--        for i, v in ipairs(s2) do
--            print(i, v)
--        end

--        1	(name:layer-898	path:/	length:3	 layer.route.name:<nil>	pattern:/	is_end:false)
--        2	(name:layer-71	path:/user/	length:3	 layer.route.name:<nil>	pattern:/user/	is_end:false)
--        3	(name:layer-901	path:/user/:id/view	length:3	 layer.route.name:<nil>	pattern:/user/([A-Za-z0-9_]+)/view/	is_end:false)
--        4	(name:layer-438	path:/user/123/view	length:3	 layer.route.name:route-898	pattern:/user/123/view$	is_end:true)
--        5	(name:layer-250	path:/book	length:3	 layer.route.name:route-670	pattern:/book$	is_end:true)
--        6	(name:layer-711	path:/test	length:3	 layer.route.name:<nil>	pattern:/test/	is_end:false)
--        7	(name:layer-231	path:/	length:4	 layer.route.name:<nil>	pattern:/	is_end:false)

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
        req.path = "/user/123/view"
        req.method = "get"
        app:handle(req, res, function(err)
            assert.is_true(req:isFound())
        end)

        assert.is.equals(4, count)
        assert.is.equals("123", req.params.id)
    end)

    it("test case 2", function()-- 404 not found
        req.path = "/user/123/view/" -- 不能匹配app:get("/user/123/view", fn()), 多了一个slash
        req.method = "get"
        app:handle(req, res, function(err)
            assert.is_not_true(req:isFound()) -- 404 not found
        end)

        assert.is.equals(3, count)
        assert.is.equals("123", req.params.id)

    end)

    it("test case 3", function()
        req.path = "/book" -- 不能匹配app:get("/user/123/view", fn()), 多了一个slash
        req.method = "get"
        app:handle(req, res)

        assert.is.equals(1, count)
        assert.is_nil( req.params.id)

        req.method = "post" -- post match
        app:handle(req, res, function(err)
            assert.is_true(req:isFound())
        end)

        assert.is.equals(5, count)
        assert.is_nil( req.params.id)
    end)

    it("test case 4", function()
        req.path = "/notfound" -- 不能匹配app:get("/user/123/view", fn()), 多了一个slash
        req.method = "get"
        app:handle(req, res, function(err)
            assert.is_not_true(req:isFound())
            assert.is_nil(err)
        end)

        assert.is.equals(1, count)
        assert.is_nil( req.params.id)
    end)

    it("test case 5", function() -- should be `not found`
        req.path = "/user_abc/123/view" -- 不能匹配app:get("/user/123/view", fn()), 多了一个slash
        req.method = "get"
        app:handle(req, res, function(err)
            assert.is_not_true(req:isFound())
        end)

        assert.is.equals(1, count)
        assert.is_nil( req.params.id)
    end)

    it("test case 6", function() -- should be `not found`
        req.path = "/user/123/view_mm" -- 不能匹配app:get("/user/123/view", fn()), 多了一个slash
        req.method = "get"
        app:handle(req, res, function(err)
            assert.is_not_true(req:isFound())
        end)

        assert.is.equals(2, count) -- passed 2 middleware
        assert.is_nil(req.params.id)
    end)

    it("test case 7", function() -- 404且不能解析参数
        req.path = "/user/inject/123/view"
        req.method = "get"
        app:handle(req, res, function(err)
            assert.is_not_true(req:isFound())
        end)

        assert.is.equals(2, count)
        assert.is_nil(req.params.id)
    end)

    it("test case 8", function() -- 过了3个middleware，解析了path variable，但是最后匹配不到路由，则为404
        req.path = "/user/123/view/inject"
        req.method = "get"
        app:handle(req, res, function(err)
            assert.is_not_true(req:isFound())
        end)

        assert.is.equals(3, count)
        assert.is.equals("123", req.params.id)
    end)

    it("test case 9", function() -- 过了3个middleware，解析了path variable，但是最后匹配不到路由，则为404
        req.path = "/inject/user/123/view"
        req.method = "get"
        app:handle(req, res, function(err)
            assert.is_not_true(req:isFound())
        end)

        assert.is.equals(1, count)
        assert.is.equals(nil, req.params.id)
    end)
end)
