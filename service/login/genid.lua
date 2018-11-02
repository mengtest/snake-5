local gameconfig = require("gameconfig")
local skynet = require("skynet")

local M = {}
local preGenTime = 0
local preGenIndex = 0

--2字节serverid  4字节当前时间  2字节自增id
function M.gen_userid()
    local harbor = skynet.getenv("harbor")
    local nowTime = skynet.starttime() + (math.floor(skynet.now() / 100))

    skynet.error(nowTime, skynet.starttime(), skynet.now())

    if preGenTime == nowTime then 
        preGenIndex = preGenIndex + 1
    else
        preGenTime = nowTime 
        preGenIndex = 0
    end

    return (harbor << 48) | (nowTime << 16) | preGenIndex
end

return M