--
-- Author: xingxingtie
-- Date: 2018-09-17 13:40:32
-- 简单按人数匹配

local M = {}

--callBack 匹配成功之后的回调函数
function M:ctor(callBack)
   self._callBack = callBack   
   self._waitList = {} 
end

function M:match(player)
    table.insert(self._waitList, player)

    if #self._waitList >= 4 then

        local userList = {}
        for i=1, 4 do 
            table.insert(userList, self._waitList[1])
            table.remove(self._waitList, 1)            
        end
        
        self._callBack(userList) 
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

function M.new(...)
    local o = {}
    M.__index = M
    setmetatable(o, M)
    o:ctor(...)
    return o
end

return M