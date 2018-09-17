--
-- Author: xingxingtie
-- Date: 2018-09-17 11:29:03
-- 协议处理类

local protopack = require("protopack")

local M = {}

function M:ctor()
    
end

--玩家匹配
function M:_c2s_match(msg)

end

--玩家操作
function M:_c2s_userop(msg)

end

function M:dispatch(msgName, msg)
    local func = M["_" .. msgName]

    func(self, msg)
end

function M.new()
    local o = {}
    M.__index = M
    setmetatable(o, M)
    o:ctor()
    return o
end

return M
