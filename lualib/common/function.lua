--
-- Author: xingxingtie
-- Date: 2018-09-17 14:47:39
--
handler = function(obj, func)
    return function(...) 
        func(obj, ...)
    end
end

split = function( str, reps )
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

table.indexof = function(tab, elem)
    for i,v in ipairs(tab) do
        if v == elem then 
            return i
        end
    end
end