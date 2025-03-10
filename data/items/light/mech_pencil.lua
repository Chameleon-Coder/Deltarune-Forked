local item, super = Class(LightEquipItem, "light/mech_pencil")

function item:init()
    super:init(self)

    -- Display name
    self.name = "Mech. Pencil"

    -- Item type (item, key, weapon, armor)
    self.type = "weapon"

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    -- Equip bonuses (for weapons and armor)
    self.bonuses = {
        attack = 1,
        defense = 0
    }

    -- Default dark item conversion for this item
    self.dark_item = "mechasaber"
end

function item:onCheck()
    Game.world:showText("* \"Mechanical Pencil\" - 1 AT\n* It's tempting to click it repeatedly.")
end

return item