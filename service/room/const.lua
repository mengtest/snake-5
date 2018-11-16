--
-- Author: xingxingtie
-- Date: 2018-09-17 15:47:06
-- 房间内常量

local M = {}

M.ROOM_CAPACITY = 10  --房间容量
M.INVIAL_OWNER  = -1  --没有房主

M.STATE_FREE    = 1   --自由状态
M.STATE_GAMING  = 2   --游戏状态

M.TURN_DELAY       = 10  --回合时长100毫秒
M.FIRST_TURN_DELAY = 5   --第一个回合触发idle 时长50毫秒

M.DIR_UP    = 1
M.DIR_DOWN  = 2
M.DIR_LEFT  = 3
M.DIR_RIGHT = 4

M.DIR_STEP = {
    [M.DIR_UP] =    {x = 0,  y = 1},
    [M.DIR_DOWN] =  {x = 0,  y = -1},
    [M.DIR_LEFT] =  {x = -1, y = 0},
    [M.DIR_RIGHT] = {x = 1,  y = 0},
}

M.CMD_NONE      = 0    --无命令
M.CMD_CHANG_DIR = 1    --改变方向
M.CMD_ADD_SPEED = 2    --加速

return M
