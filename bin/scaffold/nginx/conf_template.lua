local _M = {}

function _M:get_ngx_conf_template()
    return [[
# user www www;
pid tmp/{{LOR_ENV}}-nginx.pid;

# This number should be at maxium the number of CPU on the server
worker_processes 4;

events {
    # Number of connections per worker
    worker_connections 4096;
}

http {
    sendfile on;
    include ./mime.types;

    {{LUA_PACKAGE_PATH}}
    lua_code_cache on;

    server {
        # List port
        listen {{PORT}};

        # Access log
        access_log logs/{{LOR_ENV}}-access.log;

        # Error log
        error_log logs/{{LOR_ENV}}-error.log;

        # this variable is for view render(lua-resty-template)
        set $template_root '';

        location /static {
            alias {{STATIC_FILE_DIRECTORY}}; #app/static;
        }

        # lor runtime
        {{CONTENT_BY_LUA_FILE}}
    }
}
]]
end

return _M
