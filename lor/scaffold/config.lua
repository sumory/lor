local ogetenv = os.getenv
local lor_conf = require 'lor.config'


local scaffold_conf = {}

scaffold_conf.version = lor_conf.version
scaffold_conf.env = ogetenv("LOR_ENV") or 'dev'
scaffold_conf.app_dirs = { -- runtime nginx conf/pid/logs dir
    tmp = 'tmp',
    logs = 'logs'
}

return scaffold_conf