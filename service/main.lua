local skynet = require("skynet")
local skynet = require("skynet.manager")

local gameconfig = require("gameconfig")

local init_service = function() 
    --db server
    local dbserver = skynet.uniqueservice("database")
    skynet.call(dbserver, "lua", "start")

    --login server
    local loginserver = skynet.uniqueservice("login")
    skynet.call(loginserver, "lua", "start")    

    local watchdog = skynet.uniqueservice("watchdog")

    local hall = skynet.uniqueservice(true, "hall")
    --skynet.call(hall, "lua", "start")

    local result = skynet.call(watchdog, "lua", "start", {
        port = gameconfig.server_port,
        maxclient = gameconfig.max_client,
        nodelay = true,
        pre_agent_num = gameconfig.pre_agent_num,
    }, loginserver)

    skynet.newservice("debug_console", "192.168.147.128", 8000)
end

skynet.start(function() 
    init_service()
    skynet.exit()
end)