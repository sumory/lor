expose("expose modules", function()
    package.path = '../lib/?.lua;' .. '../?.lua;'.. './lib/?.lua;'  .. package.path
    _G.lor = require("lor.index")
    _G.request = require("test.mock_request")
    _G.response = require("test.mock_response")
end)

describe("group router middleware test 2", function()

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
    end)

    describe("'use' the same group router middleware", function()
        it("basic usage", function()
            local userRouter = lor:Router()

            local reach_first = false
            local reach_second = false

            userRouter:get("/get", function(req, res, next)
                --print("******************/user/get******************")
                reach_first = true
                reach_second = true
            end)


            app:use("/user", userRouter())
            app:use("/u", userRouter())


            -- start mock test

            req.url = "/user/get"
            req.path = req.url
            req.method = "get"
            app:handle(req, res)
            assert.is.equals(true, reach_first)

            -- reset values
            reach_first = false
            reach_second = false

            req.url = "/u/get"
            req.path = req.url
            req.method = "get"
            app:handle(req, res)
            assert.is.equals(true, reach_second)


        end)
    end)
end)
