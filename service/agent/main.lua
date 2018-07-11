local skynet = require("skynet")
local protopack = require("protopack")

local CMD = {}

clientfd = nil
gate = nil
watchdog = nil

function CMD.start(data)
    clientfd = data.clientfd
    gate = data.gate
    watchdog = data.watchdog

    skynet.call(gate, "lua", "forward", clientfd)
    skynet.error("开启客户端监听", gate)
end

function CMD.disconnect()
    skynet.error("数据异常")
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
        protopack.send_data(clientfd, id+1, tab)
    end
}

skynet.start(function()
    skynet.dispatch("lua", function(_, _, cmd, ...)
        local f = CMD[cmd]

        skynet.ret(skynet.pack(f(...)))
    end)


end)