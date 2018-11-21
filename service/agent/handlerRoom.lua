
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

function M.c2s_startGame(msg)
    local room = g_me.getRoomHandle()

    if not room then 
        g_send("s2c_startGame", {retCode = ErrorCode.NOT_IN_ROOM})
    else 
        local ret = skynet.call(g_me.getRoomHandle(), "lua", "gameStart", g_me.getUserID())   

        if ret ~= ErrorCode.OK then 
            g_send("s2c_startGame", {retCode = ret})   
        end
    end
end

function M.c2s_loadComplete(msg)
    local room = g_me.getRoomHandle()

    if not room then 
        return
    else 
        skynet.send(room, "lua", "loadComplete", g_me.getUserID())
    end    
end

function M.c2s_userCommand(msg)
    local room = g_me.getRoomHandle()

    if not room then 
        return
    else 
        msg.userID = g_me.getUserID()

        skynet.send(room, "lua", "userCommand", msg)
    end    
end

function M.pingAsk(msg)
	g_send("pingAck", msg)
end