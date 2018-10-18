include "config.path"

-- preload = "./examples/preload.lua"   -- run preload.lua before every lua service run
thread = 4
logger = nil
logpath = "."
harbor = 1
address = "127.0.0.1:2526"
master = "127.0.0.1:2013"
start = "centermain"                  -- main script
bootstrap = "snlua bootstrap"   -- The service for bootstrap
standalone = "0.0.0.0:2013"
-- snax_interface_g = "snax_g"
cpath = "./3rd/skynet/cservice/?.so"
-- daemon = "./skynet.pid"

max_client = 64
server_port = 8886