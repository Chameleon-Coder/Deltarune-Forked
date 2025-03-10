local Actor = Class()

function Actor:init()
    -- Display name (optional)
    self.name = nil

    -- Width and height for this actor, used to determine its center
    self.width = 0
    self.height = 0

    -- Hitbox for this actor in the overworld (optional, uses width and height by default)
    self.hitbox = nil

    -- Color for this actor used in outline areas (optional, defaults to red)
    self.color = {1, 0, 0}

    -- Whether this actor flips horizontally (optional, values are "right" or "left", indicating the flip direction)
    self.flip = nil

    -- Path to this actor's sprites (defaults to "")
    self.path = ""
    -- This actor's default sprite or animation, relative to the path (defaults to "")
    self.default = ""

    -- Sound to play when this actor speaks (optional)
    self.voice = nil
    -- Path to this actor's portrait for dialogue (optional)
    self.portrait_path = nil
    -- Offset position for this actor's portrait (optional)
    self.portrait_offset = nil

    -- Table of talk sprites and their talk speeds (default 0.25)
    self.talk_sprites = {}

    -- Table of sprite animations
    self.animations = {}

    -- Table of sprite offsets (indexed by sprite name)
    self.offsets = {}
end

-- Callbacks

function Actor:onWorldUpdate(chara, dt) end
function Actor:onWorldDraw(chara) end

function Actor:onBattleUpdate(battler, dt) end
function Actor:onBattleDraw(battler) end

function Actor:onTalkStart(text, sprite) end
function Actor:onTalkEnd(text, sprite) end

-- Getters

function Actor:getName() return self.name or self.id end

function Actor:getWidth() return self.width end
function Actor:getHeight() return self.height end
function Actor:getSize() return self:getWidth(), self:getHeight() end

function Actor:getHitbox()
    if self.hitbox then
        return unpack(self.hitbox)
    else
        return 0, 0, self:getWidth(), self:getHeight()
    end
end

function Actor:getColor()
    if self.color then
        return self.color[1], self.color[2], self.color[3], self.color[4] or 1
    else
        return 1, 0, 0, 1
    end
end

function Actor:getFlipDirection() return self.flip end

function Actor:getSpritePath() return self.path or "" end

function Actor:getDefaultSprite() return self.default_sprite end
function Actor:getDefaultAnim() return self.default_anim end
function Actor:getDefault() return self:getDefaultAnim() or self:getDefaultSprite() or self.default or "" end

function Actor:getVoice() return self.voice end

function Actor:getPortraitPath() return self.portrait_path end
function Actor:getPortraitOffset() return unpack(self.portrait_offset or {0, 0}) end

function Actor:hasTalkSprite(sprite) return self.talk_sprites[sprite] ~= nil end
function Actor:getTalkSpeed(sprite) return self.talk_sprites[sprite] or 0.25 end

function Actor:getAnimation(anim) return self.animations[anim] end

function Actor:hasOffset(sprite) return self.offsets[sprite] ~= nil end
function Actor:getOffset(sprite) return unpack(self.offsets[sprite] or {0, 0}) end

-- Misc Functions

-- horrific
function Actor:parseSpriteOptions(full_sprite, ignore_frames)
    local prefix = self:getSpritePath().."/"
    local is_relative, relative_sprite = Utils.startsWith(full_sprite, prefix)
    if not is_relative and self:getSpritePath() ~= "" then
        return {}
    end

    local result = {relative_sprite}

    if not ignore_frames then
        local frames_for = Assets.getFramesFor(full_sprite)
        if frames_for then
            local success, frames_sprite = Utils.startsWith(frames_for, prefix)
            if success then
                table.insert(result, frames_sprite)
            end
            full_sprite = frames_for
        end
    end

    local dirs = {"left", "right", "up", "down"}

    for _, dir in ipairs(dirs) do
        local success, dir_sprite = Utils.endsWith(full_sprite, "_"..dir)
        if not success then
            success, dir_sprite = Utils.endsWith(full_sprite, "/"..dir)
        end
        if success then
            local relative, sprite = Utils.startsWith(dir_sprite, prefix)
            if relative then
                table.insert(result, sprite)
            end
        end
    end

    return result
end

return Actor