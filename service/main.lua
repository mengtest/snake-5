local skynet = require("skynet")

local gameconfig = require("gameconfig")

local init_service = function() 
    local watchdog = skynet.uniqueservice("watchdog")
    local result = skynet.call(watchdog, "lua", "start",{
        port = gameconfig.server_port,
        maxclient = gameconfig.max_client,
        nodelay = true,
        pre_agent_num = gameconfig.pre_agent_num,
    })
end

skynet.start(function() 
    init_service()
    skynet.exit()
end)