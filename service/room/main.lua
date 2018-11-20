--
-- Author: xingxingtie
-- Date: 2018-09-17 11:57:43
-- 房间服务主类 一个服务就是一个房间
require("common.init")
local skynet = require("skynet")
local room = require("room")
local game = require("game")

skynet.start(function()
    skynet.dispatch("lua", function(_, _, cmd, ...)
        local f = room[cmd] or game[cmd]
        if f then 
            skynet.ret(skynet.pack(f(...)))
            return 
        else 
            skynet.error("can't find cmd in room:", cmd)
        end        
    end)
end)