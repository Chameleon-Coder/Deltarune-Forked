local actor, super = Class(Actor, "noelle")

function actor:init()
    super:init(self)

    -- Display name (optional)
    self.name = "Noelle"

    -- Width and height for this actor, used to determine its center
    self.width = 23
    self.height = 46

    -- Hitbox for this actor in the overworld (optional, uses width and height by default)
    self.hitbox = {2, 33, 19, 14}

    -- Color for this actor used in outline areas (optional, defaults to red)
    self.color = {1, 1, 0}

    -- Path to this actor's sprites (defaults to "")
    self.path = "party/noelle/dark"
    -- This actor's default sprite or animation, relative to the path (defaults to "")
    self.default = "walk"

    -- Sound to play when this actor speaks (optional)
    self.voice = "noelle"
    -- Path to this actor's portrait for dialogue (optional)
    self.portrait_path = "face/noelle"
    -- Offset position for this actor's portrait (optional)
    self.portrait_offset = {-12, -10}

    -- Table of sprite animations
    self.animations = {
        -- Battle animations
        ["battle/idle"]         = {"battle/idle", 0.2, true},

        ["battle/attack"]       = {"battle/attack", 1/15, false},
        ["battle/act"]          = {"battle/act", 1/15, false},
        ["battle/spell"]        = {"battle/spell", 1/15, false, next="battle/idle"},
        ["battle/item"]         = {"battle/item", 1/12, false, next="battle/idle"},
        ["battle/spare"]        = {"battle/spell", 1/15, false, next="battle/idle"},

        ["battle/attack_ready"] = {"battle/attackready", 0.2, true},
        ["battle/act_ready"]    = {"battle/actready", 0.2, true},
        ["battle/spell_ready"]  = {"battle/spellready", 0.2, true},
        ["battle/item_ready"]   = {"battle/itemready", 0.2, true},
        ["battle/defend_ready"] = {"battle/defend", 1/15, false},

        ["battle/act_end"]      = {"battle/actend", 1/15, false, next="battle/idle"},

        ["battle/hurt"]         = {"battle/hurt", 1/15, false, temp=true, duration=0.5},
        ["battle/defeat"]       = {"battle/defeat", 1/15, false},

        ["battle/transition"]   = {"battle/intro", 1/15, false},
        ["battle/victory"]      = {"battle/victory", 1/10, false},

        -- Cutscene animations
        ["laugh"]               = {"laugh", 4/30, true},
    }

    -- Table of sprite offsets (indexed by sprite name)
    self.offsets = {
        -- Movement offsets
        ["walk/down"] = {0, 0},
        ["walk/right"] = {0, 0},
        ["walk/left"] = {0, 0},
        ["walk/up"] = {0, 0},

        ["walk_smile/down"] = {0, 0},
        ["walk_smile/right"] = {0, 0},
        ["walk_smile/left"] = {0, 0},
        ["walk_smile/up"] = {0, 0},

        ["walk_happy/down"] = {0, 0},
        ["walk_happy/right"] = {0, 0},
        ["walk_happy/left"] = {0, 0},
        ["walk_happy/up"] = {0, 0},

        ["walk_blush/down"] = {0, 0},
        ["walk_blush/right"] = {0, 0},
        ["walk_blush/left"] = {0, 0},
        ["walk_blush/up"] = {0, 0},

        ["walk_sad/down"] = {0, 0},
        ["walk_sad/right"] = {0, 0},
        ["walk_sad/left"] = {0, 0},
        ["walk_sad/up"] = {0, 0},

        ["walk_look_up/down"] = {0, 0},
        ["walk_look_up/right"] = {0, 0},
        ["walk_look_up/left"] = {0, 0},
        ["walk_look_up/up"] = {0, 0},

        ["walk_scared/left"] = {-4, 3},
        ["walk_scared/right"] = {2, 3},

        ["walk_mad/left"] = {-2, 2},
        ["walk_mad/right"] = {5, 2},

        -- Battle offsets
        ["battle/idle"] = {-3, 0},

        ["battle/attack"] = {-8, 0},
        ["battle/attackready"] = {0, 0},
        ["battle/act"] = {0, 0},
        ["battle/actend"] = {0, 0},
        ["battle/actready"] = {0, 0},
        ["battle/spell"] = {-3, 0},
        ["battle/spellready"] = {0, 0},
        ["battle/item"] = {-2, 0},
        ["battle/itemready"] = {-2, 0},
        ["battle/defend"] = {-9, 0},

        ["battle/defeat"] = {0, 0},
        ["battle/hurt"] = {-9, 0},

        ["battle/intro"] = {-11, -7},
        ["battle/victory"] = {0, 0},

        -- Cutscene offsets
        ["blush"] = {0, 0},
        ["blush_side"] = {0, 0},

        ["hand_mouth"] = {0, 0},
        ["hand_mouth_side"] = {0, 0},

        ["laugh"] = {0, 0},

        ["point_up"] = {-4, 1},

        ["shocked"] = {0, 0},
        ["shocked_behind"] = {0, 0},

        ["headtilt"] = {0, -1},

        ["collapsed"] = {-14, 29},
        ["collapsed_look_up"] = {-18, 23},
        ["collapsed_reach"] = {-14, 29},

        ["hurt"] = {0, 0},
        ["kneel"] = {0, 0},
        ["kneel_shocked_left"] = {0, 0},
        ["kneel_shocked_right"] = {0, 0},
        ["kneel_smile_left"] = {0, 0},
        ["kneel_smile_right"] = {0, 0},

        ["smile_left"] = {0, 0},
        ["smile_right"] = {0, 0},

        ["head_lowered"] = {0, 0},
        ["head_lowered_look_left"] = {0, 0},
        ["head_lowered_look_right"] = {0, 0},
    }
end

return actor