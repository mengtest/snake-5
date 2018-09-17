--
-- Author: xingxingtie
-- Date: 2018-09-17 13:35:43
-- 大厅
local skynet = require("skynet")
local match = require("match")
local const = require("const")


local M = {}

function M:ctor(roomNum)
    self._roomList = {}           --房间列表
    self._idleList = {}           --空闲房间列表

    self._playerList = {}         --在大厅中的玩家列表

    self:_initRoom(roomNum)

    self._match = match.new(handler(self, self._playerMatchSuccess))
end

function M:_initRoom(roomNum)

    for i=1, roomNum do 
        local roomInfo = {
            id = i,
            agent = skynet.newservice("room", i, skynet.self()),
        }

        self._roomList[i] = roomInfo
        table.insert(self._idleList, roomInfo)
    end
end

--玩家进入房间
function M:_playerEnterRoom(player, room)
    v.hallState = const.STATE_GAMING
    player.room = room

    skynet.call(room.agent, "lua", "enter", player)
end

--通知房间游戏开始
function M:_gameStart(room)
    skynet.call(room.agent, "lua", "gameStart")
end

--匹配成功 安排进入房间
function M:_playerMatchSuccess(arr)
    local idleRoom = table.remove(self._idleList) 

    for k,v in ipairs(arr) do 
        self:_playerEnterRoom(v, idleRoom)
    end

    self:_gameStart(idleRoom)
end

--进入大厅
function M:enter(player)
    if not self._playerList[player.id] then
        self._playerList[player.id] = player

        player.hallState = const.STATE_FREE
        return "enter hall success"
    end

    return "enter hall error: already in hall"
end

--离开大厅
function M:leave(playerID)
    local player = self._playerList[player.id]

    if not player then return end

    if player.hallState == const.STATE_MATCH then 
        self._match.cancle(palyer)

    elseif player.hallState == const.STATE_GAMING then 
        skynet.call(player.room.agent, "lua", "leave", player)
    end
end

--玩家离开房间，离开房间表示玩家在房间中的游戏结束
function M:playerLeaveRoom(playerID)
    local player = self._playerList[player.id]
    
    if player and player.hallState == const.STATE_GAMING then 
        player.room = nil
        player.hallState = const.STATE_FREE
    end
end

function M:gameOver(roomID)
    local roomInfo = self._roomList[roomID]

    if roomInfo then 
        table.insert(self._idleList, roomInfo)
    end
end

--匹配，匹配成功之后立马进入房间
function M:match(playerID)
    local player = self._playerList[player.id]

    if player and player.hallState == const.STATE_FREE then 
        player.hallState = const.STATE_MATCH

        self._match.match(palyer)
    end
end

function M.new(...)
    local o = {}
    M.__index = M
    setmetatable(o, M)
    o:ctor(...)
    return o
end

return M