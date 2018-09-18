--
-- Author: xingxingtie
-- Date: 2018-09-17 11:46:25
-- 玩家数据层
local protopack = require("protopack")

local M = {}

function M:ctor(id)
    self._id   = id
end


function M:getID()
    return self._id
end

function M:pack(fd)
    return {
        agent = skynet.self(),
        id = self._id,
        fd = fd,
    }
end


function M.new()
    local o = {}
    M.__index = M
    setmetatable(o, M)
    o:ctor()
    return o
end

return M