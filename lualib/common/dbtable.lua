-- mysql 数据库表

local SHADOW = {}

--生成用于更新的sql语句
function SHADOW:genUpdateSql()
    local dirtyTab = self.__dirtyKey

    local sqlKeyValueList = {}
    for k, _ in pairs(dirtyTab) do
        local value = self[k]
        local dtype = type(value)

        if dtype == "number" then
            table.insert(sqlKeyValueList, string.format("%s=%d", k, value))
        else
            table.insert(sqlKeyValueList, string.format("%s='%s'", k, value))
        end
    end

    if #sqlKeyValueList == 0 then 
        return nil
    end

    local sqlMainKeyList = {}
    for k,v in pairs(self.__mainKey) do 
        local dtype = type(v)

        if dtype == "number" then
            table.insert(sqlMainKeyList, string.format("%s=%d", k, v))
        else
            table.insert(sqlMainKeyList, string.format("%s='%s'", k, v))
        end
    end

    if #sqlMainKeyList == 0 then 
        return nil
    end    

    return string.format(
        "update %s set %s where %s", 
        self.__tableName,
        table.concat(sqlKeyValueList, ","),
        table.concat(sqlMainKeyList, " and "))
end

--清除脏标记和刷新主键
function SHADOW:clean()   

    --清空所有的脏key记录
    for k, v in pairs(self.__dirtyKey) do 
        self.__dirtyKey[k] = nil
    end        

    --刷新主键
    for k, v in pairs(self.__mainKey) do 
        self.__mainKey[k] = self[k]
    end

end

-----------------------------------------------------------------------------

local M = {}

function updateValue(tab, key, value)
    assert(tab[key] ~= nil, key .. " cant't set int dbtable")

    tab[key] = value

    --记录key被改写过
    tab.__dirtyKey[key] = true
end

--生成可用的dbtable，用户拿到的是shadow，实际存储数据的是tab
function M.genDBTable(tab, tabName, mainKeyList)
    --给tab安插上SHADOW里面所有的方法
    setmetatable(tab, {
        __index = SHADOW
    })

    --对tab进行设置
    tab.__tableName = tabName
    tab.__dirtyKey = {}   --dirtyKey中存的是脏key
    tab.__mainKey = {}    --mainKey中存的是主键和其值

    for _, v in ipairs(mainKeyList) do 
        assert(tab[v] ~= nil, "can't find main key :" .. v)
        tab.__mainKey[v] = tab[v]        
    end

    local shadow = setmetatable({}, {
        __index = tab,
        __newindex = function(t, key, value) 
            updateValue(tab, key, value) 
            return tab.key
        end
    })

    return shadow
end

-- 生成sql子句中的字符串
function M.genWhereSql(data, mainKeys)
    local sqlMainKeyList = {}

    for _,v in ipairs(mainKeys) do 
        local value = data[v]
        local dtype = type(value)

        if dtype == "number" then
            table.insert(sqlMainKeyList, string.format("%s=%d", v, value))
        else
            table.insert(sqlMainKeyList, string.format("%s='%s'", v, value))
        end
    end

    if #sqlMainKeyList == 0 then 
        return nil
    end  

    return table.concat(sqlMainKeyList, " and ")
end

return M