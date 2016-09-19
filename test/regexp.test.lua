expose("expose modules", function()
    package.path = '../?.lua;' .. package.path
    _G.Regexp = require("lor.lib.utils.path_to_regexp")
end)

describe("path match and parse rule test", function()

    setup(function()
    end)

    teardown(function()
    end)

    before_each(function()
        Regexp = _G.Regexp
    end)

    after_each(function()
        Regexp = nil
    end)

    it("objects or modules should not be nil.", function()
        assert.is.truthy(Regexp)
    end)

    it("method:parse_pattern should work.", function()
        local keys = {}
        local path_to_parse_pattern = "/foo/:bar/create/:id/done"
        local dest_pattern = "/foo/([A-Za-z0-9_.-]+)/create/([A-Za-z0-9_.-]+)/done"
        local pattern = Regexp.parse_pattern(path_to_parse_pattern, keys)
        assert.is.equals(#keys, 2)
        assert.is.truthy(pattern)

        assert.is.equals(keys[1], "bar")
        assert.is.equals(keys[2], "id")

        assert.is.equals(pattern, dest_pattern)
    end)

    it("method:parse_path should work.", function()
        local keys = {}
        local path_to_parse_pattern = "/user/:who/do/:what/done"
        local pattern = Regexp.parse_pattern(path_to_parse_pattern, keys)

        local path1 = "/user/sumory/do/1/done"
        local params = Regexp.parse_path(path1, pattern, keys)
        assert.is.equals(2, #keys)
        assert.is.equals(params["who"], "sumory")
        assert.is.equals(params["what"], "1")
    end)

    it("method:clear_slash should work.", function()
        local p1, p1_expected = "/a///foo//", "/a/foo/"
        local p1_removed = Regexp.clear_slash(p1)
        assert.is.equals(p1_removed, p1_expected)

        local p2, p2_expected = "/abc/foo///", "/abc/foo/"
        local p2_removed = Regexp.clear_slash(p2)
        assert.is.equals(p2_removed, p2_expected)
    end)

    it("method:is_math should work.", function()
        local p1, p2, p3 = "/foo/abc", "/foo/abcde/134/5", "/foo"
        local pattern = "/foo/.*"
        assert.is_true(Regexp.is_match(p1, pattern))
        assert.is_true(Regexp.is_match(p2, pattern))
        assert.is_not_true(Regexp.is_match(p3, pattern))
    end)


end)
