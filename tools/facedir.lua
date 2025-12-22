local movement = require("/api/movement")

local dir = string.lower(...)

if dir == "n" then
    movement.faceDir(1)
elseif dir == "e" then
    movement.faceDir(2)
elseif dir == "s" then
    movement.faceDir(3)
elseif dir == "w" then
    movement.faceDir(4)
else
    print("Invalid direction: Usage: facedir [n/e/s/w]")
end