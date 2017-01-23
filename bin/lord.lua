package.path = './?.lua;' .. package.path

local generator = require("bin.scaffold.generator")
local lor = require("bin.scaffold.launcher")
local version = require("lor.version")

local usages = [[lor v]] .. version .. [[, a Lua web framework based on OpenResty.

Usage: lord COMMAND [OPTIONS]

Commands:
 new [name]             Create a new application
 start                  Start running app server
 stop                   Stop the server
 restart                Restart the server
 version                Show version of lor
 help                   Show help tips
 path                   Show install path
]]

local function exec(args)
    local arg = table.remove(args, 1)

    -- parse commands and options
    if arg == 'new' and args[1] then
        generator.new(args[1]) -- generate example code
    elseif arg == 'start' then
        lor.start() -- start application
    elseif arg == 'stop' then
        lor.stop() -- stop application
    elseif arg == 'restart' then
        lor.stop()
        lor.start()
    elseif arg == 'reload' then
        lor.reload()
    elseif arg == 'help' or arg == '-h' then
        print(usages)
    elseif arg == 'version' or arg == '-v' then
        print(version) -- show lor framework version
    elseif arg == nil then
        print(usages)
    else
        print("[lord] unsupported commands or options, `lord -h` to check usages.")
    end
end

return exec
