
--房间消息

local skynet = require("skynet")
local ErrorCode = require("proto.errorCode")

local M = require("handler")

function M.c2s_roomInfo()
    local room = g_me.getRoomHandle()

    if not room then 
        g_send("s2c_roomInfo", {retCode = ErrorCode.NOT_IN_ROOM})
    else 
        local ret = skynet.call(g_me.getRoomHandle(), "lua", "roomInfo")    

        g_send("s2c_roomInfo", ret)
    end
end

function M.c2s_changeSeat(msg)
    local room = g_me.getRoomHandle()

    if not room then 
        g_send("s2c_changeSeat", {retCode = ErrorCode.NOT_IN_ROOM})
    else 
        local ret = skynet.call(g_me.getRoomHandle(), "lua", "changeSeat", g_me.getUserID(), msg.targetSeat)   

        if ret ~= ErrorCode.OK then 
            g_send("s2c_changeSeat", {retCode = ret})   
        end
    end
end

function M.c2s_userop(msg)
    local room = g_me:getRoom()
    if not room then return end
    skynet.call(room, "lua", "userop", g_me.getUserID(), msg)
end

function M.pingAsk(msg)
	g_send("pingAck", msg)
end