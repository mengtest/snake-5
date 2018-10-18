

require("common.init")
local skynet    = require("skynet")
local protopack = require("protopack")
local player    = require("player")
local msgdef = require("proto.msgdef")

local hallMsgHandler = require("hallMsgHandler")
local roomMsgHandler = require("roomMsgHandler")

local CMD = {}

clientfd = nil
gate = nil
watchdog = nil

function CMD.start(data)
    clientfd = data.clientfd
    gate = data.gate
    watchdog = data.watchdog

    g_me = player.new(data.id)
    g_hallMsgHandler = hallMsgHandler.new()
    g_roomMsgHandler = roomMsgHandler.new(CMD.send)

    skynet.call(gate, "lua", "forward", clientfd)
    skynet.error("开启客户端监听", gate, data.id)

    print("发送消息登录消息")
    --登录成功
    CMD.send("s2c_login", {
        retCode = 0,
        id      = g_me:getID()})
    --进入大厅
    skynet.call("hall", "lua", "enter", g_me:pack())
end

function CMD.disconnect()
    skynet.error("玩家掉线")

    --离开大厅
    skynet.call("hall", "lua", "leave", g_me:getID())

    skynet.exit()
end

function CMD.send(name, msg)
    protopack.send_data(clientfd, name, msg)
end

--进入房间
function CMD.enterRoom(room)
    g_me:setRoom(room)                
end

--离开房间
function CMD.leaveRoom(room)
    g_me:setRoom(nil)
end

skynet.register_protocol {
    name = "client",  
    id = skynet.PTYPE_CLIENT,

    unpack = function (data, sz)
        return protopack.unpack(skynet.tostring(data,sz))
    end,

    dispatch = function (_, _, name, tab)
        g_eventMgr:dispatchEvent(name, tab)
    end
}

skynet.start(function()
    skynet.dispatch("lua", function(_, _, cmd, ...)
        local f = CMD[cmd]

        skynet.ret(skynet.pack(f(...)))
    end)
end)