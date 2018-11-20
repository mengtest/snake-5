require("common.init")
local skynet    = require("skynet")
local protopack = require("protopack")
local msgdef    = require("proto.ConstMsgID")
g_me      = require("me")

local msgHandler = require("handler")
require("handlerHall")
require("handlerRoom")

local CMD = {}

clientfd = nil
gate = nil
watchdog = nil

function CMD.start(data)
    gate = data.gate
    watchdog = data.watchdog

    g_me.init(data.userid, data.account)
    g_send = CMD.send

    clientfd = data.clientfd
    skynet.error("agent 开始！")
    skynet.call(gate, "lua", "forward", clientfd)

    --直接进入大厅
    skynet.call("hall", "lua", "enterHall", g_me.packHallInfo())
end

function CMD.reconnect(fd)
    skynet.error("玩家断线重连")

    clientfd = fd

    skynet.call(gate, "lua", "forward", clientfd)

    local roomHandle = g_me.getRoomHandle()
    if roomHandle then    --在房间里面
        msgHandler.c2s_enterRoom({roomID = roomHandle})
    end
end

function CMD.disconnect()
    skynet.error("玩家掉线")

    --skynet.call("hall", "lua", "leave", g_me.getUserID())

    --skynet.exit()
end

function CMD.send(name, msg)
    protopack.send_data(clientfd, name, msg)
end

--普通数据操作
function CMD.updateData(key, value)
    if g_me[key] then 
        g_me[key] = value
    else
        g_me.update(key, value)
    end
end

function CMD.queryData(key)
    if g_me[key] then 
        return g_me[key]
    else
        return g_me.query(key)
    end
end

skynet.register_protocol {
    name = "client",  
    id = skynet.PTYPE_CLIENT,

    unpack = function (data, sz)
        return protopack.unpack(skynet.tostring(data,sz))
    end,

    dispatch = function (_, _, name, tab)
        skynet.ignoreret()

        if msgHandler[name] then 
            msgHandler[name](tab)
        end
    end
}

skynet.start(function()
    skynet.dispatch("lua", function(_, _, cmd, ...)
        --print("agent街收到命令", cmd, ...)
        
        local f = CMD[cmd]

        skynet.ret(skynet.pack(f(...)))
    end)
end)