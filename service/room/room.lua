--
-- Author: xingxingtie
-- Date: 2018-09-17 13:55:10
-- 房间

local const = require("room.const")
local protopack = require("protopack")

local M = {}

function M:ctor(id, hall)
    self._id = id
    self._hall = hall
    self._playerList  = {}
    self._turnIndex = 1

    self._ifRecvCommand        = {}   --当前回合是否收到各个玩家的命令
    self._curTurnCommand       = {}   --当前回合命令
    self._commandHistory       = {}   --历史命令列表

    self._curState  =  const.STATE_FREE
end

--第一回合超时
function M:_overtimeFirstTurn()
    skynet.timeout(const.TURN_DELAY, handler(self, self._overtimeIdle))

    self:_overtimeIdle()
end

function M:_constructIdleCmd(userID)
    return {{cmdType = const.CMD_NONE, cmdValue = 0}}
end

--发送当前轮命令
function M:_sendCurTurnCommand()
    local turnop = {
        index = self, _turnIndex,
        turnCmd = self._curTurnCommand
    }

    --每个人都会发一次
    for k, v in pairs(self._playerList) do
        protopack.send_data(v.fd, "s2c_turnop", turnop)
    end
end

--到达了触发idle的时间
function M:_overtimeIdle()
    for k, v in pairs(self._playerList) do
        if (self._ifRecvCommand[v.id]) then 
            table.insert(self._curTurnCommand, self:_constructIdleCmd(v.id))
            self._ifRecvCommand[v.id] = true
        end
    end

    self:_sendCurTurnCommand()
end

--玩家的一回合command命令
function M:playercommand(playerid, cmd)
    if not self._playerList[player.id] then 
        return
    end

    --本轮玩家命令已收到，还未发出去，则拒收命令
    if self._ifRecvCommand[playerid] then 
        return 
    end

    --插入命令
    table.insert(self._curTurnCommand, command)
    self._ifRecvCommand[playerid] = true
end

function M:enter(player)
    --不是free状态不允许加入房间
    if(self._curState ~= const.STATE_FREE) then 
        return
    end

    if self._playerList[player.id] then 
        self._playerList[player.id] = player    
    end
end

function M:leave(player)
    self._playerList[player.id] = nil
end

function M:gameStart()
    skynet.timeout(const.FIRST_TURN_DELAY, handler(self, self._overtimeFirstTurn))

    for k, v in pairs(self._playerList) do
        protopack.send_data(v.fd, "s2c_gamestart", {})
    end
end

function M.new()
    local o = {}
    M.__index = M
    setmetatable(o, M)
    o:ctor(...)
    return o
end

return M