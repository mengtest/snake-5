--
-- Author: xingxingtie
-- Date: 2018-09-17 14:47:39
--
handler = function(obj, func)
    return function(...) 
        func(obj, ...)
    end
end