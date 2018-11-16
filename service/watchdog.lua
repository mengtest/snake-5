local skynet = require("skynet")
local protopack = require("protopack")

local loginserver = nil
local gate = nil

local agents = {}       -- key fd: value:agent,与玩家socket断连后该key value关系将不复存在
local onlineUser = {}   -- 在线玩家 key:userID value:agent,与玩家socket断连后玩家在服务器中的agent依然存在。

--账号----------------------------------
local verify = function(fd, tab)
    local ret, userid, account = skynet.call(loginserver, "lua", "verify", tab, fd)

    if ret then 
        if onlineUser[account] then 
            agents[fd] = agent
            skynet.call(onlineUser[account], "lua", "reconnect", fd)
        else 
            skynet.error("验证完毕", userid, account)
            local agent = get_agent(fd)

            onlineUser[account] = agent
            agents[fd] = agent

            skynet.call(agent, "lua", "start", {
                gate = gate,
                clientfd = fd,
                watchdog = skynet.self(),
                userid = userid,
                account = account})
        end
    end
end

local register = function(fd, tab)
    skynet.call(loginserver, "lua", "register", tab, fd)
end

--SOCKET--------------------------------
local SOCKET = {}

function SOCKET.open(fd, addr)
    skynet.error("发现有客户端连接")
    skynet.call(gate, "lua", "accept", fd)
end

function SOCKET.close(fd) 
    close_agent(fd)
end

function SOCKET.error(fd, msg)
    skynet.error(string.format("socket error fd = %d msg=%s", fd, msg))
    
    close_agent(fd)
end

function SOCKET.warning(fd, size)
    -- size K bytes havn't send out in fd
    log.log("socket warning fd=%d size=%d", fd, size)
end

--没有将agent传递给gete时，gate会先将数据发给watchdog
function SOCKET.data(fd, data)
    local name, tab = protopack.unpack(data)

    if name == "c2s_login" then 
        skynet.fork(verify, fd, tab)

    elseif name == "c2s_register" then
        skynet.fork(register, fd, tab)
    end
end
--CMD-----------------------------------
local CMD = {}

function CMD.start(conf, _loginsever)
    create_agent_pool(conf)

    loginserver = _loginsever

    skynet.call(gate, "lua", "open", conf)
end

function CMD.close(fd) 
    close_agent(fd)
end

--agent服务退出，此时便没有了该agent
function CMD.agentExit(account)
    onlineUser[account] = nil
end
--private-------------------------------
local POOL = {}
--预构造多个agent
function create_agent_pool(conf)
    for i=1, conf.pre_agent_num do 

        --table.insert(POOL, skynet.newservice("agent"))
    end
end

function get_agent(fd)
    local agent = nil
    if #POOL > 0 then 
        agent = table.remove(POOL)
    else
        agent = skynet.newservice("agent")
    end

    return agent
end

--将fd和agent解除绑定，但是onlineUser中的account和agent没有解除绑定
function close_agent(fd)
    local a = agents[fd]
    agents[fd] = nil

    if a then 
        skynet.call(gate, "lua", "kick", fd)

        skynet.send(a, "lua", "disconnect")
    else
        skynet.error("没有agent！")
    end
end

skynet.start(function() 
    skynet.dispatch("lua", function(_, _, cmd, subcmd, ...)
        if cmd == "socket" then 
            local f = SOCKET[subcmd]
            f(...)
        else 
            local f = CMD[cmd]
            skynet.ret(skynet.pack(f(subcmd, ...))) 
        end
    end)

    gate = skynet.newservice("gate")
end)