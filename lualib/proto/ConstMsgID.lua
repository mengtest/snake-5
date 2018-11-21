--协议号

local M = {}

--登录
M.c2s_login = 0
M.s2c_login = 1

M.c2s_register = 2
M.s2c_register = 3

--大厅
M.c2s_listTeam = 100
M.s2c_listTeam = 101 

M.c2s_createTeam = 102
M.s2c_createTeam = 103

M.c2s_enterTeam = 104
M.s2c_enterTeam = 105

M.s2c_playerJoinTeam  = 106
M.c2s_playerLeaveTeam = 107
M.s2c_playerLeaveTeam = 108

M.c2s_teamMatch = 109
M.s2c_teamMatch = 110



M.c2s_listRoom = 111
M.s2c_listRoom = 112

M.c2s_createRoom = 113
M.s2c_createRoom = 114

M.c2s_enterRoom = 115
M.s2c_enterRoom = 116

M.c2s_playerMatch = 117
M.s2c_playerMatch = 118

--房间
M.c2s_roomInfo = 200     
M.s2c_roomInfo = 201     

M.s2c_playerJoinRoom = 202

M.c2s_playerLeaveRoom = 203
M.s2c_playerLeaveRoom = 204

M.c2s_startGame = 205
M.s2c_startGame = 206

M.c2s_userCommand = 207
M.s2c_turnCommand = 208

M.c2s_changeSeat = 209
M.s2c_changeSeat = 210

M.c2s_loadComplete = 211
M.s2c_launch       = 212

return M