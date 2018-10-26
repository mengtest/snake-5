local M = {}
local db = nil

local function dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end

function M.init(dbvalue)
    db = dbvalue
end

function M.query(sql)
    local ret = db:query(sql)

    return not ret.badresult, ret
end

----------------------------------------

function M.ifDBExist(dbname)
    local ret = db:query("show databases")

    print("ifDBExist", dump(ret))
    
    for k,v in ipairs(ret) do 
        if (v.Database == dbname) then 
            return true
        end
    end

    return false
end

function M.createDB(dbname)
    local ret = db:query("create database " .. dbname)

    print("createDB", dump(ret))

    return not ret.badresult
end

function M.useDB(dbname)
   local ret = db:query("use " .. dbname) 

   print("useDB", dump(ret))

   return not ret.badresult
end

----------------------------------------

function M.ifTableExist(tablename)
    local ret = db:query("show tables")

    print("ifTableExist", dump(ret))

    for k,v in ipairs(ret) do 
        for _, name in pairs(v) do 
            if(tablename == name) then 
                return true
            end
        end
    end

    return false
end

function M.createTable(tablename)
    local ret = db:query("create table " .. tablename .." (name varchar(20), password varchar(20))")

    print("createTable", dump(ret))
end

function M.insertTable(tablename, name, password)
    local sql = string.format(
        "insert into %s (name, password) values ('%s', '%s')",
        tablename, name, password)

    local ret = db:query(sql)

    print("insertTable", dump(ret)) 
end

function M.select(tablename, keyname, keyvalue)
    local cmd = string.format("SELECT * FROM %s WHERE %s='%s' LIMIT 1", tablename, keyname, keyvalue)

    local ret = db:query(cmd)

    return not ret.badresult, ret[1]
end

---! update value
function M.update (tableName, keyName, keyValue, fieldName, fieldValue)
    local cmd = string.format("UPDATE %s SET %s='%s' WHERE %s='%s'",tableName, fieldName, fieldValue, keyName, keyValue)

    local ret = db:query(cmd)
    
    return not ret.badresult
end

function M.insert (tableName, keyName, keyValue)
    local cmd = string.format("INSERT %s (%s) VALUES ('%s')", tableName, keyName, keyValue)

    local ret = db:query(cmd)
    
    return not ret.badresult
end
----------------------------------------

return M