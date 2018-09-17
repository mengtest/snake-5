

require("common.init")
local skynet    = require("skynet")
local protopack = require("protopack")
local player    = require("agent.player")
local msgdef = require("proto.msgdef")

local param = {...}

local CMD = {}

clientfd = nil
gate = nil
watchdog = nil

function CMD.start(data)
    clientfd = data.clientfd
    gate = data.gate
    watchdog = data.watchdog
    g_me = player.new(param)
    
    skynet.call(gate, "lua", "forward", clientfd)
    skynet.error("开启客户端监听", gate)

    --登录成功
    protopack.send_data(clientfd, msgdef.s2c_login, {
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

skynet.register_protocol {
    name = "client",  
    id = skynet.PTYPE_CLIENT,

    unpack = function (data, sz)
        return protopack.unpack(skynet.tostring(data,sz))
    end,

    dispatch = function (_, _, id, tab)
        --原样返回回去
        print(tab.name, tab.id)
        protopack.send_data(clientfd, id+1, tab)
    end
}

skynet.start(function()
    skynet.dispatch("lua", function(_, _, cmd, ...)
        local f = CMD[cmd]

        skynet.ret(skynet.pack(f(...)))
    end)
end)