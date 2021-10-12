local Object = Class()

Object.CHILD_SORTER = function(a, b) return a.layer < b.layer end

function Object:init(x, y, width, height)
    -- Intitialize this object's position (optional args)
    self.x = x or 0
    self.y = y or 0

    -- Initialize this object's size
    self.width = width or 0
    self.height = height or 0

    -- Various draw properties
    self.color = {1, 1, 1, 1}
    self.scale_x = 1
    self.scale_y = 1
    self.rotation = 0
    
    -- Whether this object's color will be multiplied by its parent's color
    self.inherit_color = false

    -- Origin of the object's position
    self.origin_x = 0
    self.origin_y = 0
    -- Origin of the object's scaling
    self.scale_origin_x = nil
    self.scale_origin_y = nil
    -- Origin of the object's rotation
    self.rotate_origin_x = nil
    self.rotate_origin_y = nil

    -- Object scissor, no scissor when nil
    self.cutout_left = nil
    self.cutout_top = nil
    self.cutout_right = nil
    self.cutout_bottom = nil

    -- This object's sorting, higher number = renders last (above siblings)
    self.layer = 0

    -- Triggers list sort / child removal
    self.update_child_list = false
    self.children_to_remove = {}

    -- Whether this object updates
    self.active = true

    -- Whether this object draws
    self.visible = true

    self.parent = nil
    self.children = {}
end

--[[ Common overrides ]]--

function Object:update(dt)
    self:updateChildren(dt)
end

function Object:draw()
    self:drawChildren()
end

function Object:onAdd(parent) end
function Object:onRemove(parent) end

--[[ Common functions ]]--

function Object:move(x, y, speed)
    self.x = self.x + (x or 0) * (speed or 1)
    self.y = self.y + (y or 0) * (speed or 1)
end

function Object:setPosition(x, y) self.x = x or 0; self.y = y or 0 end
function Object:getPosition() return self.x, self.y end

function Object:setSize(width, height) self.width = width or 0; self.height = height or width or 0 end
function Object:getSize() return self.width, self.height end

function Object:setScale(x, y) self.scale_x = x or 1; self.scale_y = y or x or 1 end
function Object:getScale() return self.scale_x, self.scale_y end

function Object:setOrigin(x, y) self.origin_x = x or 0; self.origin_y = y or x or 0 end
function Object:getOrigin() return self.origin_x, self.origin_y end

function Object:setScaleOrigin(x, y) self.scale_origin_x = x; self.scale_origin_y = y or x end
function Object:getScaleOrigin() return self.scale_origin_x or self.origin_x, self.scale_origin_y or self.origin_y end

function Object:setRotateOrigin(x, y) self.rotate_origin_x = x; self.rotate_origin_y = y or x end
function Object:getRotateOrigin() return self.rotate_origin_x or self.origin_x, self.rotate_origin_y or self.origin_y end

function Object:getLayer() return self.layer end
function Object:setLayer(layer)
    self.layer = layer
    if self.parent then
        self.parent.child_layer_changed = true
    end
end

function Object:setCutout(left, top, right, bottom)
    self.cutout_left = left
    self.cutout_top = top
    self.cutout_right = right
    self.cutout_bottom = bottom
end
function Object:getCutout()
    return self.cutout_left, self.cutout_top, self.cutout_right, self.cutout_bottom
end

function Object:setScreenPos(x, y)
    self:setPosition(self:getFullTransform():transformPoint(x or 0, y or 0))
end
function Object:getScreenPos(x, y)
    return self:getFullTransform():inverseTransformPoint(x or 0, y or 0)
end

function Object:setRelativePos(other, x, y)
    local sx, sy = other:getFullTransform():inverseTransformPoint(x, y)
    self:setPosition(self:getFullTransform():transformPoint(sx, sy))
end
function Object:getRelativePos(other, x, y)
    local sx, sy = self:getFullTransform():transformPoint(x or 0, y or 0)
    return other:getFullTransform():inverseTransformPoint(sx, sy)
end

function Object:getStage()
    if self.parent and self.parent.parent then
        return self.parent:getStage()
    elseif self.parent then
        return self.parent
    end
end

function Object:getDrawColor()
    local r, g, b, a = unpack(self.color)
    if self.inherit_color and self.parent then
        local pr, pg, pb, pa = self.parent:getDrawColor()
        return r * pr, g * pg, b * pb, (a or 1) * (pa or 1)
    else
        return r, g, b, a or 1
    end
end

function Object:applyScissor()
    local left, top, right, bottom = self:getCutout()
    if left or top or right or bottom then
        Draw.scissorPoints(left, top, right and (self.width - right), bottom and (self.height - bottom))
    end
end

function Object:getTransform()
    local transform = love.math.newTransform()
    transform:translate(self.x - self.width * self.origin_x, self.y - self.height * self.origin_y)
    if self.scale_x ~= 1 or self.scale_y ~= 1 then
        transform:translate(self.width * (self.scale_origin_x or self.origin_x), self.height * (self.scale_origin_y or self.origin_y))
        transform:scale(self.scale_x, self.scale_y)
        transform:translate(self.width * -(self.scale_origin_x or self.origin_x), self.height * -(self.scale_origin_y or self.origin_y))
    end
    if self.rotation ~= 0 then
        transform:translate(self.width * (self.rotate_origin_x or self.origin_x), self.height * (self.rotate_origin_y or self.origin_y))
        transform:rotate(self.rotation)
        transform:translate(self.width * -(self.rotate_origin_x or self.origin_x), self.height * -(self.rotate_origin_y or self.origin_y))
    end
    return transform
end

function Object:getFullTransform()
    if not self.parent then
        return self:getTransform()
    else
        return self.parent:getFullTransform() * self:getTransform()
    end
end

function Object:remove()
    if self.parent then
        self.parent:removeChild(self)
    end
end

function Object:explode()
    if self.parent then
        local rx, ry = self:getRelativePos(self.parent, self.width/2, self.height/2)
        local e = Explosion(rx, ry)
        self.parent:addChild(e)
        self:remove()
    end
end

function Object:addChild(child)
    child.parent = self
    table.insert(self.children, child)
    child:onAdd(self)
    self.update_child_list = true
end

function Object:removeChild(child)
    if child.parent == self then
        child.parent = nil
    end
    self.children_to_remove[child] = true
    child:onRemove(self)
    self.update_child_list = true
end

--[[ Internal functions ]]--

function Object:updateChildList()
    for child,_ in pairs(self.children_to_remove) do
        for i,v in ipairs(self.children) do
            if v == child then
                table.remove(self.children, i)
                break
            end
        end
    end
    self.children_to_remove = {}
    table.sort(self.children, Object.CHILD_SORTER)
end

function Object:updateChildren(dt)
    if self.update_child_list then
        self:updateChildList()
        self.update_child_list = false
    end
    for _,v in ipairs(self.children) do
        if v.active then
            v:update(dt)
        end
    end
end

function Object:drawChildren()
    if self.update_child_list then
        self:updateChildList()
        self.update_child_list = false
    end
    local oldr, oldg, oldb, olda = love.graphics.getColor()
    for _,v in ipairs(self.children) do
        if v.visible then
            love.graphics.push()
            love.graphics.applyTransform(v:getTransform())
            love.graphics.setColor(v:getDrawColor())
            Draw.pushScissor()
            v:applyScissor()
            v:draw()
            Draw.popScissor()
            love.graphics.pop()
        end
    end
    love.graphics.setColor(oldr, oldg, oldb, olda)
end

return Object