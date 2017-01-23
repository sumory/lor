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

describe("path match: ", function()
    it("should succeed to match colon node.", function()
        local n1 = t:add_node("/a/:name")

        local m1 = t:match("/a/b")
        assert.are.same(n1, m1.node)
        local m2 = t:match("/a/demo")
        assert.are.same(n1, m2.node)
        assert.is.equals("demo", m2.params.name)

        t.strict_route = false
        local m3 = t:match("/a/mock/")
        assert.are.same(n1, m3.node)
        assert.is.equals("mock", m3.params["name"])

        t.strict_route = true
        m3 = t:match("/a/mock/")
        assert.are.same(nil, m3.node)
    end)
end)

describe("path matched pipeline: ", function()
    it("should get correct pipeline.", function()
        local n0 = t:add_node("/a")
        local n1 = t:add_node("/a/b")
        local n2 = t:add_node("/a/b/c")

        local m1 = t:match("/a/b/c")
        assert.are.same(n2, m1.node)

        local p1 = m1.pipeline
        assert.is.equals(4, #m1.pipeline)
        assert.is.equals(t.root.id, p1[1].id)
        assert.is.equals(n0.id, p1[2].id)
        assert.is.equals(n1.id, p1[3].id)
        assert.is.equals(n2.id, p1[4].id)
    end)

    it("slash node not included in pipeline.", function()
        local slash_node = t:add_node("/")
        local n0 = t:add_node("/a")
        local n1 = t:add_node("/a/b")
        local n2 = t:add_node("/a/b/c")

        local m1 = t:match("/a/b/c") -- won't match slash_node
        assert.are.same(n2, m1.node)

        local p1 = m1.pipeline
        assert.is_not.equals(5, #m1.pipeline)
        assert.is.equals(4, #m1.pipeline)
        for i, v in ipairs(p1) do
            assert.is_not.equals(slash_node.id, v.id)
        end
    end)

    it("pipeline contains the right parent node.", function()
        local n1 = t:add_node("/a/b/c")

        local m1 = t:match("/a/b/c")
        assert.are.same(n1, m1.node)

        local p1 = m1.pipeline
        assert.is.equals(4, #m1.pipeline)
        assert.is.equals(t.root.id, p1[1].id)
        assert.is.equals(n1.parent.parent.id, p1[2].id)
        assert.is.equals(n1.parent.id, p1[3].id)
        assert.is.equals(n1.id, p1[4].id)
    end)

    it("children pipelines should contain same parents node.", function()
        local n1 = t:add_node("/a/b/c")
        local colon_n1 = t:add_node("/a/b/:name")

        local m1 = t:match("/a/b/c")
        assert.are.same(n1, m1.node)

        local m2 = t:match("/a/b/sumory")
        assert.are.same(colon_n1, m2.node)

        local p1 = m1.pipeline
        assert.is.equals(4, #m1.pipeline)
        assert.is.equals(t.root.id, p1[1].id)
        assert.is.equals(n1.parent.parent.id, p1[2].id)
        assert.is.equals(n1.parent.id, p1[3].id)
        assert.is.equals(n1.id, p1[4].id)

        local p2 = m2.pipeline
        assert.is.equals(4, #m2.pipeline)
        assert.is.equals(t.root.id, p2[1].id)
        assert.is.equals(colon_n1.parent.parent.id, p2[2].id)
        assert.is.equals(colon_n1.parent.id, p2[3].id)
        assert.is.equals(colon_n1.id, p2[4].id)

        assert.is.equals(p1[1].id, p2[1].id)
        assert.is.equals(p1[2].id, p2[2].id)
        assert.is.equals(p1[3].id, p2[3].id)
        assert.is_not.equals(p1[4].id, p2[4].id)
    end)
end)


describe("use cases that are hard to understand: ", function()
    it("absolute & colon node math.", function()
        local n1 = t:add_node("/a/b/c")
        local colon_n1 = t:add_node("/a/b/:name")

        local m1 = t:match("/a/b/c")
        assert.are.same(n1, m1.node)

        local m2 = t:match("/a/b/sumory")
        assert.are.same(colon_n1, m2.node)

    end)

    it("confused prefix node", function()
        local n1 = t:add_node("/people/:id")
        local n2 = t:add_node("/people/list/:id")

        local m1 = t:match("/people/1")
        assert.are.same(n1, m1.node)
        local m11 = t:match("/people/abc")
        assert.are.same(n1, m11.node)

        local m2 = t:match("/people/abc/123")
        assert.are.same(nil, m2.node)

        local m3 = t:match("/people/list/123")
        assert.are.same(n2, m3.node)
    end)

    it("children pipelines should contain same parents node.", function()
        local n1 = t:add_node("/a/b/c")
        local colon_n1 = t:add_node("/a/b/:name")

        local m1 = t:match("/a/b/c")
        assert.are.same(n1, m1.node)
    end)
end)


