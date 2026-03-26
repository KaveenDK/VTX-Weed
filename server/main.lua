local ox_inventory = exports.ox_inventory

-- ==========================================
-- State Management
-- ==========================================

-- Plant States: Track growth stages (0 = Growing, 1 = Stage 1, 2 = Stage 2, 3 = Ready)
local PlantStates = {}
for i = 1, #Config.Plants.Locations do
    PlantStates[i] = 3 -- Initially, all plants are fully grown (Stage 3)
end
-- Share the plant states globally so clients know which prop to spawn
GlobalState.vtx_weed_plants = PlantStates

-- Bench State: Prevent multiple access and track limits
local BenchState = {
    inUseBy = nil,       -- Player ID currently using the UI
    status = 'idle',     -- 'idle', 'processing', 'ready'
    finishTime = 0,      -- os.time() when processing finishes
    hourlyCount = 0,     -- How many times processed in current window
    windowReset = os.time() + Config.Bench.CooldownWindow -- When the 1-hour limit resets
}

-- ==========================================
-- Helper Functions
-- ==========================================

-- Function to check and reset the hourly bench limit
local function checkHourlyLimit()
    if os.time() > BenchState.windowReset then
        BenchState.hourlyCount = 0
        BenchState.windowReset = os.time() + Config.Bench.CooldownWindow
    end
end

-- Function to handle plant growth stages over time
local function growPlant(plantId, currentStage)
    SetTimeout(Config.Plants.TimePerStage * 1000, function()
        local nextStage = currentStage + 1
        PlantStates[plantId] = nextStage
        GlobalState.vtx_weed_plants = PlantStates -- Sync new stage with clients
        
        -- If not fully grown yet, trigger the next growth cycle
        if nextStage < 3 then
            growPlant(plantId, nextStage)
        end
    end)
end

-- ==========================================
-- Plant Harvesting Logic
-- ==========================================

lib.callback.register('vtx_weed:server:harvestPlant', function(source, plantId)
    local src = source

    -- Validate plant ID and ensure it is at Stage 3 (Fully Grown)
    if not plantId or PlantStates[plantId] ~= 3 then
        return false, "Plant is not fully grown yet."
    end

    -- Set plant to harvested (Stage 0)
    PlantStates[plantId] = 0
    GlobalState.vtx_weed_plants = PlantStates -- Sync with all clients

    -- Give random amount of weed leaves
    local amount = math.random(Config.Plants.HarvestAmount.min, Config.Plants.HarvestAmount.max)
    ox_inventory:AddItem(src, Config.Plants.HarvestItem, amount)

    -- Trigger Discord Log
    TriggerEvent('vtx_weed:server:discordLog', 'harvest', src, { plantId = plantId, amount = amount })

    -- Start server-side growth cycle
    growPlant(plantId, 0)

    return true, "Successfully harvested."
end)

-- ==========================================
-- Crushing Logic
-- ==========================================

lib.callback.register('vtx_weed:server:crushWeed', function(source)
    local src = source
    local recipe = Config.Crushing.Recipe

    -- Check if player has enough leaves
    local hasItems = ox_inventory:Search(src, 'count', recipe.InputItem)
    if hasItems < recipe.InputAmount then
        return false, "Not enough " .. recipe.InputItem .. " to crush."
    end

    -- Remove leaves and give crushed weed
    ox_inventory:RemoveItem(src, recipe.InputItem, recipe.InputAmount)
    ox_inventory:AddItem(src, recipe.OutputItem, recipe.OutputAmount)

    -- Trigger Discord Log
    TriggerEvent('vtx_weed:server:discordLog', 'crush', src, {})

    return true, "Successfully crushed the weed leaves."
end)

-- ==========================================
-- Bench Processing Logic
-- ==========================================

-- 1. Request to open Bench
lib.callback.register('vtx_weed:server:getBenchState', function(source)
    local src = source
    checkHourlyLimit() -- Refresh window limit before sending state

    -- If someone else is using it, deny access
    if BenchState.inUseBy ~= nil and BenchState.inUseBy ~= src then
        return false, "Someone else is using the bench."
    end

    -- Lock the bench to this player
    BenchState.inUseBy = src

    -- If status is processing but time has passed, update to ready
    if BenchState.status == 'processing' and os.time() >= BenchState.finishTime then
        BenchState.status = 'ready'
    end

    return BenchState
end)

-- 2. Unlock bench when UI is closed
RegisterNetEvent('vtx_weed:server:closeBench', function()
    local src = source
    if BenchState.inUseBy == src then
        BenchState.inUseBy = nil
    end
end)

-- If player crashes/disconnects while using bench, unlock it
AddEventHandler('playerDropped', function()
    local src = source
    if BenchState.inUseBy == src then
        BenchState.inUseBy = nil
    end
end)

-- 3. Start Processing
lib.callback.register('vtx_weed:server:startProcessing', function(source)
    local src = source
    
    -- Security Check: Ensure only the locked player can start
    if BenchState.inUseBy ~= src then return false, "Unauthorized" end
    
    checkHourlyLimit()

    -- Check if max limits reached
    if BenchState.hourlyCount >= Config.Bench.MaxProcessesPerHour then
        return false, "Bench has reached its maximum hourly capacity."
    end

    -- Check Inventory for ALL required items (ox_inventory)
    for _, req in pairs(Config.Bench.Recipe.InputItems) do
        local hasItem = ox_inventory:Search(src, 'count', req.item)
        if hasItem < req.amount then
            return false, "Not enough " .. req.item .. "."
        end
    end

    -- Remove ALL required items
    for _, req in pairs(Config.Bench.Recipe.InputItems) do
        ox_inventory:RemoveItem(src, req.item, req.amount)
    end
    
    BenchState.status = 'processing'
    BenchState.finishTime = os.time() + Config.Bench.Recipe.ProcessTime
    BenchState.hourlyCount = BenchState.hourlyCount + 1

    -- Trigger Discord Log
    TriggerEvent('vtx_weed:server:discordLog', 'process_start', src, {})

    -- Automatically set to ready when time is up (Server-side safety)
    SetTimeout(Config.Bench.Recipe.ProcessTime * 1000, function()
        if BenchState.status == 'processing' then
            BenchState.status = 'ready'
        end
    end)

    return true, BenchState
end)

-- 4. Collect Processed Output
lib.callback.register('vtx_weed:server:collectOutput', function(source)
    local src = source

    if BenchState.inUseBy ~= src then return false, "Unauthorized" end
    
    if BenchState.status ~= 'ready' then
        return false, "Processing is not finished yet."
    end

    -- Give output item
    ox_inventory:AddItem(src, Config.Bench.Recipe.OutputItem, Config.Bench.Recipe.OutputAmount)

    -- Reset Bench State
    BenchState.status = 'idle'
    BenchState.finishTime = 0

    -- Trigger Discord Log
    TriggerEvent('vtx_weed:server:discordLog', 'process_collect', src, {})

    return true, BenchState
end)