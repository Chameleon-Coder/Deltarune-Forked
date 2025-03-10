local DarkItemMenu, super = Class(Object)

function DarkItemMenu:init()
    super:init(self, 92, 112, 457, 227)

    self.draw_children_below = 0

    self.font = Assets.getFont("main")

    self.ui_move = Assets.newSound("ui_move")
    self.ui_select = Assets.newSound("ui_select")
    self.ui_cant_select = Assets.newSound("ui_cant_select")
    self.ui_cancel_small = Assets.newSound("ui_cancel_small")

    self.heart_sprite = Assets.getTexture("player/heart")

    self.bg = UIBox(0, 0, self.width, self.height)
    self.bg.layer = -1
    self:addChild(self.bg)

    -- States: MENU, SELECT, USE
    self.state = "MENU"

    self.item_header_selected = 1
    self.item_selected_x = 1
    self.item_selected_y = 1

    self.selected_item = 1
end

function DarkItemMenu:getCurrentItemType()
    if self.item_header_selected == 3 then
        return "key_items"
    else
        return "items"
    end
end

function DarkItemMenu:getCurrentStorage()
    return Game.inventory:getStorage(self:getCurrentItemType())
end

function DarkItemMenu:getSelectedItem()
    return Game.inventory:getItem(self:getCurrentItemType(), self.selected_item)
end

