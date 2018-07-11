local sproto = require("sproto")
local socket = require("skynet.socket")

local M = {}
local id_table = {
    [100] = "person"
}

local f = assert(io.open("./proto.txt" , "rb"))
local buffer = f:read("*a")
f:close()
local sp = sproto.parse(buffer)

function M.id_to_name(id)
    return id_table[id]
end

--压流 前四个字节为id
function M.pack(id, tab)
    local name = M.id_to_name(100)

    local buf = sp:encode(name, tab)
    local len = string.len(buf)
    local pack_size = len + 4

    return string.pack(">HI4c"..len, pack_size, id, buf)
end

--解流 前四个字节为id
function M.unpack(msg)
    local len = string.len(msg) - 4
    if len < 0 then 
        return
    end

    local id, buf = string.unpack(">I4c"..len, msg)

    local name = M.id_to_name(id)
    return id, sp:decode(name, buf)
end

--发送数据
function M.send_data(fd, id, msg) 
    local data = M.pack(id, msg)

    socket.write(fd, data)
end

return M