local item, super = Class(Item, "light/ball_of_junk")

function item:init(inventory)
    super:init(self)

    -- Display name
    self.name = "Ball of Junk"

    -- Item type (item, key, weapon, armor)
    self.type = "item"

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    -- Ball of Junk inventory
    self.inventory = inventory or DarkInventory()
end

function item:onWorldUse()
    Game.world:showText("* You looked at the junk ball in\nadmiration.[wait:5]\n* Nothing happened.")
    return false
end

function item:onCheck()
    Game.world:showText("* \"Ball of Junk\" - A small ball\nof accumulated things in your\npocket.")
end

function item:onToss()
    Game.world:startCutscene(function(cutscene)
        if Game.chapter == 1 then
            cutscene:text("* You really didn't want to throw\nit away.")
        else
            cutscene:text("* You took it from your pocket.[wait:5]\n"..
                          "* You have a [color:yellow]very,[wait:5] very,[wait:5] bad\n"..
                            "feeling[color:reset] about throwing it away.")
        end
        cutscene:text("* Throw it away anyway?")

        local dropped
        if Game.chapter == 1 then
            dropped = cutscene:choicer({"No", "Yes"}) == 2
        else
            dropped = cutscene:choicer({"Yes", "No"}) == 1
        end

        if dropped then
            Game.inventory:removeItem(self)

            Assets.playSound("snd_bageldefeat")
            cutscene:text("* Hand shaking,[wait:5] you dropped the\nball of junk on the ground.")
            cutscene:text("* It broke into pieces.")
            cutscene:text("* You felt bitter.")
        else
            cutscene:text("* You felt a feeling of relief.")
        end
    end)
    return false
end

function item:convertToDark(inventory)
    for k,storage in pairs(self.inventory.storages) do
        for i = 1, storage.max do
            if storage[i] then
                if not inventory:addItemTo(storage.id, i, storage[i]) then
                    inventory:addItem(storage[i])
                end
            end
        end
    end
    return true
end

function item:onSave(data)
    data.inventory = self.inventory:save()
end

function item:onLoad(data)
    self.inventory = DarkInventory()
    self.inventory:load(data.inventory)
end

return item