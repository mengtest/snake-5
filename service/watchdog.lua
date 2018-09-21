local skynet = require("skynet")

local gate = nil
local agents = {}
local playerid = 0

--SOCKET--------------------------------
local SOCKET = {}

function SOCKET.open(fd, addr)
    skynet.error("发现有客户端连接")
    skynet.call(gate, "lua", "accept", fd)

    local a = get_agent()

    skynet.call(a, "lua", "start", {
        gate = gate,
        clientfd = fd,
        watchdog = skynet.self()})
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
    skynet.error("watch dog 数据！")
    local a = get_agent()

    skynet.call(a, "lua", "start", {
        gate = gate,
        clientfd = fd,
        watchdog = skynet.self()})
end
--CMD-----------------------------------
local CMD = {}

function CMD.start(conf)
    create_agent_pool(conf)

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
        table.insert(POOL, skynet.newservice("agent", i))
    end
end

function get_agent()
    if #POOL > 0 then 
        return table.remove(POOL)
    end

    playerid = playerid + 1

    return skynet.newservice("agent", playerid)
end

function close_agent(fd)
    local a = agents[fd]
    agents[fd] = nil

    if a then 
        skynet.call(gate, "lua", "kick", fd)

        --在agent看来就是disconnect
        skynet.send(a, "lua", "disconnect")
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