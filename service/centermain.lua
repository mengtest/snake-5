--中心服务器
--游戏服务器会将自己的ip 和 游戏端口告知中心服务器，玩家开启游戏时会在中心服务器处拿到开服列表

local skynet = require("skynet")
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