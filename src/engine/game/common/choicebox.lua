local Choicebox, super = Class(Object)

function Choicebox:init(x, y, width, height, battle_box)
    super:init(self, x, y, width, height)

    self.box = UIBox(0, 0, width, height)
    self.box.layer = -1
    self:addChild(self.box)

    self.battle_box = battle_box
    if battle_box then
        self.box.visible = false
    end

    self.choices = {}

    self.current_choice = 0
    self.selected_choice = nil

    self.done = false

    self.font = Assets.getFont("main")

    self.heart = Assets.getTexture("player/heart_menu")
end

function Choicebox:update(dt)
    local old_choice = self.current_choice
    if Input.pressed("left")  then self.current_choice = 1 end
    if Input.pressed("right") then self.current_choice = 2 end
    if Input.pressed("up")    then self.current_choice = 3 end
    if Input.pressed("down")  then self.current_choice = 4 end

    if self.current_choice > #self.choices then
        self.current_choice = old_choice
    end

    if Input.pressed("confirm") then
        if self.current_choice ~= 0 then
            self.selected_choice = self.current_choice

            self.done = true

            if not self.battle_box then
                self:remove()
                if Game.world:hasCutscene() then
                    Game.world.cutscene.choice = self.selected_choice
                    Game.world.cutscene:tryResume()
                end
            else
                self:clearChoices()
                self.active = false
                self.visible = false
                Game.battle.battle_ui.encounter_text.active = true
                Game.battle.battle_ui.encounter_text.visible = true
                if Game.battle:hasCutscene() then
                    Game.battle.cutscene.choice = self.selected_choice
                    Game.battle.cutscene:tryResume()
                end
            end
        end
    end
    super:update(self, dt)
end

function Choicebox:draw()
    super:draw(self)
    love.graphics.setFont(self.font)
    if self.choices[1] then
        love.graphics.setColor(1, 1, 1, 1)
        if self.current_choice == 1 then love.graphics.setColor(1, 1, 0, 1) end
        love.graphics.print(self.choices[1], 36, 24)
    end
    if self.choices[2] then
        love.graphics.setColor(1, 1, 1, 1)
        if self.current_choice == 2 then love.graphics.setColor(1, 1, 0, 1) end
        love.graphics.print(self.choices[2], 528 - self.font:getWidth(self.choices[2]), 24)
    end
    if self.choices[3] then
        love.graphics.setColor(1, 1, 1, 1)
        if self.current_choice == 3 then love.graphics.setColor(1, 1, 0, 1) end
        love.graphics.print(self.choices[3], 17 + Utils.round(self.width / 2) - Utils.round(self.font:getWidth(self.choices[3]) / 2), -8)
    end
    if self.choices[4] then
        love.graphics.setColor(1, 1, 1, 1)
        if self.current_choice == 4 then love.graphics.setColor(1, 1, 0, 1) end
        love.graphics.print(self.choices[4], 17 + Utils.round(self.width / 2) - Utils.round(self.font:getWidth(self.choices[4]) / 2), 78)
    end

    local soul_positions = {
        --[[ Center: ]] {224, 38},
        --[[ Left:   ]] {4,   34},
        --[[ Right:  ]] {528 - self.font:getWidth(self.choices[2] or "") - 32, 34},
        --[[ Top:    ]] {17 + Utils.round(self.width / 2) - Utils.round(self.font:getWidth(self.choices[3] or "") / 2) - 32, -8 + 6},
        --[[ Bottom: ]] {17 + Utils.round(self.width / 2) - Utils.round(self.font:getWidth(self.choices[4] or "") / 2) - 32, 78 + 6}
    }

    local heart_x = soul_positions[self.current_choice + 1][1]
    local heart_y = soul_positions[self.current_choice + 1][2]

    love.graphics.setColor(Game:getSoulColor())
    love.graphics.draw(self.heart, heart_x, heart_y, 0, 2, 2)
end

function Choicebox:setSize(w, h)
    self.width, self.height = w or 0, h or 0

    self.text:setSize(self.width, self.height)
    self.box:setSize(self.width, self.height)
end

function Choicebox:clearChoices()
    self.choices = {}
    self.current_choice = 0
end

function Choicebox:addChoice(name)
    table.insert(self.choices, name)
end

function Choicebox:getBorder()
    if self.box.visible then
        return self.box:getBorder()
    else
        return 0, 0
    end
end

return Choicebox