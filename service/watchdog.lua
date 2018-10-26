local skynet = require("skynet")
local protopack = require("protopack")

local loginserver = nil
local gate = nil
local agents = {}

--账号----------------------------------
local verify = function(fd, tab)
    local ret, id = skynet.call(loginserver, "lua", "verify", tab, fd)

    if ret then 
        local a = get_agent(fd)

        skynet.call(a, "lua", "start", {
            gate = gate,
            clientfd = fd,
            watchdog = skynet.self(),
            id = id})
    end
end

local register = function(fd, tab)
    skynet.call(loginserver, "lua", "register", tab, fd)
end

--SOCKET--------------------------------
local SOCKET = {}

function SOCKET.open(fd, addr)
    --skynet.error("发现有客户端连接")
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
    --skynet.error("watch dog 数据！")

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
--private-------------------------------
local POOL = {}
--预构造多个agent
function create_agent_pool(conf)
    for i=1, conf.pre_agent_num do 

        table.insert(POOL, skynet.newservice("agent"))
    end
end

function get_agent(fd)
    local agent = nil
    if #POOL > 0 then 
        agent = table.remove(POOL)
    end
    
    agent = skynet.newservice("agent")
    agents[fd] = agent

    return agent
end

function close_agent(fd)
    local a = agents[fd]
    agents[fd] = nil


    if a then 
        skynet.call(gate, "lua", "kick", fd)

        skynet.error("发送disconnect")
        --在agent看来就是disconnect
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