before_each(function()
    Trie = _G.Trie
    t = Trie:new()
    t1 = Trie:new()
    t2 = Trie:new()
end)

after_each(function()
    Trie = nil
    t = nil
    t1 = nil
    t2 = nil
    _debug = nil
end)

describe("complex use cases: ", function()
    it("should match the correct colon node.", function()
        local n1 = t:add_node("/a/b/c/e")
        local colon_n1 = t:add_node("/a/b/:name/d")

        local m1 = t:match("/a/b/c/d")
        --print(t:gen_graph())
        assert.are.same(colon_n1, m1.node)
    end)

    it("same prefix while different suffix.", function()
        local n1 = t:add_node("/a/b/c/e/f")
        local colon_n1 = t:add_node("/a/b/:name/d/g")
        local colon_n2 = t:add_node("/a/b/:name/e/f")

        local m1 = t:match("/a/b/c/d/g")
        assert.are.same(colon_n1, m1.node)

        local m2 = t:match("/a/b/other/e/f")
        assert.are.same(colon_n2, m2.node)
    end)

    it("confused prefix node", function()
        local n1 = t:add_node("/people/:id")
        local n2 = t:add_node("/people/list/:id")
        local n3 = t:add_node("/people/list")

        local m1 = t:match("/people/123")
        assert.are.same(n1, m1.node)

        local m2 = t:match("/people/list")
        assert.are.same(n3, m2.node)

        local m3 = t:match("/people/list/123")
        assert.are.same(n2, m3.node)

        local m4 = t:match("/people/list/123/456")
        assert.are.same(nil, m4.node)
    end)

    it("should succeed to match colon & common node.", function()
        local n1 = t:add_node("/user")
        local n2 = t:add_node("/user/123")
        local n3 = t:add_node("/user/:id/create")

        local m1 = t:match("/user/123/create")
        assert.are.same(n3, m1.node) -- should not match n2
        assert.is.equals("123", m1.params["id"])
    end)

    it("a complicated example.", function()
        local n1 = t:add_node("/a/:p1/:p2/:p3/g")
        local n2 = t:add_node("/a/:p1/:p2/f/h")
        local n3 = t:add_node("/a/:p1/:p2/f")
        local n4 = t:add_node("/a/:p1/e")
        local n5 = t:add_node("/a/:p1/c/o")
        local n6 = t:add_node("/a/d/c")
        local n7 = t:add_node("/a/m")

        local m1 = t:match("/a/d/c/o")
        local m2 = t:match("/a/n/e/f")
        local m3 = t:match("/a/n/e/f/g")

        assert.are.same(n5, m1.node)
        assert.is.equals("d", m1.params["p1"])

        assert.are.same(n3, m2.node)
        assert.is.equals("n", m2.params["p1"])
        assert.is.equals("e", m2.params["p2"])

        assert.are.same(n1, m3.node)
        assert.is.equals("n", m3.params["p1"])
        assert.is.equals("e", m3.params["p2"])
        assert.is.equals("f", m3.params["p3"])
        
    end)
end)




