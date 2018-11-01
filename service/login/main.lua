local skynet = require("skynet")
local protopack = require("protopack")
local ErrorCode = require("proto.errorCode")
local genid = require("genid")

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

--发送数据到前端
function sendRigsterInfo(fd, retcode)
    protopack.send_data(fd, "s2c_register", {
        retCode = retcode})
end

--
function CMD.start()

end

--注册
function CMD.register(tab, fd)

    --账号为空
    if string.len(tab.account) == 0 then 
        sendRigsterInfo(fd, ErrorCode.ACCOUNT_EMPTY)
        return false 
    end

    --密码为空
    if string.len(tab.password) == 0 then 
        sendRigsterInfo(fd, ErrorCode.PASSWORD_EMPTY)
        return false 
    end

    local ok, ret = skynet.call(".dbserver", "lua", "select", "playerinfo", "account", tab.account)

    --sql执行错误
    if not ok then 
        sendRigsterInfo(fd, ErrorCode.SERVER_ERROR)
        return false
    end

    --账号已被注册
    if ret then 
        sendRigsterInfo(fd, ErrorCode.ACCOUT_EXIST)
        return false
    end

    local userid = genid.gen_userid()

    local cmd = string.format("insert into %s (account, password, userid) values ('%s', '%s', )", 
        "playerinfo", 
        tab.account, 
        tab.password)

    local ok, _ = skynet.call(".dbserver", "lua", "query", cmd)
    if not ok then 
        sendRigsterInfo(fd, ErrorCode.SERVER_ERROR)
        return false
    end

    sendRigsterInfo(fd, ErrorCode.OK)
    skynet.error("注册成功")
    return true
end

--验证
function CMD.verify(tab, fd)
    local ok, ret = skynet.call(".dbserver", "lua", "select", "playerinfo", "account", tab.account)

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

    return true, id, tab.account
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