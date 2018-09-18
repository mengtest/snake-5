--
-- Author: xingxingtie
-- Date: 2018-09-17 13:38:03
--
require("common.init")
local skynet = require("skynet")

local CMD = {}

function CMD.start()
    g_hall = require("hall").new(10)
end

skynet.start(function()

    skynet.dispatch("lua", function(_, _, cmd, ...)
        local f = CMD[cmd]
        if f then 
            skynet.ret(skynet.pack(f(...)))
        end

        f = g_hall[cmd]
        if f then 
            skynet.ret(skynet.pack(f(g_hall, ...)))
            return 
        end
    end)
end)
