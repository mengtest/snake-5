--
-- Author: xingxingtie
-- Date: 2018-09-18 09:48:04
-- 大厅消息

local skynet = require("skynet")
local M = {}

function M:ctor()
    g_eventMgr:addEventListener("c2s_match", handler(self, self.on_c2s_match), "hall")
end

function M:on_c2s_match()
    print("请求大厅匹配")
    local s = skynet.queryservice(true, "hall")
    skynet.call(s, "lua", "match", g_me:getID())
end

function M.new(...)
    local o = {}
    M.__index = M
    setmetatable(o, M)
    o:ctor(...)
    return o
end

return M
