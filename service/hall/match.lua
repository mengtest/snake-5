--
-- Author: xingxingtie
-- Date: 2018-09-17 13:40:32
-- 简单按人数匹配
local skynet = require("skynet")

local MATCH_NUM = 5

--等待匹配的列表
local waitList = {}
local mathList = {}

local function wakeup(list)
    for _, v in ipairs(list) do 
        skynet.wakeup(v.co)
    end
end

--挂起
local function suspend(player)
    local co = coroutine.running()
    table.insert(waitList, {co = co, id = player.id})
    skynet.wait()
    return player.id
end

--执行匹配动作
local function domatch()
    if #waitList < MATCH_NUM then 
        return
    end

    local list = {}
    for i=1, MATCH_NUM do 
        local p = table.remove(waitList, 1)
        table.insert(list, p.id)

        mathList[p.id] = list
    end

    wakeup(list)
end

local M = {}

--请求匹配，匹配完成后返回一个玩家id列表
function M.match(player)
    skynet.fork(domatch)

    local id = suspend()
    local list = matchList[id]
    mathList[id] = nil

    return list
end

--取消匹配
function M.cancle(player)
    for i=1, #self._waitList do 
        if(self._waitList[i].id == player.id) then
            table.remove(self._waitList, i)
            break
        end
    end
end

return M