--
-- Author: xingxingtie
-- Date: 2018-09-17 13:38:03
--
require("common.init")
local skynet = require("skynet")
local hall   = require("hall")


skynet.start(function()
    skynet.dispatch("lua", function(_, _, cmd, ...)
        local f = hall[cmd]

        if f then 
            skynet.ret(skynet.pack(f(...)))
            return
        end
    end)

    hall.init()
end)
