--
-- Author: xingxingtie
-- Date: 2018-09-17 16:40:49
-- 网络协议id定义

local M = {}
--登录
M.c2s_login = 0
M.s2c_login = 1

--大厅
M.c2s_match = 100
M.s2c_match = 101

--房间
M.c2s_userop = 200      --玩家操作
M.s2c_turnop = 201      --一轮的玩家操作集合

return M