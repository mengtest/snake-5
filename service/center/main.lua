local skynet = require("skynet")
local protopack = require("protopack")
local tab_fd_addr = {}

local SOCKET = {}

function SOCKET.c2s_register(fd, name, tab)
	local record = tab_fd_addr[fd]
	local retCode = 0

	if record and not record.port then 
		record.port = tab.port
	end
	
	protopack.send_data(fd, "s2c_register", {retCode = 0})
end

function SOCKET.c2s_serverList(fd, name, tab)
	local 

	protopack.send_data(fd, "s2c_register", {retCode = 0})
end
--CMD---------------------------
local CMD = {}

function CMD.start()
	msgIDs = require("proto.centerMsgID")

	protopack.init_proto("./lualib/proto/centerproto.txt", msgIDs)
end

function CMD.connect(fd, addr)
	tab_fd_addr[fd] = {ip = "addr", port = nil}
end

skynet.register_protocol {
    name = "client",  

    id = skynet.PTYPE_CLIENT,

    unpack = function (data, sz)
        return protopack.unpack(skynet.tostring(data, sz))
    end,

    dispatch = function (_, fd, name, tab)
        --g_eventMgr:dispatchEvent(name, tab)
    end
}


skynet.start(function() 
	skynet.dispatch("lua", function(_, _, cmd, subcmd, ...) 
        local f = CMD[cmd]
        skynet.ret(skynet.pack(f(subcmd, ...))) 
    end)
end)