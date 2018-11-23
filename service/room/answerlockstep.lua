--云风博客中提到的经典帧同步做法
--[[
    如果只是想验证基础模型就不要想太复杂，不要在搞明白之前就考虑优化。不要考虑任何网络波动，延迟，丢包（用 TCP 假定连接稳定绝对不会断）。

    1. 客户端把操作依次发出去，回合时间到了就发个回合结束标记。

    2. 服务器收到什么转发什么，不做任何处理。和时间也没任何关系。

    3. 客户端只有收到所有玩家（包括自己）的回合结束标记后，再表现这个回合。不然就卡住等待。
]]


local const     = require("const")
local skynet    = require("skynet")
local ErrorCode = require("proto.errorCode")
local room      = require("room")

local playerWaitReady      = {}

local function initNewGame()
    local playerList = room.getPlayerList()

    for k,v in pairs(playerList) do
        playerWaitReady[v.userid] = true
    end
end

local M = {}

--收到玩家命令之后毫不做作，立即发送
function M.userCommand(cmd)
    room.broadcast("s2c_turnCommand", {
        userCmd   = cmd,
    })
end

function M.gameStart(userid)
    if userid ~= room.getOwner() then 
        return ErrorCode.OWNER_START_GAME
    end

    initNewGame()

    room.broadcast(  --广播游戏开始，客户端收到s2c_startGame消息后，开始整局游戏。
        "s2c_startGame", 
        {
            retCode = ErrorCode.OK, 
            turnTime = const.TURN_DELAY * 10,     --一回合操作的毫秒值
        })

    return ErrorCode.OK
end

function M.loadComplete(userid) 
    playerWaitReady[userid] = nil

    for k, v in pairs(playerWaitReady) do
        return 
    end

    room.broadcast(  --广播游戏开始，客户端收到s2c_startGame消息后，开始整局游戏。
        "s2c_launch", 
        {})
end

return M