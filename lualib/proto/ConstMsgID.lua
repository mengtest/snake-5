--协议号

local M = {}

--登录
M.c2s_login = 0
M.s2c_login = 1

M.c2s_register = 2
M.s2c_register = 3

--大厅
M.c2s_match = 100
M.s2c_match = 101

M.c2s_listRoom = 102
M.s2c_listRoom = 103

M.c2s_createRoom = 104
M.s2c_createRoom = 105

M.c2s_enterRoom = 106
M.s2c_enterRoom = 107

--房间
M.c2s_userop = 200         --玩家操作
M.s2c_turnop = 201         --一轮的玩家操作集合
M.s2c_gamestart = 202      --游戏开始

return M