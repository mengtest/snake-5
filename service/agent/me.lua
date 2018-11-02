--
-- Author: xingxingtie
-- Date: 2018-09-17 11:46:25
-- 玩家数据层
local skynet = require("skynet")
local protopack = require("protopack")
local tabledefine = require("tabledefine")
local dbtable = require("common.dbtable")

local M = {}
local DATA = {}

--载入db里面的数据
function M.loadDBData()
    for _, v in ipairs(tabledefine) do
        for tableName, mainKeys in pairs(v) do 
            local sqlWhere = dbtable.genWhereSql(DATA, mainKeys)
            local ok, ret = skynet.call("dbserver", "lua", "select", tableName, sqlWhere)
            
            if ok then 
                DATA[tabName] = dbtable.genDBTable(ret, tableName, mainKeys)    
            end
        end
    end
end

function M.init(id)
    DATA.userid = id      --玩家唯一id

    --M.loadDBData()
end

--获取数据 key是A.B.C.D结构，表示从从A到D按顺序查找key的value
function M.query(key)
    assert(type(key) == "string", "key is not string in query function!")

    local data = DATA
    local list = split(key, ".")

    for _,v in ipairs(list) do 
        data = data[v]
        assert(data, "data is nil in query, when key is: ", v)
    end

    return data
end

-- 刷新数据
function M.update(key, value)
    assert(type(key) == "string", "key is not string in update function!")

    local data = DATA
    local list = split(key, ".")
    local lastKey = table.remove(list)

    for _,v in ipairs(list) do 
        data = data[v]
        assert(data, "data is nil in query, when key is: ", v)
    end

    data[lastKey] = value
end

-- 将数据写入db
function M.flush(key)
    local data = M.query(key)

    assert(data.genUpdateSql, "can't flush data when key is:" .. key)

    local sql = data:genUpdateSql()

    local ret = skynet.call("dbserver", "lua", "query", sql)

    if ret.badresult then 
        skynet.error("flush db error; sql is:" .. sql)
        return false
    end

    data:clean()
    return true
end

function M.pack(fd)
    return {
        agent = skynet.self(),
        id = self._id,
        fd = fd,
    }
end


return M