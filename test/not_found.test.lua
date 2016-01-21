expose("expose modules", function()
    package.path = '../?.lua;' .. package.path
    _G.lor = require("lor.lib.lor")
end)

describe("not found test", function()
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


    it("test case 1", function()
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


        app:use(function(req, res, next)
            count = 404
        end)

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
        assert.is.equals(req.params.id, "11111111")
        assert.is.truthy(string.match(count, errorMsg))

        req.url = "/notfound"
        req.path = req.url
        req.method = "post"
        app:handle(req, res, function(err)
            if err then
                print(err)
            end
        end)
        assert.is.equals(404, count)
    end)
end)