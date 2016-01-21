



expose("expose modules", function()
    package.path = '../?.lua;' .. package.path
    _G.lor = require("lor.lib.lor")
    _G.request = require("test.mock_request")
    _G.response = require("test.mock_response")
end)

describe("error middleware test", function()

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


    it("error middleware should stop the left error middlewares if has no `next`.", function()
        app:use(logErrors);
        app:use(clientErrorHandler);
        app:use(errorHandler);


        local function logErrors(err, req, res, next)
            next(err)
        end


        local function clientErrorHandler(err, req, res, next)
            next(err)
        end

        local function errorHandler(err, req, res, next)
            res.status(500)
            res.render('error', { error = err })
        end
    end)


end)