--错误码

local M = {
    OK = 0,                     [0] = "ok",
    NOT_IN_HALL = 1,            [1] = "不在大厅内",
    ALREADY_MATCHING = 2,       [2] = "已经在匹配中",
    ALREADY_IN_HALL = 3,        [3] = "已在大厅中",
    TEAM_NOT_CREATE_TEAM = 4,   [4] = "已在队伍中无法创建队伍",
    ROOM_NOT_CREATE_TEAM = 5,   [5] = "已在房间中无法创建队伍",
    ALREADY_IN_TEAM = 6,        [6] = "已在队伍中",
    ALREADY_IN_ROOM = 7,        [7] = "已在房间中",
    TEAM_NOT_EXIST = 8,         [8] = "队伍不存在",
    TEAM_IS_FULL = 9,           [9] = "队伍已满员",
    NOT_IN_TEAM = 10,           [10] = "没在队伍中",
    ROOM_NOT_LEAVE_TEAM = 11,   [11] = "已在房间中无法离队",

    SERVER_ERROR = 12,          [12] = "内部错误",    
    ACCOUNT_EMPTY = 13,         [13] = "账号不能为空",    
    PASSWORD_EMPTY = 14,        [14] = "密码不能为空",    
    ACCOUT_EXIST = 15,          [15] = "账号已被注册",    
    NO_ACCOUNT = 16,            [16] = "没有此账号",    
    WRONG_PASSWORD = 17,        [17] = "密码错误",    

	NONE_ROOM = 18, 	        [18] = "房间不存在",    
	ROOM_IS_FULL = 19,  	    [19] = "房间已满员",   
    NOT_IN_ROOM = 20,           [20] = "没在房间中",   

    --room---------------------------------------------- 
    SEAT_HAVE_PLAYER = 21,      [21] = "座位上已有人",
    OWNER_START_GAME = 22,      [22] = "房主才能开启游戏",
}

return M