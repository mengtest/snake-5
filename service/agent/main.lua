local skynet = require("skynet")

local CMD = {}

clientfd = nil
gate = nil
watchdog = nil

function CMD.start(data)
    clientfd = data.clientfd
    gate = data.gate
    watchdog = data.watchdog
end

function CMD.disconnect()
    skynet.exit()
end

skynet.start(function()
    skynet.dispatch("lua", function(_, _, cmd, ...)
        local f = CMD[cmd]

        skynet.ret(skynet.pack(f(...)))
    end)
end)