local logger = require("/api/logger").getLogger("InventoryUtils")

function getEmptySlot()
    local initialSlot = turtle.getSelectedSlot()

    local turtleInventorySize = 16
    for i = 1, turtleInventorySize do
        turtle.select(i)
        local details = turtle.getItemDetail()
        if details == nil then
            turtle.select(initialSlot)
            return i
        end
    end

    turtle.select(initialSlot)
    logger("WARNING: No empty slot in inventory!")
    return nil
end

function getSlotOfItem(itemName)
    local initialSlot = turtle.getSelectedSlot()

    local turtleInventorySize = 16
    for i = 1, turtleInventorySize do
        turtle.select(i)
        local details = turtle.getItemDetail()
        if details ~= nil and details.name == itemName then
            turtle.select(initialSlot)
            return i
        end
    end

    turtle.select(initialSlot)
    return nil
end

return { getEmptySlot = getEmptySlot, getSlotOfItem = getSlotOfItem}