--
-- Author: xingxingtie
-- Date: 2018-09-18 09:48:04
-- 大厅消息

local skynet = require("skynet")
local hall = skynet.uniqueservice(true, "hall")

local M = require("handler")

function M.c2s_listTeam()
    local ret, list = skynet.call(hall, "lua", "listTeam")

    local result = {
        retCode = ret,
        teamInfoList = list
    }

    g_send("s2c_listTeam", result)
end

function M.c2s_createTeam()
    local ret, teamID = skynet.call(hall, "lua", "createTeam", g_me.getId())
    g_send("s2c_createTeam", ret)

    if ret ~= ErrorCode.OK then 
        return
    end

    --队伍创建成功后则直接进入队伍
    M.c2s_enterTeam({teamID = teamID})
end

function M.c2s_enterTeam(msg)
    local ret, result = skynet.call(hall, "lua", "enterTeam", g_me.getId(), msg.teamID)

    if ret == ErrorCode.OK then 
        result.retCode = ret
        g_send("s2c_enterTeam", result) 
    else
        g_send("s2c_enterTeam", {retCode = ret}) 
    end
end

function M.c2s_leaveTeam()
    local ret, result = skynet.call(hall, "lua", "leaveTeam", g_me.getId())

    if ret == ErrorCode.OK then 
        g_send("s2c_leaveTeam", result) 
    else
        g_send("s2c_leaveTeam", {retCode = ret}) 
    end
end

-- function M:c2s_listTeam()
--     --print("请求大厅匹配")
--     local s = skynet.queryservice(true, "hall")

--     skynet.call(s, "lua", "match", g_me:getID())    
-- end
