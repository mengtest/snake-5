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
local sharemap  = require("skynet.sharemap")

local M = {}
local g_playerList = {}
local g_teamList = {}
local g_roomList = {}

local roomInfoStream = nil
local roomInfoSize   = nil

--玩家操作--------------------------------------------------
function M._packInfo(player)
    return {
        userid = player.userid,
        name   = player.name,
        handle = player.handle,
    }
end

function M._packRoomInfo(player)
    return {
        userid = player.userid,
        name   = player.name,
        handle = player.handle,
    }
end

--进入大厅
function M.enterHall(player)     
    local hallPlayer = g_playerList[player.userid]

    if g_playerList[player.userid] then 
        hallPlayer.handle = player.handle

        return ErrorCode.ALREADY_IN_HALL
    end

    local p = {
        userid   = player.userid,
        name     = player.account,
        handle   = player.handle,
        location = const.LOCATION_HALL,   --当前所在位置
        teamID   = nil,                   --所在队伍id
        roomID   = nil,                   --所在房间id
    }

    g_playerList[player.userid] = p

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

--列出房间列表 player --> hall
function M.listRoom()
    local ifUpdate = false

    for k,v in pairs(g_roomList) do 
        if v.smRoomInfoDirty then 
            ifUpdate = true
            v.smRoomInfoDirty = false
            v.smRoomInfo:update()
        end
    end

    if not ifUpdate then 
        --skynet.error("返回老数据")
        return roomInfoStream, roomInfoSize
    end

    --skynet.error("构造新数据")

    local infoList = {}
    for k,v in pairs(g_roomList) do 
        if not v.smRoomInfo.playing then 
            table.insert(infoList, {
                roomID    = k,
                ownerName = g_playerList[v.smRoomInfo.owner].name,
                capacity  = v.smRoomInfo.capacity,
                playerNum = v.smRoomInfo.playerNum,
            })    
        end
    end

    roomInfoStream, roomInfoSize = skynet.pack(infoList)
    return roomInfoStream, roomInfoSize
end

--创建房间 player --> hall
function M.createRoom(playerID)
    if M._ifInRoom(playerID) then 
        return ErrorCode.ALREADY_IN_ROOM
    end

    local roomHandle = skynet.newservice("room")
    local smRoomInfoName, copy = skynet.call(roomHandle, "lua", "start")
    g_roomList[roomHandle] = {
        smRoomInfo = sharemap.reader(smRoomInfoName, copy),
        smRoomInfoDirty = true,   --强行设为dirty，方便后面listroom时取得正确的数据
    }

    return ErrorCode.OK, roomHandle
end

--player --> hall
function M.enterRoom(roomID, userid)
    local room = g_roomList[roomID]

    if not room then 
        return ErrorCode.NONE_ROOM
    end

    if M._ifInRoom(userid) then 
        return ErrorCode.ROOM_NOT_CREATE_TEAM
    end

    local player = g_playerList[userid]

    local ret = skynet.call(roomID, "lua", "enter", M._packRoomInfo(player))
    if ret == ErrorCode.OK then 
        player.location  = player.location | const.LOCATION_ROOM
    end

    return ret
end

--房间内部信息变化通知 room-->hall
function M.roomInfoChanged(roomID)
    local room = g_roomList[roomID]

    assert(room, "room is not defined")

    room.smRoomInfoDirty = true
end

--玩家从房间退出 room --> hall
function M.leaveFromRoom(userid)

end

function M.init()

end


return M