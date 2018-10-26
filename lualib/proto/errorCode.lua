--错误码

local M = {
    OK = 0,                     [0] = "ok",
    NOT_IN_HALL = 1,            [1] = "不在大厅内",
    ALREADY_MATCHING = 2,       [2] = "已经在匹配中",
    ALREADY_IN_HALL = 3,        [3] = "已在大厅中",
    TEAM_NOT_CREATE_TEAM = 4,   [4] = "已在队伍中无法创建队伍",
    ROOM_NOT_CREATE_TEAM = 5,   [5] = "已在房间中无法创建队伍",
    ALREADY_IN_TEAM = 3,        [3] = "已在队伍中",
    ALREADY_IN_ROOM = 3,        [3] = "已在房间中",
    TEAM_NOT_EXIST = 3,         [3] = "队伍不存在",
    TEAM_IS_FULL = 3,           [3] = "队伍已满员",
    NOT_IN_TEAM = 3,            [3] = "没在队伍中",
    ROOM_NOT_LEAVE_TEAM = 5,    [5] = "已在房间中无法离队",
}

return M