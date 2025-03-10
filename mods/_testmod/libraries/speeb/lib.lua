local lib = {}

function lib:init()
    print("Loaded speeb library....watch out")

    Utils.hook(Player, "update", function(orig, self, dt)
        if self.run_timer > 60 then
            self.walk_speed = self.walk_speed + dt
        elseif self.walk_speed > 4 then
            self.walk_speed = 4
        end

        orig(self, dt)

        if self.last_collided_x or self.last_collided_y then
            if self.walk_speed >= 16 then
                self:explode()
                Game.world.music:stop()

                Game.stage.timer:after(2, function()
                    local rect = Rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
                    rect:setColor(0, 0, 0)
                    rect:setLayer(100000)
                    rect.alpha = 0
                    Game.stage:addChild(rect)

                    Game.stage.timer:tween(2, rect, {alpha = 1}, "linear", function()
                        rect:remove()
                        Game:gameOver(0, 0)
                        Game.soul:remove()
                        Game.soul = nil
                        Game.gameover_screenshot = nil
                        Game.gameover_timer = 150
                        Game.gameover_stage = 4
                    end)
                end)
            elseif self.walk_speed >= 10 then
                Game.world:hurtParty(20)
            end
        end
    end)
end

--[[function lib:onFootstep(chara, num)
    if chara:includes(Player) and love.math.random() < 0.01 then
        chara:explode()
        Game.world.music:stop()
    end
end]]

return lib