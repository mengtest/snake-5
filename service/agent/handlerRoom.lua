
--房间消息

local skynet = require("skynet")
local M = require("handler")

function M.c2s_userop(msg)
    local room = g_me:getRoom()
    if not room then return end
    skynet.call(room, "lua", "userop", g_me:getID(), msg)
end

function M.pingAsk(msg) 
	g_send("pingAck", msg)
end