local movement = require("/api/movement")
local distance = tonumber((...)) or -1

local i = 0
while i ~= distance do
    movement.forward()
    i = i + 1
end
