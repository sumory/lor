-- most code is from https://github.com/ostinelli/gin/blob/master/gin/cli/base_launcher.lua
local function create_dirs(necessary_dirs)
    for _, dir in pairs(necessary_dirs) do
        os.execute("mkdir -p " .. dir .. " > /dev/null")
    end
end

local function create_nginx_conf(nginx_conf_file_path, nginx_conf_content)
    local fw = io.open(nginx_conf_file_path, "w")
    fw:write(nginx_conf_content)
    fw:close()
end

local function remove_nginx_conf(nginx_conf_file_path)
    os.remove(nginx_conf_file_path)
end

local function nginx_command(env, nginx_conf_file_path, nginx_signal)
    local env_cmd = ""

    if env ~= nil then env_cmd = "-g \"env LOR_ENV=" .. env .. ";\"" end
    local cmd = "nginx " .. nginx_signal .. " " .. env_cmd .. " -p `pwd`/ -c " .. nginx_conf_file_path
    print("execute: " .. cmd)
    return os.execute(cmd)
end

local function start_nginx(env, nginx_conf_file_path)
    return nginx_command(env, nginx_conf_file_path, '')
end

local function stop_nginx(env, nginx_conf_file_path)
    return nginx_command(env, nginx_conf_file_path, '-s stop')
end

local function reload_nginx(env, nginx_conf_file_path)
    return nginx_command(env, nginx_conf_file_path, '-s reload')
end


local NginxHandle = {}
NginxHandle.__index = NginxHandle

function NginxHandle.new(necessary_dirs, nginx_conf_content, nginx_conf_file_path)
    local instance = {
        nginx_conf_content = nginx_conf_content,
        nginx_conf_file_path = nginx_conf_file_path,
        necessary_dirs = necessary_dirs
    }
    setmetatable(instance, NginxHandle)
    return instance
end

function NginxHandle:start(env)
    create_dirs(self.necessary_dirs)
    -- create_nginx_conf(self.nginx_conf_file_path, self.nginx_conf_content)

    return start_nginx(env, self.nginx_conf_file_path)
end

function NginxHandle:stop(env)
    local result = stop_nginx(env, self.nginx_conf_file_path)
    -- remove_nginx_conf(self.nginx_conf_file_path)

    return result
end

function NginxHandle:reload(env)
    -- remove_nginx_conf(self.nginx_conf_file_path)
    create_dirs(self.necessary_dirs)
    -- create_nginx_conf(self.nginx_conf_file_path, self.nginx_conf_content)

    return reload_nginx(env, self.nginx_conf_file_path)
end

return NginxHandle
