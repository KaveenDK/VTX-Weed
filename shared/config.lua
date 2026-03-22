Config = {}

-- ==========================================
-- General Settings
-- ==========================================
Config.Debug = false -- Set to true to enable developer prints and debug polyzones
Config.ThemeColor = "#1497e4" -- Server theme color used for UI elements and Discord logs

-- ==========================================
-- Discord Webhooks
-- ==========================================
Config.Webhooks = {
    -- Replace these with your actual Discord webhook URLs
    Harvest = "", 
    Process = "", 
    Exploit = ""  
}

-- ==========================================
-- Blip Settings
-- ==========================================
Config.Blips = {
    WeedFarm = {
        Enable = true,
        Name = "Weed Farm",
        Sprite = 140, 
        Color = 52, 
        Scale = 0.8,
        Coords = vec3(1057.94, -3196.79, -39.14) -- Center of the farm
    },
    ProcessingBench = {
        Enable = true,
        Name = "Weed Processing",
        Sprite = 469, 
        Color = 2, 
        Scale = 0.8,
        Coords = vec3(1045.0, -3194.5, -39.0) -- Location of the bench
    }
}

-- ==========================================
-- Weed Plants Settings (Harvesting)
-- ==========================================
Config.Plants = {
    Model = `prop_weed_01`, -- Default FiveM weed plant prop
    TargetIcon = "fas fa-leaf",
    TargetLabel = "Harvest Weed",
    
    -- Items & Timers
    HarvestItem = "weed_leaf", -- The item given to the player (must exist in ox_inventory)
    HarvestAmount = { min = 1, max = 3 }, -- Random amount given per plant
    HarvestTime = 5000, -- Time it takes to harvest the plant in milliseconds (5 seconds)
    RespawnTime = 30 * 60, -- 30 minutes in seconds (Time before the plant grows back)

    -- Animation for harvesting
    Anim = {
        dict = "creatures@rottweiler@tricks@",
        clip = "petting_franklin"
    },

    -- Plant Locations
    Locations = {
        [1] = vec3(1057.94, -3196.79, -39.14),
        [2] = vec3(1059.50, -3198.20, -39.14),
        [3] = vec3(1061.20, -3195.40, -39.14),
        -- Add as many locations as you want here
    }
}

-- ==========================================
-- Processing Bench Settings
-- ==========================================
Config.Bench = {
    Model = `bkr_prop_weed_table_01a`, -- Default FiveM weed processing table
    Coords = vec4(1045.0, -3194.5, -39.16, 90.0), -- x, y, z, heading
    TargetIcon = "fas fa-box-open",
    TargetLabel = "Use Processing Bench",

    -- Limits and Cooldowns
    MaxProcessesPerHour = 3, -- Maximum number of times a player can process within the window
    CooldownWindow = 60 * 60, -- 1 hour in seconds (Time until the player's process count resets)

    -- Recipe configuration
    Recipe = {
        InputItem = "weed_leaf",     -- Item required to start processing
        InputAmount = 50,            -- Amount of the input item required
        OutputItem = "weed_package", -- Item given after processing is complete
        OutputAmount = 1,            -- Amount of output item given
        ProcessTime = 10 * 60        -- 10 minutes in seconds (Time it takes to process one batch)
    }
}

-- ==========================================
-- UI / Notification Settings
-- ==========================================
Config.Notify = {
    SoundFile = "notify.mp3", -- Sound file located in html/sounds/
    DefaultDuration = 5000 -- How long the notification stays on screen in milliseconds
}