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
    Harvest = "https://discord.com/api/webhooks/1486391676208414771/MFQWfNggSg68T2fHMTwG90y6EuKu6wOy5vYpSIsqJeosTDmx9BZPwT4Y5w4s53RkGqW7",
    Crush   = "https://discord.com/api/webhooks/1486658726894112820/cmN7D9_vISJ8TkXa4_zGd3Bslo2TTa__bIeY5QxVtJMZiHiUoqief9Pt6gvz-PfyKCcR",
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
        Coords = vec3(1057.94, -3196.79, -39.14)
    },
    CrushingTable = {
        Enable = false,
        Name = "Weed Crushing",
        Sprite = 469, 
        Color = 5,
        Scale = 0.8,
        Coords = vec3(3805.3, 4441.8, 4.2)
    },
    ProcessingBench = {
        Enable = false,
        Name = "Weed Processing",
        Sprite = 469, 
        Color = 2, 
        Scale = 0.8,
        Coords = vec3(1045.0, -3194.5, -39.0)
    }
}

-- ==========================================
-- Weed Plants Settings (Dynamic Growth)
-- ==========================================
Config.Plants = {
    TargetIcon = "fas fa-leaf",
    TargetLabel = "Harvest Weed",
    
    -- Items & Timers
    HarvestItem = "weed_leaf", 
    HarvestAmount = { min = 1, max = 3 }, 
    HarvestTime = 5000, -- 5 seconds to harvest
    TimePerStage = 10 * 60, -- 10 minutes per stage (3 stages = 30 minutes total)

    -- Growth Stages Props
    Stages = {
        [1] = `urbanweeds02_l1`, -- Stage 1: Small/Seedling
        [2] = `prop_weed_02`,    -- Stage 2: Medium
        [3] = `prop_weed_01`     -- Stage 3: Fully Grown (Ready to harvest)
    },

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
    }
}

-- ==========================================
-- Crushing Table Settings
-- ==========================================
Config.Crushing = {
    Model = `bkr_prop_coke_table01a`, -- Using a different table to distinguish from packaging
    Coords = vec4(3805.3018, 4441.8804, 4.2115, 185.6901),
    TargetIcon = "fas fa-mortar-pestle",
    TargetLabel = "Crush Weed Leaves",
    
    CrushTime = 60000, -- 1 minute (60 seconds) to crush 1 batch
    Anim = {
        dict = "mini@repair", 
        clip = "fixing_a_ped"
    },

    Recipe = {
        InputItem = "weed_leaf",
        InputAmount = 10,
        OutputItem = "crushed_weed",
        OutputAmount = 10
    }
}

-- ==========================================
-- Processing Bench Settings
-- ==========================================
Config.Bench = {
    Model = `bkr_prop_weed_table_01a`, 
    Coords = vec4(3801.3018, 4441.8804, 4.2115, 185.6901),
    TargetIcon = "fas fa-box-open",
    TargetLabel = "Use Processing Bench",

    -- Available Recipes
    Recipes = {
        Package = {
            Label = "Weed Package",
            InputItems = {
                { item = "crushed_weed", amount = 50 },
                { item = "weed_baggy_empty", amount = 1 }
            },
            OutputItem = "weed_package", 
            OutputAmount = 1,            
            ProcessTime = 10 * 60 -- 10 minutes       
        },
        Joint = {
            Label = "Weed Joint",
            InputItems = {
                { item = "crushed_weed", amount = 5 },
                { item = "rolling_paper_blue", amount = 1 }
            },
            OutputItem = "joint", -- Assuming this is your joint item name, change if needed
            OutputAmount = 1,            
            ProcessTime = 10 * 60 -- 10 minutes      
        }
    }
}