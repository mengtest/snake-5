-- 数据库服务，其它服务通过此服务来操作数据库

local skynet = require("skynet")
local dbtool = require("dbtool")
local mysql = require "skynet.db.mysql"
require "skynet.manager"

local CMD = {}

function CMD.start()
    local function on_connect(db)
        db:query("set charset utf8");
    end

    local db = mysql.connect({
        host="127.0.0.1",
        port=3306,
        database="skynet",
        user="root",
        password="xingxingtie",
        --Xingxingtie123!'
        max_packet_size = 1024 * 1024,
        on_connect = on_connect
    })

    dbtool.init(db)

    skynet.name("dbserver", skynet.self())
end

function CMD.query(sql)
    return dbtool.query(sql)
end

function CMD.select(tablename, condition)
    return dbtool.select(tablename, condition)
end

function CMD.update(tableName, keyName, keyValue, fieldName, fieldValue)
    return dbtool.update(tableName, keyName, keyValue, fieldName, fieldValue)
end

function CMD.insert(tableName, keyName, keyValue)
    return dbtool.insert(tableName, keyName, keyValue)
end


skynet.start(function() 
    skynet.dispatch("lua", function(_, _, cmd, ...)
        local f = CMD[cmd]

        if f then 
            skynet.ret(skynet.pack(f(...)))
            return
        end
    end)
end)