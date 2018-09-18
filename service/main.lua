local skynet = require("skynet")
local skynet = require("skynet.manager")

local gameconfig = require("gameconfig")

local init_service = function() 

    local watchdog = skynet.uniqueservice("watchdog")

    local hall = skynet.uniqueservice(true, "hall")
    skynet.call(hall, "lua", "start")

    local result = skynet.call(watchdog, "lua", "start", {
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