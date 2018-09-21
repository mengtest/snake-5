--
-- Author: xingxingtie
-- Date: 2018-09-17 13:55:10
-- 房间

local const = require("const")
local protopack = require("protopack")
local skynet = require("skynet")

local M = {}

function M:ctor(id, hall)
    self._id = id
    self._hall = hall
    self._playerList  = {}
    self._turnIndex = 1

    self._curTurnCommand       = {}   --当前回合命令
    self._commandHistory       = {}   --历史命令列表
    self._ifRecvCommand        = {}   --记录当前回合是否收到玩家命令

    self._curState  =  const.STATE_FREE
end

--第一回合超时
function M:_overtimeFirstTurn()
    self:_overtimeIdle()
end

function M:_constructIdleCmd(userID)
    return {userID = userID, cmdType = const.CMD_NONE, cmdValue = 0}
end

--发送当前轮命令
function M:_sendCurTurnCommand()
    local turnop = {
        turnIndex = self._turnIndex,
        turnCmd = self._curTurnCommand
    }

    --print("发送消息:", self._turnIndex)

    --每个人都会发一次
    for k, v in pairs(self._playerList) do
        skynet.send(v.agent, "lua", "send", "s2c_turnop", turnop)
    end

    --记录历史
    table.insert(self._commandHistory, turnop)

    self._curTurnCommand = {}
    self._ifRecvCommand = {}
end

--到达了触发idle的时间
function M:_overtimeIdle()
  
    for k, v in pairs(self._playerList) do
        if not self._ifRecvCommand[v.id] then 
            table.insert(self._curTurnCommand, self:_constructIdleCmd(v.id))
        end
    end

    self:_sendCurTurnCommand()

    self._turnIndex = self._turnIndex + 1

    skynet.timeout(const.TURN_DELAY, handler(self, self._overtimeIdle))
end

--玩家的一回合command命令
function M:userop(playerid, cmd)

    if not self._playerList[playerid] then 
        return
    end

    --插入命令
    cmd.userID = playerid
    table.insert(self._curTurnCommand, cmd)

    self._ifRecvCommand[playerid] = true
end

function M:enter(player)
    --不是free状态不允许加入房间
    if(self._curState ~= const.STATE_FREE) then 
        return
    end

    if not self._playerList[player.id] then 
        self._playerList[player.id] = player    
    end
end

function M:leave(player)
    self._playerList[player.id] = nil
end

function M:gameStart()
    skynet.error("房间游戏开始....", #self._playerList)

    skynet.timeout(const.FIRST_TURN_DELAY, handler(self, self._overtimeFirstTurn))

    --构造第一回合指令
    local turnop = {
        turnIndex = 1,
        turnCmd = {}
    }
    for k, v in pairs(self._playerList) do
        table.insert(turnop.turnCmd, {userID = v.id, cmdType = 0, cmdValue = 0})
    end

    for k, v in pairs(self._playerList) do
        skynet.error("发送游戏开始命令")
        turnop.turnIndex = 1
        skynet.send(v.agent, "lua", "send", "s2c_gamestart", {turnCmd = turnop})
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