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

----------------------------------------
function M.query(sql)
    print("query:", sql)

    local ret = db:query(sql)

    print(sql)
    
    return not ret.badresult, ret
end

--仅仅返回一个结果
function M.select (tablename, condition)
    local cmd = string.format("SELECT * FROM %s WHERE %s LIMIT 1", tablename, condition)

    print(cmd)

    local ret = db:query(cmd)

    return not ret.badresult, ret[1]
end

---! update value
function M.update (tableName, keyName, keyValue, fieldName, fieldValue)
    local cmd = string.format("UPDATE %s SET %s='%s' WHERE %s='%s'",tableName, fieldName, fieldValue, keyName, keyValue)

    print(cmd)

    local ret = db:query(cmd)
    
    return not ret.badresult
end

function M.insert (tableName, keyName, keyValue)
    local cmd = string.format("INSERT %s (%s) VALUES ('%s')", tableName, keyName, keyValue)

    print(cmd)

    local ret = db:query(cmd)
    
    return not ret.badresult
end
----------------------------------------

return M