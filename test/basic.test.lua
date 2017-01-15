expose("expose modules", function()
    package.path = '../lib/?.lua;' .. '../?.lua;'.. './lib/?.lua;'  .. package.path
    _G.lor = require("lor.index")
    _G.request = require("test.mock_request")
    _G.response = require("test.mock_response")

    _G.Trie = require("lor.lib.trie")
    _G.Node = require("lor.lib.node")

    _G.json_view = function(t)
        local cjson
        pcall(function() cjson = require("cjson") end)
        if not cjson then
            print("\n[cjson should be installed...]\n")
        else
            if t.root then
                t:remove_nested_property(t.root)
                print("\n", cjson.encode(t.root), "\n")
            else
                t:remove_nested_property(t)
                print("\n", cjson.encode(t), "\n")
            end
        end
    end

    _G._debug = nil
    pcall(function() _G._debug = require("lor.lib.debug") end)
    if not _G._debug then
        _G._debug = print
    end
end)

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

describe("basic test for common usages", function()
    it("use middleware should works.", function()
        local count = 1
        app:use("/user", function(req, res, next)
            count = 2
            next()
            count = 5
        end)

        app:use("/user/123", function(req, res, next)
            count = 3
            next()
        end)

        app:get("/user/:id/create", function(req, res, next)
            count = 4
        end)



        req.url = "http://sumory.com/user/123/create"
        req.path ="/user/123/create"
        req.method = "get"
        app:handle(req, res)
        json_view(app.router.trie)
        ---assert.is.equals(count, 5)
    end)

    -- it("error middleware should work.", function()
    --     local origin_error_msg, error_msg = "this is an error", ""
    --     app:use("/user", function(req, res, next)
    --         next()
    --     end)

    --     app:get("/user/123/create", function(req, res, next)
    --         next(origin_error_msg) -- let other handlers continue...
    --     end)

    --     app:erroruse(function(err, req, res, next)
    --         error_msg = err
    --     end)

    --     req.url = "/user/123/create"
    --     req.path = req.url
    --     req.method = "get"
    --     app:handle(req, res)
    --     assert.is.equals(error_msg, origin_error_msg)
    -- end)
end)
