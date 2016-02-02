expose("expose modules", function()
    package.path = '../?.lua;' .. package.path
    _G.lor = require("lor.lib.lor")
    _G.request = require("test.mock_request")
    _G.response = require("test.mock_response")
end)

-- remind: final handler is the last middleware that can be used to handle errors
-- it will alwayes be executed but only `err` object is not nil when error occurs
describe("if finall handler defined, it will always be executed. but maybe not the last one to make sense.", function()

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


    it("the request has no execution except for `use` middlewares.", function()
        local count = 1
        app:use("/user", function(req, res, next)
            count = 2
            next()
        end)

        app:use("/user/123", function(req, res, next)
            count = 3
            next()
        end)

        req.url = "/user/123/create"
        req.path = req.url
        req.method = "get"
        app:handle(req, res, function(err)
            count = 111
        end)
        assert.is.equals(count, 111)
    end)


    describe("the request has one successful execution. final handler execs but `err` shoule be nil.", function()
        it("test case 1", function()
            local count = 1
            app:use("/user", function(req, res, next)
                count = 2
                next()
            end)

            app:get("/user/123", function(req, res, next)
                count = 4
                next()
            end)

            req.url = "/user/123/create"
            req.path = req.url
            req.method = "get"
            app:handle(req, res, function(err)
                if err then
                    count = 222
                end
            end)
            assert.is.equals(2, count) -- not 222, because there is no err; not 4,because `/user/123/create` does not math `/user/123$`
        end)

        it("test case 2", function()
            local count = 1
            app:use("/user", function(req, res, next)
                count = 2
                next()
            end)

            app:get("/user/123", function(req, res, next)
                count = 4
                next()
            end)

            req.url = "/user/123/create"
            req.path = req.url
            req.method = "get"
            app:handle(req, res, function(err)
                assert.is_falsy(err) -- 没有发生错误，此时err为nil
                assert.is_not_true(req:is_found()) -- 没有匹配到/user/123/create
                count = 222 -- finallhandler 仍被执行
            end)
            assert.is.equals(count, 222)
        end)
    end)

    describe("the previous error middleware pass or not pass the `err` object.", function()
        it("test case 1.", function()
            local count = 1
            app:use("/user", function(req, res, next)
                count = 2
                next()
            end)

            app:use("/user/123", function(req, res, next)
                count = 3
                next()
            end)

            app:get("/user/123", function(req, res, next)
                count = 4
                error("abc")
            end)

            app:erroruse(function(err, req, res, next)
                count = 5
            end)

            req.url = "/user/123/create"
            req.path = req.url
            req.method = "get"
            app:handle(req, res, function(err) -- the `err` is nil because the previous middleware didn't pass it.
                count = 444
                if err then
                    count = 333
                end

                assert.is.equals(count, 444) --not 5 and not 333
                -- though the previous error middleware didn't perform `next`, final handler also executes but the `err` object is nil
            end)

        end)


        it("test case 2.", function()
            local count = 1
            app:use("/user", function(req, res, next)
                count = 2
                next()
            end)

            app:use("/user/123", function(req, res, next)
                count = 3
                next()
            end)

            app:get("/user/123", function(req, res, next)
                count = 4
                error("abc")
            end)

            app:erroruse(function(err, req, res, next)
                count = 5
                assert.is.equals(err, "abc")
                next(err)
            end)

            req.url = "/user/123/create"
            req.path = req.url
            req.method = "get"
            app:handle(req, res, function(err) -- the `err` is a real error because the previous middleware pass it.
                count = 333
                if err then
                    count = 222
                end
                assert.is.equals( 222,count)-- not 5 and not 333, because the previous error middleware performs `next`
            end)
        end)
    end)
end)
