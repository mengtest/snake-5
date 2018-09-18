local sproto = require("sproto")
local socket = require("skynet.socket")
local msgdef = require("proto.msgdef")

local M = {}

local f = assert(io.open("./lualib/proto/gameproto.txt" , "rb"))
local buffer = f:read("*a")
f:close()
local sp = sproto.parse(buffer)

local findTable = nil

function M.id_to_name(id)
    if findTable == nil then 
        findTable = {}
        
        for k,v in pairs(msgdef) do 
            findTable[v] = k
        end
    end

    return findTable[id]
end

function M.name_to_id(name)

    print("name is:", name)
    for k,v in pairs(msgdef) do
        print(k, v)
    end

    return msgdef[name]
end

--压流 前四个字节为id
function M.pack(id, msgName, tab)
    local buf = sp:encode(msgName, tab)
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
    return name, sp:decode(name, buf)
end

--[[
    发送数据
    fd : sockct fd
    id : 协议号
    msgName : 协议名称
    msg : 协议内容
--]]
function M.send_data(fd, msgName, msg) 
    local id = M.name_to_id(msgName)

    assert(id, "找不到msg对应的id" .. msgName)

    local data = M.pack(id, msgName, msg)
    
    socket.write(fd, data)
end

return M