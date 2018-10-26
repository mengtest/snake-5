--
-- Author: xingxingtie
-- Date: 2018-09-18 09:48:04
-- 大厅消息

local skynet = require("skynet")
local hall = skynet.uniqueservice(true, "hall")
local sendData = nil

local M = {}
function M.init(sender)
    sendData = sender

    g_eventMgr:addEventListener("c2s_listTeam", handler(self, self.on_c2s_listTeam), "handlerHall")
    g_eventMgr:addEventListener("c2s_createTeam", handler(self, self.on_c2s_createTeam), "handlerHall")
    g_eventMgr:addEventListener("c2s_enterTeam", handler(self, self.on_c2s_enterTeam), "handlerHall")
    g_eventMgr:addEventListener("c2s_leaveTeam", handler(self, self.on_c2s_leaveTeam), "handlerHall")



end

function M.on_c2s_listTeam()
    local ret, list = skynet.call(hall, "lua", "listTeam")

    local result = {
        retCode = ret,
        teamInfoList = list
    }

    sendData("s2c_listTeam", result)
end

function M.on_c2s_createTeam()
    local ret, teamID = skynet.call(hall, "lua", "createTeam", g_me.getId())
    sendData("s2c_createTeam", ret)

    if ret ~= ErrorCode.OK then 
        return
    end

    --队伍创建成功后则直接进入队伍
    M.on_c2s_enterTeam({teamID = teamID})
end

function M.on_c2s_enterTeam(msg)
    local ret, result = skynet.call(hall, "lua", "enterTeam", g_me.getId(), msg.teamID)

    if ret == ErrorCode.OK then 
        result.retCode = ret
        sendData("s2c_enterTeam", result) 
    else
        sendData("s2c_enterTeam", {retCode = ret}) 
    end
end

function M.on_c2s_leaveTeam()
    local ret, result = skynet.call(hall, "lua", "leaveTeam", g_me.getId())

    if ret == ErrorCode.OK then 
        sendData("s2c_leaveTeam", result) 
    else
        sendData("s2c_leaveTeam", {retCode = ret}) 
    end
end

-- function M:on_c2s_listTeam()
--     --print("请求大厅匹配")
--     local s = skynet.queryservice(true, "hall")

--     skynet.call(s, "lua", "match", g_me:getID())    
-- end

return M