function DarkItemMenu:updateSelectedItem()
    local items = self:getCurrentStorage()
    if #items == 0 then
        self.state = "MENU"
        Game.world.menu:setDescription("", false)
    else
        if self.selected_item > #items then
            self.item_selected_x = (#items - 1) % 2 + 1
            self.item_selected_y = math.floor((#items - 1) / 2) + 1
            self.selected_item = (2 * (self.item_selected_y - 1) + self.item_selected_x)
        elseif self.selected_item < 1 then
            self.item_selected_x = 1
            self.item_selected_y = 1
            self.selected_item = 1
        end
        if items[self.selected_item] then
            Game.world.menu:setDescription(items[self.selected_item]:getDescription(), true)
        else
            Game.world.menu:setDescription("", true)
        end
    end
end

function DarkItemMenu:useItem(item, party)
    local result = item:onWorldUse(party)
    if isClass(party) then
        party = {party}
    end
    for _,char in ipairs(party) do
        for index, chara in ipairs(Game.party) do
            local reaction = chara:getReaction(item, char)
            if reaction then
                Game.world.healthbar.action_boxes[index].reaction_alpha = 50
                Game.world.healthbar.action_boxes[index].reaction_text = reaction
            end
        end
    end
    if (item.type == "item" and (result == nil or result)) or (item.type ~= "item" and result) then
        if item:hasResultItem() then
            Game.inventory:replaceItem(item, item:createResultItem())
        else
            Game.inventory:removeItem(item)
        end
    end
    if item.type == "key" then
        local boxes = Game.world.healthbar.action_boxes
        for _, box in ipairs(boxes) do
            box.selected = true
        end
    end
    self:updateSelectedItem()
end

function DarkItemMenu:update(dt)
    if self.state == "MENU" then
        if Input.pressed("cancel") then
            self.ui_cancel_small:stop()
            self.ui_cancel_small:play()
            Game.world.menu:closeBox()
            return
        end
        if Input.pressed("left") then
            self.item_header_selected = self.item_header_selected - 1
            self.ui_move:stop()
            self.ui_move:play()
        end
        if Input.pressed("right") then
            self.item_header_selected = self.item_header_selected + 1
            self.ui_move:stop()
            self.ui_move:play()
        end
        if self.item_header_selected < 1 then self.item_header_selected = 3 end
        if self.item_header_selected > 3 then self.item_header_selected = 1 end
        if Input.pressed("confirm") and (#Game.inventory:getStorage(self:getCurrentItemType()) > 0) then
            self.ui_select:stop()
            self.ui_select:play()
            self.item_selected_x = 1
            self.item_selected_y = 1
            self.selected_item = 1
            self.state = "SELECT"

            self:updateSelectedItem()
        end
    elseif self.state == "SELECT" then
        if Input.pressed("cancel") then
            self.ui_cancel_small:stop()
            self.ui_cancel_small:play()
            self.state = "MENU"

            Game.world.menu:setDescription("", false)
            return
        end
        local old_x, old_y = self.item_selected_x, self.item_selected_y
        if Input.pressed("left") or Input.pressed("right") then
            if self.item_selected_x == 1 then
                self.item_selected_x = 2
            else
                self.item_selected_x = 1
            end
        end
        if Input.pressed("up") then
            self.item_selected_y = self.item_selected_y - 1
        end
        if Input.pressed("down") then
            self.item_selected_y = self.item_selected_y + 1
        end
        local items = self:getCurrentStorage()
        if self.item_selected_y < 1 then self.item_selected_y = 1 end
        if (2 * (self.item_selected_y - 1) + self.item_selected_x) > #items then
            if (#items % 2) ~= 0 then
                self.item_selected_x = ((#items - 1) % 2) + 1
            end
            self.item_selected_y = math.floor((#items - 1) / 2) + 1
        end
        self.selected_item = (2 * (self.item_selected_y - 1) + self.item_selected_x)
        if self.item_selected_y ~= old_y or self.item_selected_x ~= old_x then
            self.ui_move:stop()
            self.ui_move:play()
            self:updateSelectedItem()
        end
        if Input.pressed("confirm") then
            --self.selected_item = (2 * (self.item_selected_y - 1) + self.item_selected_x)
            local item = items[self.selected_item]
            if self.item_header_selected == 2 then
                self.state = "USE"

                self.ui_select:stop()
                self.ui_select:play()

                Game.world.menu:setDescription("Really throw away the\n" .. item:getName() .. "?")
                Game.world.menu:partySelect("ALL", function(success, party)
                    self.state = "SELECT"
                    if success then
                        self.ui_cancel_small:stop()
                        self.ui_cancel_small:play()

                        local result = item:onToss()

                        if result ~= false then
                            Game.inventory:removeItem(item)
                        end
                    end
                    self:updateSelectedItem()
                end)
            elseif item.usable_in == "world" or item.usable_in == "all" then
                if item.target == "ally" or item.target == "party" then
                    self.state = "USE"

                    local target_type = item.target == "ally" and "SINGLE" or "ALL"

                    if target_type == "SINGLE" then -- yep, deltarune bug
                        self.ui_select:stop()
                        self.ui_select:play()
                    end

                    Game.world.menu:partySelect(target_type, function(success, party)
                        self.state = "SELECT"
                        if success then
                            self:useItem(item, party)
                        end
                        self:updateSelectedItem()
                    end)
                else
                    self:useItem(item, Game.party)
                end
            else
                self.ui_cant_select:stop()
                self.ui_cant_select:play()
            end
        end
    end

    super:update(self, dt)
end

function DarkItemMenu:draw()
    love.graphics.setFont(self.font)

    local headers = {"USE", "TOSS", "KEY"}

    for i,name in ipairs(headers) do
        if self.state == "MENU" then
            love.graphics.setColor(1, 1, 1, 1)
        elseif self.item_header_selected == i then
            love.graphics.setColor(255/255, 160/255, 64/255)
        else
            love.graphics.setColor(128/255, 128/255, 128/255)
        end
        local x = 88 + ((i - 1) * 120)
        love.graphics.print(name, x, -2)
    end

    local heart_x = 20
    local heart_y = 20

    if self.state == "MENU" then
        heart_x = 88 + ((self.item_header_selected - 1) * 120) - 25
        heart_y = 8
    elseif self.state == "SELECT" then
        heart_x = 28 + (self.item_selected_x - 1) * 210
        heart_y = 50 + (self.item_selected_y - 1) * 30
    end
    if self.state ~= "USE" then
        love.graphics.setColor(Game:getSoulColor())
        love.graphics.draw(self.heart_sprite, heart_x, heart_y)
    end

    local item_x = 0
    local item_y = 0
    local inventory = self:getCurrentStorage()

    for index, item in ipairs(inventory) do
        -- Draw the item shadow
        love.graphics.setColor(51/255, 32/255, 51/255, 1)
        love.graphics.print(item:getName(), 54 + (item_x * 210) + 2, 40 + (item_y * 30) + 2)

        if self.state == "MENU" then
            love.graphics.setColor(128/255, 128/255, 128/255, 1)
        else
            if item.usable_in == "world" or item.usable_in == "all" then
                love.graphics.setColor(1, 1, 1, 1)
            else
                love.graphics.setColor(192/255, 192/255, 192/255, 1)
            end
        end
        love.graphics.print(item:getName(), 54 + (item_x * 210), 40 + (item_y * 30))
        item_x = item_x + 1
        if item_x >= 2 then
            item_x = 0
            item_y = item_y + 1
        end
    end

    super:draw(self)
end

return DarkItemMenu