expose("expose modules", function()
    package.path = '../?.lua;' .. package.path
    _G.lor = require("lor.lib.lor")
end)

describe("group router middleware test", function()

    setup(function()
    end)

    teardown(function()
    end)

    before_each(function()
        lor = _G.lor
        app = lor({
            debug = false
        })
    end)

    after_each(function()
        lor = nil
        app = nil
    end)

    it("objects or modules should not be nil.", function()
        assert.is.truthy(lor)
        assert.is.truthy(app)
    end)

    describe("single group router middleware", function()

        it("basic usage", function()
            local count = 0
            local userRouter = lor:Router()

            userRouter:get("/find/:id", function(req, res, next)
                count = 1
                next()
            end)

            userRouter:post("/create/:id", function(req, res, next)
                count = 2
                next()
            end)

            app:use("/user", userRouter())

            -- shoule not be reached, because `next` has no params and no error occurs
            app:erroruse(function(err, req, res, next)
                count = 3
            end)


            -- start mock test
            local req = lor:Request()
            local res = lor:Response()

            req.url = "/user/create/123"
            req.path = req.url
            req.method = "post"
            app:handle(req, res)
            assert.is.equals(2, count)


            req.url = "/user/find/123"
            req.path = req.url
            req.method = "get"
            app:handle(req, res)
            assert.is.equals(1, count)
        end)


        it("error middleware should work as normal", function()
            local count = 0
            local errorMsg = "an error occurs."
            local userRouter = lor:Router()

            userRouter:get("/find/:id", function(req, res, next)
                count = 1
                error(errorMsg)
            end)

            userRouter:post("/create/:id", function(req, res, next)
                count = 2
                next(errorMsg) -- has one param, so this will pass to an error middleware
            end)

            userRouter:post("/edit/:id", function(req, res, next)
                count = 3
            end)

            app:use("/user", userRouter())

            app:erroruse(function(err, req, res, next)
                if err then -- double check
                count = err
                req.params.id = "11111111"
                end
            end)


            -- start mock test
            local req = lor:Request()
            local res = lor:Response()

            req.url = "/user/find/456"
            req.path = req.url
            req.method = "get"
            app:handle(req, res)
            assert.is.truthy(string.match(count, errorMsg))

            req.url = "/user/create/123"
            req.path = req.url
            req.method = "post"
            app:handle(req, res)
            assert.is.truthy(string.match(count, errorMsg)) -- count contains errorMsg


            req.url = "/user/edit/987"
            req.path = req.url
            req.method = "post"
            app:handle(req, res)
            assert.is.equals(3, count) -- no error occurs
        end)

        it("path variable parser should work", function()
            local count = 0
            local errorMsg = "an error occurs."
            local userRouter = lor:Router()

            userRouter:get("/find/:id", function(req, res, next)
                count = 1
                error(errorMsg)
            end)

            userRouter:post("/create/:id", function(req, res, next)
                count = 2
                next(errorMsg) -- has one param, so this will pass to an error middleware
            end)

            userRouter:post("/edit/:id", function(req, res, next)
                count = 3
            end)

            app:use("/user", userRouter())

            app:erroruse("/user", function(err, req, res, next)
                --print("user error middleware", err)
                --if err then -- double check
                    count = err
                    req.params.id = "22222"
                --end
                next(err) -- 继续传递，只会被下一个erroruse覆盖
            end)

            app:erroruse(function(err, req, res, next)
                --print("common error middleware", err)
                if err then -- double check
                    count = err
                    req.params.id = "11111111"
                end
            end)


            -- start mock test
            local req = lor:Request()
            local res = lor:Response()

            req.url = "/user/find/456"
            req.path = req.url
            req.method = "get"
            app:handle(req, res)
            assert.is.equals("11111111", req.params.id)
            assert.is.truthy(string.match(count, errorMsg))

            req.url = "/user/create/123"
            req.path = req.url
            req.method = "post"
            app:handle(req, res)
            assert.is.equals("11111111", req.params.id)
            assert.is.truthy(string.match(count, errorMsg)) -- count contains errorMsg


            req.url = "/user/edit/987"
            req.path = req.url
            req.method = "post"
            app:handle(req, res)
            assert.is.equals("987", req.params.id)
            assert.is.equals(3, count)
        end)
    end)


    describe("multi group router middleware", function()
        it("basic usage", function()
            local flag = ""
            local userRouter = lor:Router()
            local bookRouter = lor:Router()

            app:use(function(req, res, next)
                flag = "first use"
                req.params.flag = "origin value"
                next()
            end)

            userRouter:get("/find/:id", function(req, res, next)
                flag = 1
                req.params.flag = 1
                next("error occurs")
            end)

            userRouter:post("/create/:id", function(req, res, next)
                flag = 2
                req.params.flag = 2
                next()
            end)

            bookRouter:get("/view/:id", function(req, res, next)
                flag = 3
                req.params.flag = 3
                error("common error")
                req.params.flag = 33
            end)

            app:use("/user", userRouter()) -- must invoke before `erroruse`
            app:use("/book", bookRouter()) -- must invoke before `erroruse`

            app:erroruse("/user", function(err, req, res, next)
                --print("------------- user error m", err)
                assert.is.truthy(err)
                flag = "user_error_middleware"
                req.params.flag = 111
            end)

            app:erroruse(function(err, req, res, next)
                --print("------------- common error m", err)
                flag = "common_error_middleware"
                req.params.flag = 333
                assert.is.truthy(err)
            end)

            -- start mock test
            local req = lor:Request()
            local res = lor:Response()

            req.url = "/user/create/123"
            req.path = req.url
            req.method = "post"
            app:handle(req, res)
            assert.is.equals(2, flag)
            assert.is.equals(2, req.params.flag)


            req.url = "/user/find/123"
            req.path = req.url
            req.method = "get"
            app:handle(req, res)
            assert.is.equals("user_error_middleware", flag)
            assert.is.equals(111, req.params.flag)

            req.url = "/book/view/999"
            req.path = req.url
            req.method = "get"
            app:handle(req, res, function(err)
                if err then
                    print(err)
                end
                -- not found path will be here
                -- not processed error will be here
            end)
            assert.is.equals("common_error_middleware", flag)
            assert.is.equals(333, req.params.flag)
        end)
    end)
end)