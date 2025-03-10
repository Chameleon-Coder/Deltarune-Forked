local item, super = Class(Item, "light/egg")

function item:init()
    super:init(self)

    -- Display name
    self.name = "Egg"

    -- Item type (item, key, weapon, armor)
    self.type = "key"

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil
end

function item:onWorldUse()
    Assets.playSound("snd_egg")
    Game.world:showText("* You used the Egg.")
    return false
end

function item:onCheck()
    Game.world:showText("* \"Egg\" - Not too important,[wait:5] not\ntoo unimportant.")
end

function item:onToss()
    Game.world:showText("* What Egg?")
    return true
end

function item:convertToDark(inventory)
    return "egg"
end

return item