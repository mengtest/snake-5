
--房间消息

local skynet = require("skynet")
local M = {}

function M:ctor(send)
	self._send = send

    g_eventMgr:addEventListener("c2s_userop", handler(self, self.on_c2s_userop), "room")

    g_eventMgr:addEventListener("pingAsk", handler(self, self.on_pingAsk), "room")
end

function M:on_c2s_userop(msg)
    local room = g_me:getRoom()
    
    if not room then return end

    skynet.call(room, "lua", "userop", g_me:getID(), msg)
end

function M:on_pingAsk(msg) 
	self._send("pingAck", msg)
end

function M.new(...)
    local o = {}
    M.__index = M
    setmetatable(o, M)
    o:ctor(...)
    return o
end

return M
