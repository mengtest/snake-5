local sproto = require("sproto")
local socket = require("socket")

local M = {}

local sp = sproto.parse(buffer)

function M.id_to_name(id)
    return n
end

--压流
function M.pack(id, tab)
    local name = id_to_name(id)

    local buf = sp:encode(name, tab)

    return string.pack(">Hs2", id, buf)
end

--解流
function M.unpack(msg)
    local id, buf = string.unpack(">Hs2", msg)

    local name = id_to_name(id)

    return sp:decode(name, msg)
end

--发送数据
function send_data(fd, id, msg) 
    local data = M.pack(id, msg)

    socket.write(fd, data)
end


return M