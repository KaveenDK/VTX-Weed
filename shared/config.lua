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
    Harvest = "https://discord.com/api/webhooks/1486391676208414771/MFQWfNggSg68T2fHMTwG90y6EuKu6wOy5vYpSIsqJeosTDmx9BZPwT4Y5w4s53RkGqW7", 
    Process = "https://discord.com/api/webhooks/1486391251497517107/k0IQIHtZN1RrwE89iV6nFbqQm_JhTIAGjXv6YD3nMb7K0F-BFH7ogKrbnRebNLrcmXJH", 
    Exploit = "https://discord.com/api/webhooks/1486390983317782561/-3qhkuDgw2abO-nntfV72FGuYIl10aEJhLEy9vP_XXuLLnVt3eeJoy2y70gTdPntTAO3"  
}

-- ==========================================
-- Blip Settings
-- ==========================================
Config.Blips = {
    WeedFarm = {
        Enable = false,
        Name = "Weed Farm",
        Sprite = 140, 
        Color = 52, 
        Scale = 0.8,
        Coords = vec3(1057.94, -3196.79, -39.14) -- Center of the farm
    },
    ProcessingBench = {
        Enable = false,
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
        [1] = vec3(3793.9810, 4445.9268, 4.6123),
        [2] = vec3(3786.3882, 4445.3931, 4.6317),
        [3] = vec3(3787.0808, 4450.5303, 5.1360),
        [4] = vec3(3790.7104, 4442.4536, 4.3903),
        [5] = vec3(3791.3870, 4450.1860, 4.9621),
        [6] = vec3(3794.3123, 4472.3232, 5.4399),
        [7] = vec3(3786.3511, 4473.6660, 5.9279),
        [8] = vec3(3792.8523, 4479.1484, 5.4741),
        [9] = vec3(3785.2109, 4481.2510, 6.0741),
        [10] = vec3(3785.6326, 4488.7031, 6.3624),
        [11] = vec3(3789.5667, 4487.5044, 5.9679),
        [12] = vec3(3791.8350, 4491.6821, 6.0484),
        [13] = vec3(3789.2427, 4494.8359, 6.4294),
        [14] = vec3(3791.7542, 4498.5210, 6.9169),
        [15] = vec3(3797.6636, 4497.5835, 6.5902),
        [16] = vec3(3805.3083, 4496.3740, 5.4638),
        [17] = vec3(3809.3357, 4500.0664, 5.2028),
        [18] = vec3(3801.4905, 4501.0737, 6.4036),
        [19] = vec3(3807.3118, 4505.4175, 5.5660),
        [20] = vec3(3815.5635, 4503.4541, 4.5720),





        -- Add as many locations as you want here
    }
}

-- ==========================================
-- Processing Bench Settings
-- ==========================================
Config.Bench = {
    Model = `bkr_prop_weed_table_01a`, -- Default FiveM weed processing table
    Coords = vec4(3801.3018, 4441.8804, 4.2115, 185.6901), -- x, y, z, heading
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