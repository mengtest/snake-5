local teamID = 1

local M = {}
M.__index = M

function M.new()
    local obj = setmetatable({
        obj.id = teamID,
        obj.leaderID = nil,
        capacity = 5,
        playerList = {},
    }, M)

    teamID = teamID + 1
    return obj
end

function M:_packInfo(leaderName)
    return {
        teamID = v.id,
        leaderName = leaderName,
        capacity = v.capacity,
        playerNum = #v.playerList
    }
end

function M:_changeLeader()
    if #self.playerList == 0 then 
        self.leaderID = nil
    else 
        self.leaderID = self.playerList[1] 
    end
end

function M:addPlayer(playerID)
    table.insert(playerID)
end

function M:deletePlayer(playerID)
    for i,v in ipairs(self.playerList) do 
        if v == playerID then 
            table.remove(self.playerList, i)
            if i == 1 then 
               self:_changeLeader()
            end
            break
        end
    end
end

return M