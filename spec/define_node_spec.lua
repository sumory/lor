setup(function()
    _G.LOR_FRAMEWORK_DEBUG = true
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

describe("objects check: ", function()
    it("objects or modules should not be nil.", function()
        assert.is.truthy(Trie)
        assert.is.truthy(Node)
        assert.is.truthy(t)
        assert.is.truthy(t1)
        assert.is.truthy(t2)
    end)
end)

describe("add node: ", function()
    it("wrong patterns with `/` to add.", function()
        assert.has_error(function()
            t1:add_node("//")
        end)
        assert.has_error(function()
            t1:add_node("///")
        end)
        assert.has_error(function()
            t1:add_node("/a/b//")
        end)
        assert.has_error(function()
            t1:add_node("//a/b/")
        end)
        assert.has_error(function()
            t1:add_node("/a//b/")
        end)
        assert.has_error(function()
            t1:add_node("/a///b/")
        end)
    end)

    it("wrong patterns with spaces to add.", function()
        assert.has_error(function()
            t1:add_node(" / / ")
        end)

        assert.has_error(function()
            t1:add_node("/ /")
        end)
    end)

    it("correct pattern to add.", function()
        assert.has_no_error(function()
            t1:add_node(" ") -- slim to ""
            t1:add_node("/")
            t1:add_node("")
            t1:add_node("/a")
            t1:add_node("/a/b")
            t1:add_node("/a/b/c/")
        end)

        assert.has_no.error(function()
            t1:add_node("  ")
        end)
    end)

    it("these patterns should get same node.", function()
        local node = t1:add_node("/")

        assert.is.equals(node, t1:add_node("/"))
        assert.is.equals(node, t1:add_node(""))
        assert.is.equals(t1:add_node("/"), t1:add_node(""))
        assert.is.equals(node.parent, t1.root)

        assert.is_not.equals(node, t2:add_node("/"))
        assert.is_not.equals(node, t2:add_node(""))
    end)

    it("spaces in patterns are trimed.", function()
        local node = t:add_node("/")
        assert.is.equals(node, t:add_node(" "))
        assert.is.equals(node, t:add_node("  "))
        assert.is.equals(node, t:add_node("  /"))
        assert.is.equals(node, t:add_node(" / "))

    end)
end)

describe("illegal & legal path: ", function()
    it("wrong path", function()
        assert.has_error(function()
            t:add_node("/#+")
        end)
        assert.has_error(function()
            t:add_node(":+abc")
        end)
        assert.has_error(function()
            t:add_node(":&abc")
        end)

        assert.has_error(function()
            t:add_node(":abc*")
        end)

    end)
    it("correct path", function()
        assert.has_no_error(function()
            t:add_node(":abc")
        end)
        assert.has_no_error(function()
            t:add_node("abc")
        end)
        assert.has_no_error(function()
            t:add_node("/abc")
        end)
    end)
end)

describe("node's name: ", function()
    it("check names", function()
        local node = t1:add_node("/")
        assert.is.equals(node.name, "")
    end)
end)

describe("parent/children relation: ", function()
    it("use case 1.", function()
        local node = t1:add_node("/a/b")
        assert.is.equals(node.name, "")
        assert.is.equals(node.pattern, "/a/b")

        assert.is.equals(node, t1:add_node("/a/b"))
        assert.is_not.equals(node, t1:add_node("a/b/"))
        assert.is_not.equals(node, t1:add_node("/a/b/"))
        assert.is.equals(t1:add_node("/a/b/"), t1:add_node("a/b/"))

        parent = t1:add_node("/a")
        assert.is.equals(node.parent, parent)
        assert.is_not.equals(parent.varyChild, node)
        assert.is.equals(parent:find_child("b"), node)
        child = t1:add_node("/a/b/c")
        assert.is.equals(child.parent, node)
        assert.is.equals(node:find_child("c"), child)

        assert.has_error(function()
            t1:add_node("/a//b")
        end)
    end)

    it("use case 2.", function()
        local root = t.root

        local slash_level = t:add_node("/")
        local level0 = t:add_node("/00")
        local level1 = t:add_node("/01")
        local level2 = t:add_node("/02")

        local level0_0 = t:add_node("/00/0")
        local level0_1 = t:add_node("/00/1")
        local level0_2 = t:add_node("/00/2")

        local level1_0 = t:add_node("/01/0")
        local level1_1 = t:add_node("/01/1")
        local level1_2 = t:add_node("/01/2")

        local level2_0 = t:add_node("/02/0")
        local level2_1 = t:add_node("/02/1")
        local level2_2 = t:add_node("/02/2")

        local level0_0_0 = t:add_node("/00/0/0")
        local level0_0_1 = t:add_node("/00/0/1")
        local level0_0_2 = t:add_node("/00/0/2")

        assert.is.equals(root.name, "")
        assert.is.equals(root.pattern, "")

        assert.is.equals(slash_level.name, "")
        assert.is.equals(slash_level.pattern, "/")
        assert.is.equals(level0.name, "")
        assert.is.equals(level0.pattern, "/00")

        assert.are.same(slash_level.parent, level1.parent)
        assert.are.same(level0.parent, level1.parent)
        assert.are.same(level1.parent, level2.parent)

        assert.is.equals(root, level0.parent)
        assert.is.equals(root, level1.parent)
        assert.is.equals(root, level2.parent)

        assert.is.equals(level0, level0_0.parent)
        assert.is.equals(level0_0.parent, level0_1.parent)
        assert.is.equals(level1, level1_0.parent)
        assert.is.equals(level1_0.parent, level1_1.parent)

        assert.is.equals(root, level0_0_0.parent.parent.parent)
        assert.is.equals(level0, level0_0_0.parent.parent)
    end)
end)

describe("colon child define: ", function()
    it("should failed to define conflict node.", function()
        local root = t.root

        local slash_level = t:add_node("/")
        local level0 = t:add_node("/00")

        t:add_node("/00/0")
        t:add_node("/00/0/:0")

        assert.has_error(function()
            t:add_node("/00/0/:1")
        end)

        assert.has_error(function()
            t:add_node("/00/0/:01")
        end)

        assert.has_no_error(function()
            t:add_node("/00/0/absolute")
        end)
    end)

    it("should succeed to define not conflict nodes.", function()
        local root = t.root

        local slash_level = t:add_node("/")
        local level0 = t:add_node("/00")

        t:add_node("/00/0")
        t:add_node("/00/0/:0")

        assert.has_no_error(function()
            t:add_node("/00/0/absolute")
        end)

        assert.has_no_error(function()
            t:add_node("/00/0/123")
        end)

        assert.has_no_error(function()
            t:add_node("/00/0/123/456")
        end)
    end)
end)

describe("shadow child define: ", function()
    it("should failed to define conflict node.", function()
        local level0_0_0 = t:add_node("/00/0/:0")
        local level0_0_0_shadow = t:add_node("/00/0/:0")
        local level0_0_0_shadow2 = t:add_node("/00/0/:0")
        assert.is.equals(level0_0_0, level0_0_0_shadow)
        assert.is.equals(level0_0_0_shadow, level0_0_0_shadow2)
    end)
end)

describe("regex node define: ", function()
    it("should failed to define error regex node.", function()
        assert.has_error(function()
           t:add_node("/a/:(^abc)")
        end)
        assert.has_error(function()
           t:add_node("/a/(^abc)")
        end)
        assert.has_error(function()
           t:add_node("/a/:abc(^abc")
        end)
        assert.has_error(function()
           t:add_node("/a/:abc^abc)")
        end)
    end)
    it("should succeed to define regex node.", function()
        assert.has_no_error(function()
           t:add_node("/a/:b(^abc)")
        end)
        assert.has_no_error(function()
           t:add_node("/a/b/:c(^abc)")
        end)
       

        local n1 = t:add_node("/a/:b(^abc)")
        assert.is.equals("^abc", n1.regex)
    end)
end)


describe("just for dev, print json/tree : ", function()
    it("case 1.", function()
        local root = t.root

        local slash_level = t:add_node("/")
        local level0 = t:add_node("/00")
        local level0_0 = t:add_node("/00/0")

        local level0_0_1 = t:add_node("/00/0/1")

        local level0_0_0 = t:add_node("/00/0/:0")
        local level0_0_0_shadow = t:add_node("/00/0/:0")
        assert.is.equals(level0_0_0, level0_0_0_shadow)
        
    end)
end)

