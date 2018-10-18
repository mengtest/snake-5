--
-- Author: xingxingtie
-- Date: 2018-09-17 11:46:25
-- 玩家数据层
local skynet = require("skynet")
local protopack = require("protopack")

local M = {}

function M:ctor(id)
    self._id   = id      --玩家唯一id
    self._room = nil     --所在的房间
end

function M:getID()
    return self._id
end

function M:setRoom(room)
    self._room = room
end

function M:getRoom()
    return self._room
end

function M:pack(fd)
    return {
        agent = skynet.self(),
        id = self._id,
        fd = fd,
    }
end

function M.new(...)
    local o = {}
    M.__index = M
    setmetatable(o, M)
    o:ctor(...)
    return o
end

return M