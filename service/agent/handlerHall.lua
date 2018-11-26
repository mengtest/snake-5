--
-- Author: xingxingtie
-- Date: 2018-09-18 09:48:04
-- 大厅消息

local skynet = require("skynet")
local ErrorCode = require("proto.errorCode")

local M = require("handler")

function M.c2s_listTeam()
    local ret, list = skynet.call("hall", "lua", "listTeam")

    local result = {
        retCode = ret,
        teamInfoList = list
    }

    g_send("s2c_listTeam", result)
end

function M.c2s_createTeam()
    local ret, teamID = skynet.call("hall", "lua", "createTeam", g_me.getUserID())
    g_send("s2c_createTeam", ret)

    if ret ~= ErrorCode.OK then 
        return
    end

    --队伍创建成功后则直接进入队伍
    M.c2s_enterTeam({teamID = teamID})
end

function M.c2s_enterTeam(msg)
    local ret, result = skynet.call("hall", "lua", "enterTeam", g_me.getUserID(), msg.teamID)

    if ret == ErrorCode.OK then 
        result.retCode = ret
        g_send("s2c_enterTeam", result) 
    else
        g_send("s2c_enterTeam", {retCode = ret}) 
    end
end

function M.c2s_leaveTeam()
    local ret, result = skynet.call("hall", "lua", "leaveTeam", g_me.getUserID())

    if ret == ErrorCode.OK then 
        g_send("s2c_leaveTeam", result) 
    else
        g_send("s2c_leaveTeam", {retCode = ret}) 
    end
end

--房间---------------------------------------------------
function M.c2s_listRoom()
    local ret, size =  skynet.call("hall", "lua", "listRoom")

    ret = skynet.unpack(ret, size)

    g_send("s2c_listRoom", {retCode = ErrorCode.OK, roomList = ret})  
end

function M.c2s_createRoom()
    local ret, roomID = skynet.call("hall", "lua", "createRoom", g_me.getUserID())

    g_send("s2c_createRoom", {retCode = ret}) 

    --创建房间之后立马进入房间
    if ret == ErrorCode.OK then 
        M.c2s_enterRoom({roomID = roomID})
    end
end

function M.c2s_enterRoom(msg)
    local ret, roomID = skynet.call("hall", "lua", "enterRoom", msg.roomID, g_me.getUserID())    

    if ret == ErrorCode.OK then 
    
        g_me.setRoomHandle(roomID)

        g_send("s2c_enterRoom", {retCode = ret, roomId = roomID}) 
    else
        g_send("s2c_enterRoom", {retCode = ret}) 
    end
end