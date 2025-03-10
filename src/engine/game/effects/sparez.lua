local SpareZ, super = Class(Sprite)

function SpareZ:init(angle, x, y)
    super:init(self, "effects/spare/z", x, y)

    self:setOrigin(0.5, 0.5)
    self:fadeOutAndRemove(0.1)

    self.grow_x = 0.2
    self.grow_y = 0.2

    self.physics.speed = 12
    self.physics.direction = math.rad(angle)
    self.physics.friction = 1
end

function SpareZ:update(dt)
    self.scale_x = self.scale_x + self.grow_x * DTMULT
    self.scale_y = self.scale_y + self.grow_y * DTMULT

    super:update(self, dt)
end

return SpareZ