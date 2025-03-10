local Spell = Class()

function Spell:init()
    -- Display name
    self.name = "Test Spell"
    -- Name displayed when cast (optional)
    self.cast_name = nil

    -- Battle description
    self.effect = ""
    -- Menu description
    self.description = ""

    -- TP cost
    self.cost = 0

    -- Target mode (ally, party, enemy, enemies, or none)
    self.target = "none"

    -- Tags that apply to this spell
    self.tags = {}
end

function Spell:getName() return self.name end
function Spell:getCastName() return self.cast_name or self:getName():upper() end

function Spell:getDescription() return self.description end
function Spell:getBattleDescription() return self.effect end

function Spell:getTPCost(chara) return self.cost end

function Spell:hasTag(tag)
    return Utils.containsValue(self.tags, tag)
end

function Spell:getCastMessage(user, target)
    return "* "..user.chara:getName().." cast "..self:getCastName().."!"
end

function Spell:onCast(user, target)
    -- Returning false here allows you to call 'Game.battle:finishActionBy(user)' yourself
end

function Spell:onStart(user, target)
    Game.battle:battleText(self:getCastMessage(user, target))
    user:setAnimation("battle/spell", function()
        local result = self:onCast(user, target)
        if result or result == nil then
            Game.battle:finishActionBy(user)
        end
    end)
end

return Spell