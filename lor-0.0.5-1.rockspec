package = "lor"
version = "0.0.5-1"
source = {
   url = "git://github.com/sumory/lor.git"
}
description = {
   homepage = "http://lor.sumory.com",
   maintainer = "sumory<sumory.wu@gmail.com>",
   detailed = "A fast and minimalist web framework based on OpenResty",
   license = "MIT"
}
dependencies = {
    "lua>=5.1"
}
build = {
   type = "builtin",
   modules = {
      ["bin.scaffold.generator"] = "bin/scaffold/generator.lua",
      ["bin.scaffold.launcher"] = "bin/scaffold/launcher.lua",
      ["bin.scaffold.nginx.conf_template"] = "bin/scaffold/nginx/conf_template.lua",
      ["bin.scaffold.nginx.config"] = "bin/scaffold/nginx/config.lua",
      ["bin.scaffold.nginx.directive"] = "bin/scaffold/nginx/directive.lua",
      ["bin.scaffold.nginx.handle"] = "bin/scaffold/nginx/handle.lua",
      ["bin.scaffold.utils"] = "bin/scaffold/utils.lua",
      ["lor.index"] = "lor/index.lua",
      ["lor.lib.application"] = "lor/lib/application.lua",
      ["lor.lib.debug"] = "lor/lib/debug.lua",
      ["lor.lib.lor"] = "lor/lib/lor.lua",
      ["lor.lib.methods"] = "lor/lib/methods.lua",
      ["lor.lib.middleware"] = "lor/lib/middleware/init.lua",
      ["lor.lib.middleware.cookie"] = "lor/lib/middleware/cookie.lua",
      ["lor.lib.middleware.params"] = "lor/lib/middleware/params.lua",
      ["lor.lib.middleware.session"] = "lor/lib/middleware/session.lua",
      ["lor.lib.request"] = "lor/lib/request.lua",
      ["lor.lib.response"] = "lor/lib/response.lua",
      ["lor.lib.router.layer"] = "lor/lib/router/layer.lua",
      ["lor.lib.router.route"] = "lor/lib/router/route.lua",
      ["lor.lib.router.router"] = "lor/lib/router/router.lua",
      ["lor.lib.utils.path_to_regexp"] = "lor/lib/utils/path_to_regexp.lua",
      ["lor.lib.utils.utils"] = "lor/lib/utils/utils.lua",
      ["lor.lib.view"] = "lor/lib/view.lua",
      ["lor.lib.wrap"] = "lor/lib/wrap.lua",
      ["resty.cookie"] = "resty/cookie.lua",
      ["resty.session"] = "resty/session.lua",
      ["resty.session.ciphers.aes"] = "resty/session/ciphers/aes.lua",
      ["resty.session.ciphers.none"] = "resty/session/ciphers/none.lua",
      ["resty.session.encoders.base16"] = "resty/session/encoders/base16.lua",
      ["resty.session.encoders.base64"] = "resty/session/encoders/base64.lua",
      ["resty.session.encoders.hex"] = "resty/session/encoders/hex.lua",
      ["resty.session.serializers.json"] = "resty/session/serializers/json.lua",
      ["resty.session.storage.cookie"] = "resty/session/storage/cookie.lua",
      ["resty.session.storage.memcache"] = "resty/session/storage/memcache.lua",
      ["resty.session.storage.memcached"] = "resty/session/storage/memcached.lua",
      ["resty.session.storage.redis"] = "resty/session/storage/redis.lua",
      ["resty.session.storage.shm"] = "resty/session/storage/shm.lua",
      ["resty.template"] = "resty/template.lua",
      ["resty.template.html"] = "resty/template/html.lua",
      ["resty.template.microbenchmark"] = "resty/template/microbenchmark.lua",
      ["test.basic.test"] = "test/basic.test.lua",
      ["test.error_handler.test"] = "test/error_handler.test.lua",
      ["test.error_middleware.test"] = "test/error_middleware.test.lua",
      ["test.final_handler.test"] = "test/final_handler.test.lua",
      ["test.group_router.test"] = "test/group_router.test.lua",
      ["test.mock_request"] = "test/mock_request.lua",
      ["test.mock_response"] = "test/mock_response.lua",
      ["test.not_found.test"] = "test/not_found.test.lua",
      ["test.path_params.test"] = "test/path_params.test.lua",
      ["test.path_pattern.test"] = "test/path_pattern.test.lua",
      ["test.regexp.test"] = "test/regexp.test.lua",
      ["test.stack.test"] = "test/stack.test.lua"
   },
   install = {
        bin = {
            "bin/lord"
        }
   }
}
