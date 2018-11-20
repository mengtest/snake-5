local const     = require("const")
local protopack = require("protopack")
local skynet    = require("skynet")
local sharemap  = require("skynet.sharemap")
local ErrorCode = require("proto.errorCode")

local smRoomInfo = nil
local playerList  = {}      --玩家列表
local seatList    = {false, false, false, false, false, false}      --座位表  每个位置对应一个玩家

--房间是否已满
local function ifRoomFull()
    return smRoomInfo.playerNum >= smRoomInfo.capacity
end

local M = {}

local function notifyHallRoomInfo()
    smRoomInfo:commit()

    skynet.send("hall", "lua", "roomInfoChanged", skynet.self())
end

--分配座位
local function allocateSeat(player)
    for i, v in ipairs(seatList) do 
        if not v then
            seatList[i] = player
            player.seat = i
            return
        end
    end

    --分配座位失败
    assert(false, "allocateSeat failed!")
end

--释放座位
local function releaseSeat(seat)
    seatList[seat] = false
end

--裁决新的房主
local function judgeNewOwner()
    local owner = nil
    local lastJoinTime = -1

    for k,v in pairs(playerList) do 
        if v.joinTime > lastJoinTime then 
            lastJoinTime = v.joinTime
            owner = v
        end
    end

    assert(owner, "can't find new owner")
    return owner.userid
end

local function broadcast(name, msg, exclude)
    for k,v in pairs(playerList) do 
        if (not exclude) or (not table.indexof(exclude, v.userid)) then 
            skynet.send(v.handle, "lua", "send", name, msg)   
        end
    end
end

local function packPlayerInfo(player) 
    return {
        userID    = player.userid,
        name      = player.name,
        winCount  = player.winCount,
        loseCount = player.loseCount,
        position  = player.seat,
    }
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

    if smRoomInfo.owner == const.INVIAL_OWNER then 
        smRoomInfo.owner = player.userid
    end

    smRoomInfo.playerNum = smRoomInfo.playerNum + 1
    notifyHallRoomInfo()

    player.joinTime = skynet.now()
    playerList[player.userid] = player
    allocateSeat(player)

    player.winCount  = skynet.call(player.handle, "lua", "queryData", "gameinfo.wincount")
    player.loseCount = skynet.call(player.handle, "lua", "queryData", "gameinfo.losecount")
    
    broadcast("s2c_playerJoinRoom", {playerinfo = packPlayerInfo(player)}, {player.userid})

    return ErrorCode.OK
end

--玩家离开 player --> room
--玩家点击房间的退出按钮退出房间，这时候是房间最先知道玩家退出，房间通知大厅有人退出
function M.leave(userid)
    local player = playerList[userid]

    playerList[userid] = nil
    releaseSeat(player.seat)

    if smRoomInfo.owner == userid then
        smRoomInfo.owner = judgeNewOwner()
        notifyHallRoomInfo()
    end

    skynet.send("hall", "lua", "leaveFromRoom", userid)
end

--返回房间信息 player --> room
function M.roomInfo()
    local result = {
        retCode = ErrorCode.OK,
        ownerID = smRoomInfo.owner,
        userList = {}
    }

    local userList = result.userList

    for _, p in pairs(playerList) do 
        table.insert(userList, packPlayerInfo(p))
    end 

    return result
end

-- 换座位 player --> room
function M.changeSeat(userid, targetSeat)
    if seatList[targetSeat] then 
       return ErrorCode.SEAT_HAVE_PLAYER
    end

    local player = playerList[userid]

    local msg = {
        retCode = ErrorCode.OK,
        originSeat = player.seat,
        targetSeat = targetSeat
    }

    releaseSeat(player.seat)
    player.seat = targetSeat
    seatList[targetSeat] = player

    broadcast("s2c_changeSeat", msg)

    return ErrorCode.OK
end

function M.getPlayerList()
    return playerList
end

--玩家断线 hall --> room
function M.disconnect(userid)
    for k,v in pairs(playerList) do 
        
    end
end

--玩家重连 hall --> room
function M.reconnect(userid)

end

return M