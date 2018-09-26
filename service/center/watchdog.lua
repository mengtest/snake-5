local skynet = require("skynet")
local gate = nil
local centerserver = nil

--SOCKET--------------------------------
local SOCKET = {}

function SOCKET.open(fd, ip)	
			
end

function SOCKET.close()

end

function SOCKET.error()

end

function SOCKET.warning(fd, size)
    log.log("socket warning fd=%d size=%d", fd, size)
end

function SOCKET.data(fd, data)

end

--CMD-----------------------------------
local CMD = {}

function CMD.start(conf)
    create_agent_pool(conf)

    skynet.call(gate, "lua", "open", conf)
end

function CMD.close() 
    
end
---------------------------------------

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

    centerserver = skynet.newservice(center)
end)