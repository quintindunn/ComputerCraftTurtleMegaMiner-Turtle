local logger = require("/api/logger").getLogger("ExternalInventoryUtil")

--[[
Returns the first empty slot in an inventory
]]
function ExtGetEmptySlot(src)
    local size = src.size()

    local i = 1
    for slot, item in pairs(src.list()) do
        if slot > i then
            logger("Empty Slot "..tostring(i))
            return i
        end
        i = i + 1
    end

    if i <= size then
        return i
    end   
    logger("WARNING: NO EMPTY SLOT FOUND!")
end

--[[
Swaps two slots contents in an inventory, requires that there's at least one empty slot.
]]
function swapChestSlots(src, slotA, slotB)
    local pName = peripheral.getName(src)
    local emptySlot = ExtGetEmptySlot(src)
    
    if slotA == emptySlot then
        src.pullItems(pName, slotB, nil, slotA)
        return
    end
    
    if slotB == emptySlot then
        src.pullItems(pName, slotA, nil, slotB)
        return
    end
    
    src.pullItems(pName, slotA, nil, emptySlot)
    src.pullItems(pName, slotB, nil, slotA)
    src.pullItems(pName, emptySlot, nil, slotB)
end

function pullFromSlot(src, slot, --[[optional]]limit, --[[optional]]dstSlot)
    swapChestSlots(src, 1, slot)
    limit = limit or 64
    local initialSlot = turtle.getSelectedSlot()

    if dstSlot ~= nil then
        turtle.select(dstSlot)
    end
    
    turtle.suck(limit)
    turtle.select(initialSlot)
end

--[[
Returns the slot of the first instance of an item in an inventory
]]
function findItemInSrc(src, itemName)
    for slot, item in pairs(src.list()) do
        if item.name == itemName then
            return slot
        end
    end
    
    return nil
end

--[[
Gets an item from a peripheral and places it in dst slot or the first available slot
]]
function getItemFromSrc(src, itemName, --[[OPTIONAL]]limit, --[[optional]]dstSlot)
    slot = findItemInSrc(src, itemName)
    if slot == nil then
        logger("WARNING: Item: \"" .. itemName .. "\" not in " .. peripheral.getName(src))
    end
    pullFromSlot(src, slot, limit, dstSlot)
end

--[[
Checks if there is a block in front of the turtle
]]
function isBlockInFront()
    return turtle.detect()
end

--[[
Gets an item from the EChest (in slot 1) and places it in dstSlot or the first available slot
]]
function getItemFromEChest(itemName, --[[optional]]dstSlot)
    local initialSlot = turtle.getSelectedSlot()

    if isBlockInFront() then
        turtle.dig()
    end
    
    turtle.select(1)
    turtle.place()
    
    local echest = peripheral.wrap("front")
    
    if dstSlot ~= nil then
        turtle.select(dstSlot)
    end

    getItemFromSrc(echest, itemName, 1, dstSlot)
    turtle.select(1)
    turtle.dig()

    turtle.select(initialSlot)
end

function pushSlotToEChest(eChestSlot, srcSlot, --[[optional]]limit)
    local initialSlot = turtle.getSelectedSlot()

    if isBlockInFront() then
        turtle.dig()
    end

    limit = limit or 64

    turtle.select(eChestSlot)
    turtle.place()
    turtle.select(srcSlot)
    turtle.drop()
    turtle.select(eChestSlot)
    turtle.dig()
    turtle.select(initialSlot)
end

return { getItemFromEChest = getItemFromEChest, ExtGetEmptySlot = ExtGetEmptySlot, swapChestSlots = swapChestSlots, pullFromSlot = pullFromSlot, findItemInSrc = findItemInSrc, getItemFromSrc = getItemFromSrc, pushSlotToEChest = pushSlotToEChest }
