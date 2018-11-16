local const     = require("const")
local protopack = require("protopack")
local skynet    = require("skynet")
local sharemap  = require("skynet.sharemap")
local ErrorCode = require("proto.errorCode")

local smRoomInfo = nil
local playerQueue = {}      --玩家队列，用来定房主顺序。 队列前面的优先成为房主。
local playerList  = {}      --玩家列表

--房间是否已满
local function ifRoomFull()
    return smRoomInfo.playerNum >= smRoomInfo.capacity
end

local M = {}

local function notifyHallRoomInfo()
    smRoomInfo:commit()

    skynet.send("hall", "lua", "roomInfoChanged", skynet.self())
end

function M.start()
    assert(not smRoomInfo, "room is already inited!")

    sharemap.register("./lualib/proto/sharemap.sp")

    smRoomInfo = sharemap.writer("roomInfo", { 
        owner     = const.INVIAL_OWNER,
        playerNum = 0,
        capacity  = 10, 
        playing   = false
    })

    smRoomInfo:commit()

    return "roomInfo", smRoomInfo:copy()
end

--有玩家进入 hall -> room
function M.enter(player)
    if ifRoomFull() then 
        return ErrorCode.ROOM_IS_FULL
    end

    if player == null then 
        skynet.error("player is null!!!!!!!!!!!!!!")
    end

    if smRoomInfo.owner == const.INVIAL_OWNER then 
        smRoomInfo.owner = player.userid
    end

    smRoomInfo.playerNum = smRoomInfo.playerNum + 1
    notifyHallRoomInfo()

    table.insert(playerQueue, player.userid)
    playerList[player.userid] = player

    return ErrorCode.OK
end

--玩家离开 player --> room
--玩家点击房间的退出按钮退出房间，这时候是房间最先知道玩家退出，房间通知大厅有人退出
function M.leave(userid)
    playerList[player.userid] = nil

    local index = table.indexof(playerQueue, userid)
    table.remove(playerQueue, index)

    if #playerQueue > 0 then 
        smRoomInfo.owner = playerQueue[1]
        notifyHallRoomInfo()
    end

    skynet.send("hall", "lua", "leaveFromRoom", userid)
end

--玩家断线 hall --> room
function M.disconnect(userid)

end

--玩家重连 hall --> room
function M.reconnect(userid)

end

return M