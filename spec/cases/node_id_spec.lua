before_each(function()
    Trie = require("lor.lib.trie")
    t = Trie:new()
end)

after_each(function()
    t = nil
end)

function table_size(t)
    local res = 0
    if t then
        for _ in pairs(t) do
            res = res + 1
        end
    end
    return res
end

describe("node is should be unique", function()
    it("test case 1", function()
        local count = 100
        local nodes = {}
        for i=1,count,1 do
            local node = t:add_node(tostring(i))
            table.insert(nodes, node)
        end

        assert.is.equals(count, #nodes)
        assert.is.equals(count, table_size(nodes))

        local node_map = {}
        for i=1,count,1 do
            node_map[nodes[i].id] = true
        end
        assert.is.equals(count, table_size(node_map))
    end)
end)
