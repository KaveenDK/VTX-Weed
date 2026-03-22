local ox_inventory = exports.ox_inventory

-- ==========================================
-- State Management (Source of Truth)
-- ==========================================

-- Plant States: Keep track of which plants are grown
local PlantStates = {}
for i = 1, #Config.Plants.Locations do
    PlantStates[i] = true -- Initially, all plants are grown
end
-- Share the plant states globally so clients know when to spawn props
GlobalState.vc_weed_plants = PlantStates

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

-- ==========================================
-- Plant Harvesting Logic
-- ==========================================

lib.callback.register('vc_weed:server:harvestPlant', function(source, plantId)
    local src = source

    -- Validate plant ID and if it is actually grown
    if not plantId or not PlantStates[plantId] then
        return false, "Plant is not fully grown yet."
    end

    -- Set plant to harvested (false)
    PlantStates[plantId] = false
    GlobalState.vc_weed_plants = PlantStates -- Sync with all clients

    -- Give random amount of weed leaves
    local amount = math.random(Config.Plants.HarvestAmount.min, Config.Plants.HarvestAmount.max)
    ox_inventory:AddItem(src, Config.Plants.HarvestItem, amount)

    -- Trigger Discord Log
    TriggerEvent('vc_weed:server:discordLog', 'harvest', src, { plantId = plantId, amount = amount })

    -- Start server-side timer to respawn the plant
    SetTimeout(Config.Plants.RespawnTime * 1000, function()
        PlantStates[plantId] = true
        GlobalState.vc_weed_plants = PlantStates -- Sync that plant has grown back
    end)

    return true, "Successfully harvested."
end)

-- ==========================================
-- Bench Processing Logic
-- ==========================================

-- 1. Request to open Bench
lib.callback.register('vc_weed:server:getBenchState', function(source)
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
RegisterNetEvent('vc_weed:server:closeBench', function()
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
lib.callback.register('vc_weed:server:startProcessing', function(source)
    local src = source
    
    -- Security Check: Ensure only the locked player can start
    if BenchState.inUseBy ~= src then return false, "Unauthorized" end
    
    checkHourlyLimit()

    -- Check if max limits reached
    if BenchState.hourlyCount >= Config.Bench.MaxProcessesPerHour then
        return false, "Bench has reached its maximum hourly capacity."
    end

    -- Check Inventory (ox_inventory)
    local hasItems = ox_inventory:Search(src, 'count', Config.Bench.Recipe.InputItem)
    if hasItems < Config.Bench.Recipe.InputAmount then
        return false, "Not enough "..Config.Bench.Recipe.InputItem.."."
    end

    -- Remove items and update state
    ox_inventory:RemoveItem(src, Config.Bench.Recipe.InputItem, Config.Bench.Recipe.InputAmount)
    
    BenchState.status = 'processing'
    BenchState.finishTime = os.time() + Config.Bench.Recipe.ProcessTime
    BenchState.hourlyCount = BenchState.hourlyCount + 1

    -- Trigger Discord Log
    TriggerEvent('vc_weed:server:discordLog', 'process_start', src, {})

    -- Automatically set to ready when time is up (Server-side safety)
    SetTimeout(Config.Bench.Recipe.ProcessTime * 1000, function()
        if BenchState.status == 'processing' then
            BenchState.status = 'ready'
        end
    end)

    return true, BenchState
end)

-- 4. Collect Processed Output
lib.callback.register('vc_weed:server:collectOutput', function(source)
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
    TriggerEvent('vc_weed:server:discordLog', 'process_collect', src, {})

    return true, BenchState
end)