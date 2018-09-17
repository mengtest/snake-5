--
-- Author: xingxingtie
-- Date: 2018-09-17 11:57:43
-- 房间服务主类 一个服务就是一个房间
require("common.init")
local skynet = require("skynet")

local param = {...}
local CMD = {}

function CMD.start()
    g_room = require("room").new()
end

skynet.start(function()
    skynet.dispatch("lua", function(_, _, cmd, ...)
        local f = CMD[cmd]
        if f then 
            skynet.ret(skynet.pack(f(...)))
            return 
        end

        local f = g_room[cmd]
        if f then 
            skynet.ret(skynet.pack(f(g_room, ...)))
            return 
        end        
    end)
end)