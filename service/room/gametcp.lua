-- tcp方式 帧同步
-- 服务器按固定时间下发收集到的玩家操作。 这些操作是客户端计算游戏画面的依据。
-- 不为没有操作的客户端生成空操作

local const     = require("const")
local skynet    = require("skynet")
local ErrorCode = require("proto.errorCode")
local room      = require("room")

local curTurnCommand       = {}   --当前回合命令
local commandHistory       = {}   --历史命令列表
local playerList           = nil
local playerWaitReady      = {}
local turnIndex            = 0

local function initNewGame()
    curTurnCommand       = {}
    commandHistory       = {}

    playerList = room.getPlayerList()

    for k,v in pairs(playerList) do
        playerWaitReady[v.userid] = true
    end
end

--到达了触发idle的时间 也是一轮命令收集截止的时间
local function overtimeIdle()
    room.broadcast("s2c_turnCommand", {
        turnIndex = turnIndex,
        turnCmd   = curTurnCommand,
    })
    
    --记录历史
    table.insert(commandHistory, curTurnCommand)
    curTurnCommand       = {}

    skynet.timeout(const.TURN_DELAY, handler(self, overtimeIdle))
end

local M = {}

--收集玩家的命令
function M.userCommand(cmd)
    if playerList[cmd.userID] then 
        table.insert(curTurnCommand, cmd)    
    end
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

    turnIndex = 2    --开始收集第二回合的数据

    --严格每TURN_DELAY毫秒发送数据
    skynet.timeout(const.TURN_DELAY, handler(self, overtimeIdle))
end

return M