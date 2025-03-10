local Event, super = Class(Object)

function Event:init(x, y, w, h)
    if type(x) == "table" then
        local data = x
        x, y = data.x, data.y
        w, h = data.width, data.height
    elseif type(w) == "table" then
        local data = w
        w, h = data.width, data.height
    end

    super:init(self, x, y, w, h)

    self._default_collider = Hitbox(self, 0, 0, self.width, self.height)
    if not self.collider then
        self.collider = self._default_collider
    end

    -- Whether this object should stop the player
    self.solid = false

    -- ID of the object in the current room (automatically set after init)
    self.object_id = nil
    -- User-defined ID of the object used for save variables (optional, automatically set after init)
    self.unique_id = nil

    -- Sprite object, gets set by setSprite()
    self.sprite = nil
end

--[[ OPTIONAL FUNCTIONS

function Event:onInteract(player, dir)
    -- Do stuff when the player interacts with this object (CONFIRM key)
    return false
end

function Event:onCollide(player, dt)
    -- Do stuff every frame the player collides with the object
end

function Event:onEnter(player)
    -- Do stuff when the player enters this object
end

function Event:onExit(player)
    -- Do stuff when the player leaves this object
end

]]--

function Event:onAdd(parent)
    if parent:includes(World) then
        self.world = parent
    elseif parent.world then
        self.world = parent.world
    end
end

function Event:onRemove(parent)
    if parent:includes(World) or parent.world then
        self.world = nil
    end
end

function Event:getUniqueID()
    if self.unique_id then
        return self.unique_id
    else
        return (self.world or Game.world).map:getUniqueID() .. "#" .. self.object_id
    end
end

function Event:setFlag(flag, value)
    local uid = self:getUniqueID()
    Game:setFlag(uid..":"..flag, value)
end

function Event:getFlag(flag, default)
    local uid = self:getUniqueID()
    return Game:getFlag(uid..":"..flag, default)
end

function Event:setSprite(texture, speed, use_size)
    if texture then
        if self.sprite then
            self:removeChild(self.sprite)
        end
        self.sprite = Sprite(texture)
        self.sprite:setScale(2)
        if speed then
            self.sprite:play(speed)
        end
        self:addChild(self.sprite)
        if not self.collider or self.collider == self._default_collider then
            self.collider = Hitbox(self, 0, 0, self.sprite.width * 2, self.sprite.height * 2)
        end
        if use_size or use_size == nil then
            self:setSize(self.sprite.width*2, self.sprite.height*2)
        end
    elseif self.sprite then
        self:removeChild(self.sprite)
        self.sprite = nil
    end
end

function Event:draw()
    super:draw(self)
    if DEBUG_RENDER then
        self.collider:draw(1, 0, 1)
    end
end

return Event