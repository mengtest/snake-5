--
-- Author. xingxingtie
-- Date. 2018-09-17 13.35.43
-- 大厅
local skynet = require("skynet")
local match = require("match")
local const = require("const")
local ErrorCode = require("proto.errorCode")
local team = require("team")
local protopack = require("protopack")

local M = {}
local g_playerList = {}
local g_teamList = {}

--玩家操作--------------------------------------------------
function M._packInfo(player)
    return {
        userID = player.userID,
        name   = player.name,
    }
end

function M.enter(player) 
    if g_playerList[player.id] then 
        return ErrorCode.ALREADY_IN_HALL
    end

    local p = {
        userID   = player.id,
        name     = player.name,
        handle   = player.handle,
        location = const.LOCATION_HALL,
        teamID   = nil,               --所在队伍id
        roomID   = nil,               --所在房间id
    }

    g_playerList[player.id] = p

    return ErrorCode.OK
end

--队伍操作-------------------------------------------------
function M._ifInTeam(playerID)
    local player = g_playerList[playerID]

    return (player.location & const.LOCATION_TEAM) ~= 0
end

function M.createTeam(playerID)
    if M._ifInTeam(playerID) then 
        return ErrorCode.TEAM_NOT_CREATE_TEAM
    end

    if M._ifInRoom(playerID) then 
        return ErrorCode.ROOM_NOT_CREATE_TEAM
    end

    local newTeam = team.new()
    g_teamList[newTeam.id] = newTeam

    return ErrorCode.OK, newTeam.id
end

--列出所有的队伍
function M.listTeam()
    local list = {}

    for k,v in pairs(g_teamList) do
        table.insert(list, v:_packInfo(g_playerList[v.leaderID].name)) 
    end

    return ErrorCode.OK, list
end

--进入队伍
function M.enterTeam(playerID, teamID)
    if M._ifInTeam(playerID) then 
        return ErrorCode.ALREADY_IN_TEAM
    end

    if M._ifInRoom(playerID) then 
        return ErrorCode.ALREADY_IN_ROOM
    end

    local team = g_teamList[teamID]
    if not team then 
        return ErrorCode.TEAM_NOT_EXIST
    end

    local player = g_playerList[playerID]
    player.location = player.location | const.LOCATION_TEAM
    player.teamID = teamID

    --通知其他玩家
    for k,v in ipairs(team.playerList) do 
        local player = g_playerList[v]
        skynet.call(player.handle, "lua", "send", "s2c_playerJoinTeam", M._packInfo(player))
    end

    --通知加入者
    local result = {
        leader = team.leaderID,
        userList = {},
    }
    for k,v in ipairs(team.playerList) do 
        local player = g_playerList[v]
        table.insert(result.userList, M._packInfo(player))
    end

    team:addPlayer(playerID)

    return ErrorCode.OK, result
end

--离开队伍
function M.leaveTeam(playerID)
    if not M._ifInTeam(playerID) then 
        return ErrorCode.NOT_IN_TEAM
    end

    if M._ifInRoom(playerID) then 
        return ErrorCode.ROOM_NOT_LEAVE_TEAM
    end

    local player = g_playerList[playerID]
    local team = player.teamID
    team:deletePlayer(playerID)

    local result = {
        retCode   = ErrorCode.OK,
        userID    = playerID,
        newLeader = team.leaderID,
    }

    for k,v in ipairs(team.playerList) do 
        local player = g_playerList[v]
        skynet.call(player.handle, "lua", "send", "s2c_leaveTeam", result)
    end

    return ErrorCode.OK, result
end

--房间操作-------------------------------------------------
function M._ifInRoom(playerID)
    local player = g_playerList[playerID]

    return (player.location & const.LOCATION_ROOM) ~= 0
end

function M.init()

end


return M