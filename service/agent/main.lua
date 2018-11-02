require("common.init")
local skynet    = require("skynet")
local protopack = require("protopack")
local msgdef    = require("proto.msgdef")
local g_me      = require("me")

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

    g_me.init(data.userid)
    g_send = CMD.send

    clientfd = fd
    skynet.error("agent 开始！")
    assert(false, "debug")
    --skynet.call(gate, "lua", "forward", clientfd)

    --直接进入大厅
    --skynet.call("hall", "lua", "enter", g_me:pack())
end

function CMD.reconnect(fd)
    skynet.error("玩家断线重连")

    clientfd = fd

    skynet.call(gate, "lua", "forward", clientfd)
end

function CMD.disconnect()
    skynet.error("玩家掉线")

    skynet.call("hall", "lua", "leave", g_me:getID())

    skynet.exit()
end

function CMD.send(name, msg)
    protopack.send_data(clientfd, name, msg)
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
        
        skynet.ignoreret()
    end
}

skynet.start(function()
    skynet.dispatch("lua", function(_, _, cmd, ...)
        print("agent街收到命令", cmd, ...)
        assert(cmd ~= "start")
        local f = CMD[cmd]

        skynet.ret(skynet.pack(f(...)))
    end)
end)