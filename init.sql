
-- 删除表
drop table playerinfo;

-- 账号表
CREATE TABLE IF NOT EXISTS `playerinfo`(
   `account` VARCHAR(100) NOT NULL,
   `password` VARCHAR(40) NOT NULL,
   `userid` BIGINT NOT NULL,
   PRIMARY KEY ( `account` )
)DEFAULT CHARSET=utf8;

-- 玩家信息表
CREATE TABLE IF NOT EXISTS `gameinfo`(
   `userid`   BIGINT NOT NULL,
   `wincount` INT NOT NULL,         -- 赢的次数
   `losecount` INT NOT NULL,        -- 输的次数
   PRIMARY KEY ( `userid` )
)DEFAULT CHARSET=utf8;