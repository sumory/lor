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


-- remind: final handler is the last middleware that could be used to handle errors
-- it will alwayes be executed but `err` object is not nil only when error occurs
describe("if finall handler defined, it will always be executed.", function()
    it("the request has no execution", function()
        local count = 1
        app:use("/user", function(req, res, next)
            count = 2
            next()
        end)

        app:use("/user/123", function(req, res, next)
            count = 3
            next()
        end)

        req.path = "/user/123/create"
        req.method = "get"
        app:handle(req, res, function(err)
            count = 111
        end)
        assert.is.equals(count, 111)
    end)

    it("404! should reach the final handler", function()
        local count = 1

        app:use("/user", function(req, res, next) -- won't enter
            count = 2
            next()
        end)

        app:get("/user/123", function(req, res, next) -- won't enter
            count = 4
            next()
        end)

        req.path = "/user/123/create" -- won't match app:get("/user/123", function...)
        req.method = "get"
        app:handle(req, res, function(err) -- 404! not found error
            assert.is_truthy(err)
            if err then
                count = 404
            end
        end)
        assert.is.equals(404, count)
    end)
end)


describe("the request has one successful execution. final handler execs but `err` should be nil.", function()
    it("test case 2", function()
        local count = 1
        app:use("/user", function(req, res, next)
            count = 2
            next()
        end)

        app:get("/user/123/create", function(req, res, next)
            count = 4
            next()
        end)

        req.path = "/user/123/create"
        req.method = "get"
        app:handle(req, res, function(err)
            assert.is_falsy(err) -- err should be nil
            assert.is_true(req:is_found()) -- matched app:get("/user/123/create")
            count = 222 --
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

        app:erroruse(function(err, req, res, next)
            count = 5
        end)

        req.path = "/user/123/create"
        req.method = "get"
        app:handle(req, res, function(err)
            assert.is.equals(count, 5) -- not found: should match error middleware, so count is 5
            count = 444
            if err then
                count = 333
            end

            assert.is.equals(count, 333)
        end)
    end)


    it("test case 2.", function()
        local count = 1

        app:get("/user/123", function(req, res, next)
            count = 4
            error("abc")
        end)

        app:erroruse(function(err, req, res, next)
            count = 5
            assert.is.equals(true, string.find(err, "abc")>0)
            next("def")
        end)

        app:erroruse(function(err, req, res, next)
            count = 6
            assert.is.equals("def", err)
            next("123")
        end)

        req.path = "/user/123"
        req.method = "get"
        app:handle(req, res, function(err)
            count = 333
            if err then
                count = 222
            end
            assert.is.equals(222, count)
        end)
    end)

    it("test case 3， when error occurs in `error middleware`, the process will jump to the final handler immediately.", function()
        app:get("/user/123", function(req, res, next)
            error("ERROR1")
        end)

        -- error middleware 1
        app:erroruse(function(err, req, res, next)
            local test_var = 1 / tonumber("error number") -- error occurs here
            next(err .. "\nERROR2") -- won't be reached
        end)

        -- error middleware 2
        -- won't be matched because an error `in error middleware` occurs before it
        app:erroruse(function(err, req, res, next)
            next(err .. "\nERROR3")
        end)

        req.path = "/user/123"
        req.method = "get"
        app:handle(req, res, function(err)
            assert.is.equals(true, string.find(err, "ERROR1") > 0)
            assert.is.equals(nil, string.find(err, "ERROR2")) -- matched `error middleware1`, but error occured
            assert.is.equals(nil, string.find(err, "ERROR3")) -- not matched `error middleware2`
            assert.is.equals(true, string.find(err, "perform arithmetic on a nil value") > 0)
        end)
    end)
end)
