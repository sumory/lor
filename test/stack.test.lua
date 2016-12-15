expose("expose modules", function()
    package.path = '../lib/?.lua;' .. '../?.lua;'.. './lib/?.lua;'  .. package.path
    _G.lor = require("lor.index")
    _G.request = require("test.mock_request")
    _G.response = require("test.mock_response")
end)

describe("router usages test", function()

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

    it("test case 1", function()
        local count = 1

        app:use("/", function(req, res, next)
            next()
        end)
        assert.is.equals(1, #app.router.stack)

        app:use("/user", function(req, res, next)
            next()
        end)
        assert.is.equals(2, #app.router.stack)

        app:use("/user/:id/view", function(req, res, next)
            next()
        end)
        assert.is.equals(3, #app.router.stack)

        app:get("/user/123/view", function(req, res, next)
            next()
        end)
        assert.is.equals(4, #app.router.stack)

        app:post("/book" , function(req, res, next)
            next()
        end)
        assert.is.equals(5, #app.router.stack)


        local testRouter = lor:Router() -- 一个新的router，区别于主router
        testRouter:get("/get", function(req, res, next)
            next()
        end)
        testRouter:post("/foo/bar", function(req, res, next)
            next()
        end)
        assert.is.equals(2, #testRouter.stack)
        assert.is.equals(5, #app.router.stack)

        app:use("/test", testRouter())
        assert.is.equals(6, #app.router.stack)
    end)
end)

--
--router.lua#new:	(name:routerr-481	stack_length:0)

--router.lua#new:	(name:routerr-461	stack_length:0)
--application.lua#use	/
--layer.lua#new:	(name:layer-425	path:/	length:3	 layer.route.name:<nil>	pattern:/)
--router.lua#use now the router(routerr-461) stack is:
--1	(name:layer-425	path:/	length:3	 layer.route.name:<nil>	pattern:/)
--router.lua#use now the router(routerr-461) stack is-------------
--
--application.lua#use	/user
--layer.lua#new:	(name:layer-285	path:/user	length:3	 layer.route.name:<nil>	pattern:/user)
--router.lua#use now the router(routerr-461) stack is:
--1	(name:layer-425	path:/	length:3	 layer.route.name:<nil>	pattern:/)
--2	(name:layer-285	path:/user	length:3	 layer.route.name:<nil>	pattern:/user)
--router.lua#use now the router(routerr-461) stack is-------------
--
--application.lua#use	/user/:id/view
--layer.lua#new:	(name:layer-885	path:/user/:id/view	length:3	 layer.route.name:<nil>	pattern:/user/([A-Za-z0-9_]+)/view)
--router.lua#use now the router(routerr-461) stack is:
--1	(name:layer-425	path:/	length:3	 layer.route.name:<nil>	pattern:/)
--2	(name:layer-285	path:/user	length:3	 layer.route.name:<nil>	pattern:/user)
--3	(name:layer-885	path:/user/:id/view	length:3	 layer.route.name:<nil>	pattern:/user/([A-Za-z0-9_]+)/view)
--router.lua#use now the router(routerr-461) stack is-------------
--
--
--app:get	/user/123/view	start init##############################
--route.lua#new:	(name:route-692	path:/user/123/view	stack_length:0)
--layer.lua#new:	(name:layer-216	path:/user/123/view	length:3	 layer.route.name:<nil>	pattern:/user/123/view)
--router.lua#route now the router(routerr-461) stack is:
--1	(name:layer-425	path:/	length:3	 layer.route.name:<nil>	pattern:/)
--2	(name:layer-285	path:/user	length:3	 layer.route.name:<nil>	pattern:/user)
--3	(name:layer-885	path:/user/:id/view	length:3	 layer.route.name:<nil>	pattern:/user/([A-Za-z0-9_]+)/view)
--4	(name:layer-216	path:/user/123/view	length:3	 layer.route.name:route-692	pattern:/user/123/view)
--router.lua#route now the router(routerr-461) stack is+++++++++++
--
--layer.lua#new:	(name:layer-257	path:/	length:3	 layer.route.name:<nil>	pattern:/)
--route.lua# now the route(route-692) stack is:
--1	(name:layer-257	path:/	length:3	 layer.route.name:<nil>	pattern:/)
--route.lua# now the route(route-692) stack is~~~~~~~~~~~~
--
--app:get	/user/123/view	end init################################
--
--
--app:post	/book	start init##############################
--route.lua#new:	(name:route-421	path:/book	stack_length:0)
--layer.lua#new:	(name:layer-961	path:/book	length:3	 layer.route.name:<nil>	pattern:/book)
--router.lua#route now the router(routerr-461) stack is:
--1	(name:layer-425	path:/	length:3	 layer.route.name:<nil>	pattern:/)
--2	(name:layer-285	path:/user	length:3	 layer.route.name:<nil>	pattern:/user)
--3	(name:layer-885	path:/user/:id/view	length:3	 layer.route.name:<nil>	pattern:/user/([A-Za-z0-9_]+)/view)
--4	(name:layer-216	path:/user/123/view	length:3	 layer.route.name:route-692	pattern:/user/123/view)
--5	(name:layer-961	path:/book	length:3	 layer.route.name:route-421	pattern:/book)
--router.lua#route now the router(routerr-461) stack is+++++++++++
--
--layer.lua#new:	(name:layer-327	path:/	length:3	 layer.route.name:<nil>	pattern:/)
--route.lua# now the route(route-421) stack is:
--1	(name:layer-327	path:/	length:3	 layer.route.name:<nil>	pattern:/)
--route.lua# now the route(route-421) stack is~~~~~~~~~~~~
--
--app:post	/book	end init################################
--
--router.lua#new:	(name:routerr-793	stack_length:0)
--route.lua#new:	(name:route-124	path:/get	stack_length:0)
--layer.lua#new:	(name:layer-852	path:/get	length:3	 layer.route.name:<nil>	pattern:/get)
--router.lua#route now the router(routerr-793) stack is:
--1	(name:layer-852	path:/get	length:3	 layer.route.name:route-124	pattern:/get)
--router.lua#route now the router(routerr-793) stack is+++++++++++
--
--layer.lua#new:	(name:layer-717	path:/	length:3	 layer.route.name:<nil>	pattern:/)
--route.lua# now the route(route-124) stack is:
--1	(name:layer-717	path:/	length:3	 layer.route.name:<nil>	pattern:/)
--route.lua# now the route(route-124) stack is~~~~~~~~~~~~
--
--route.lua#new:	(name:route-474	path:/foo/bar	stack_length:0)
--layer.lua#new:	(name:layer-900	path:/foo/bar	length:3	 layer.route.name:<nil>	pattern:/foo/bar)
--router.lua#route now the router(routerr-793) stack is:
--1	(name:layer-852	path:/get	length:3	 layer.route.name:route-124	pattern:/get)
--2	(name:layer-900	path:/foo/bar	length:3	 layer.route.name:route-474	pattern:/foo/bar)
--router.lua#route now the router(routerr-793) stack is+++++++++++
--
--layer.lua#new:	(name:layer-280	path:/	length:3	 layer.route.name:<nil>	pattern:/)
--route.lua# now the route(route-474) stack is:
--1	(name:layer-280	path:/	length:3	 layer.route.name:<nil>	pattern:/)
--route.lua# now the route(route-474) stack is~~~~~~~~~~~~
--
--application.lua#use	/test
--layer.lua#new:	(name:layer-497	path:/test	length:3	 layer.route.name:<nil>	pattern:/test)
--router.lua#use now the router(routerr-461) stack is:
--1	(name:layer-425	path:/	length:3	 layer.route.name:<nil>	pattern:/)
--2	(name:layer-285	path:/user	length:3	 layer.route.name:<nil>	pattern:/user)
--3	(name:layer-885	path:/user/:id/view	length:3	 layer.route.name:<nil>	pattern:/user/([A-Za-z0-9_]+)/view)
--4	(name:layer-216	path:/user/123/view	length:3	 layer.route.name:route-692	pattern:/user/123/view)
--5	(name:layer-961	path:/book	length:3	 layer.route.name:route-421	pattern:/book)
--6	(name:layer-497	path:/test	length:3	 layer.route.name:<nil>	pattern:/test)
--router.lua#use now the router(routerr-461) stack is-------------
