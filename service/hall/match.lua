--
-- Author: xingxingtie
-- Date: 2018-09-17 13:40:32
-- 匹配规则

local M = {}

--callBack 匹配成功之后的回调函数
function M:ctor(callBack)
   self._callBack = callBack   
   self._waitList = {} 
end

function M:match(player)
    table.insert(self._waitList, player)

    if #self._waitList > 2 then
        self._callBack({self._waitList[1], self._waitList[2]}) 
    end
end

--取消匹配
function M:cancle(player)
    for i=1, #self._waitList do 
        if(self._waitList[i] == player) then 
            table.remove(self._waitList, i)
        end
    end
end

function M.new()
    local o = {}
    M.__index = M
    setmetatable(o, M)
    o:ctor()
    return o
end

return M