local skynet = require("skynet")
local protopack = require("protopack")

local CMD = {}
local id = 1

--发送数据到前端
function sendLoginInfo(fd, retcode, id, account, token)
    protopack.send_data(fd, "s2c_login", {
        retCode = retcode,
        id      = id,
        account = account,
        token   = token})
end

--
function CMD.start()

end

--验证
function CMD.verify(data, fd)
    local name, tab = protopack.unpack(data)

    --玩家在确认登录之前只能发登录数据其它的一概不管
    if name ~= "c2s_login" then 
        sendLoginInfo(fd, 4)
    end

    local ok, ret = skynet.call(".dbserver", "lua", "getByKey", "playerinfo", "account", tab.account)

    --sql执行错误
    if not ok then 
        sendLoginInfo(fd, 3)
        return false
    end

    --没有该玩家
    if not ret then 
        sendLoginInfo(fd, 1)
        return false
    end

    --密码错误
    if ret.password ~= tab.password then 
        sendLoginInfo(fd, 2)
        return false
    end

    --正确
    sendLoginInfo(fd, 0, id, tab.account, "token")
    id = id + 1

    return true, id
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