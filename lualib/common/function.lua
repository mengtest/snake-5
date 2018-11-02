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