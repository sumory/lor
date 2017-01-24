setup(function()
    _G.LOR_FRAMEWORK_DEBUG = false
end)

teardown(function()
end)

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



describe("for debug cases: ", function()
    it("a complicated example.", function()
        local n1 = t:add_node("/a/:p1/:p2/:p3/g")
        local n2 = t:add_node("/a/:p1/:p2/f/h")
        local n3 = t:add_node("/a/:p1/:p2/f")
        local n4 = t:add_node("/a/:p1/e")
        local n5 = t:add_node("/a/:p1/c/o")
        local n6 = t:add_node("/a/d/c")
        local n7 = t:add_node("/a/m")

        local m3 = t:match("/a/n/e/f/g")
        --json_view(t)
        --print(t:gen_graph())

        assert.are.same(n1, m3.node)
        assert.is.equals("n", m3.params["p1"])
        assert.is.equals("e", m3.params["p2"])
        assert.is.equals("f", m3.params["p3"])

    end)
end)




