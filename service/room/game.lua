--
-- Author: xingxingtie
-- Date: 2018-09-17 13:55:10
-- 房间

local const     = require("const")
local protopack = require("protopack")
local skynet    = require("skynet")
local sharemap  = require("skynet.sharemap")
local room      = require("room")

local curTurnCommand       = {}   --当前回合命令
local commandHistory       = {}   --历史命令列表
local commandVersion       = {}   --记录各个玩家的已发送命令的版号
local turnIndex            = 1    --整个游戏的回合数从1开始 turnIndex记录的是当前正在收集的命令的回合号

local function initNewGame()
    curTurnCommand       = {}
    commandHistory       = {}
    commandVersion       = {}
    turnIndex            = 1 

    local playrList = room.getPlayerList()
    for k, v in pairs(playerList) do 
        commandVersion[v.userid] = nil
    end
end

--构造空数据
local function constructIdleCmd(userID)
    return {
        userID = userID, 
        cmdType = const.CMD_NONE, 
        cmdValue = 0
    }
end

--发送当前轮命令
local function sendCurTurnCommand()
    local turnCommand = {
        turnIndex = turnIndex,
        turnCmd   = curTurnCommand,
    }

    room.broadcast("s2c_turnCommand", turnCommand)
    
    --记录历史
    table.insert(self._commandHistory, turnCommand)

    curTurnCommand       = {}
    commandVersion       = {}
end

--到达了触发idle的时间 其实也是一轮命令收集截止的时间
local function overtimeIdle()
    local playrList = room.getPlayerList()

    for k, v in pairs(playrList) do
        if self._commandVersion[userid] < turnIndex then 

            self._commandVersion[userid] = turnIndex

            table.insert(self._curTurnCommand, self:_constructIdleCmd(v.id))
        end
    end

    self:_sendCurTurnCommand()

    turnIndex = turnIndex + 1

    skynet.timeout(const.TURN_DELAY, handler(self, overtimeIdle))
end

local M = {}

--收集玩家的命令，一回合中玩家有可能发送多条命令
function M.userCommand(userid, cmd)
    if not self._playerList[userid] then 
        return
    end

    table.insert(self._curTurnCommand, cmd)

    self._commandVersion[userid] = self._turnIndex
end

function M.gameStart()

    initNewGame()

    room.broadcast(
        "s2c_startGame", 
        {
            retCode = ErrorCode.OK, 
            turnTime = const.TURN_DELAY / 2 * 10
        })

    --立即发送第一回合的数据，玩家所有的回合的行动都是依据后端来的
    M:_overtimeIdle()

    --严格每100毫秒发送数据 第一次特殊处理：50毫秒之后发送第二回合的行动数据
    skynet.timeout(const.TURN_DELAY / 2, handler(self, overtimeIdle))
end


return M