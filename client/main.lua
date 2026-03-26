local ox_target = exports.ox_target

-- ==========================================
-- Map Blips Setup
-- ==========================================
CreateThread(function()
    for _, v in pairs(Config.Blips) do
        if v.Enable then
            local blip = AddBlipForCoord(v.Coords.x, v.Coords.y, v.Coords.z)
            SetBlipSprite(blip, v.Sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, v.Scale)
            SetBlipColour(blip, v.Color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.Name)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

-- ==========================================
-- Weed Plants Logic (Zero-Lag via lib.points)
-- ==========================================
local spawnedPlants = {}

local function harvestPlant(plantId)
    if lib.progressBar({
        duration = Config.Plants.HarvestTime,
        label = Config.Plants.TargetLabel,
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true },
        anim = { dict = Config.Plants.Anim.dict, clip = Config.Plants.Anim.clip },
    }) then
        local success, msg = lib.callback.await('vtx_weed:server:harvestPlant', false, plantId)
        if success then
            exports['vtx_weed']:SendCustomNotify('Harvested', msg, 'success')
        else
            exports['vtx_weed']:SendCustomNotify('Failed', msg, 'error')
        end
    else
        exports['vtx_weed']:SendCustomNotify('Cancelled', 'Harvesting cancelled.', 'error')
    end
end

local function spawnPlantProp(plantId, coords)
    if spawnedPlants[plantId] then return end

    lib.requestModel(Config.Plants.Model)
    local obj = CreateObject(Config.Plants.Model, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(obj, math.random(0, 360) + 0.0)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    
    spawnedPlants[plantId] = obj

    ox_target:addLocalEntity(obj, {
        {
            name = 'harvest_weed_' .. plantId,
            icon = Config.Plants.TargetIcon,
            label = Config.Plants.TargetLabel,
            distance = 2.0,
            onSelect = function()
                harvestPlant(plantId)
            end
        }
    })
    SetModelAsNoLongerNeeded(Config.Plants.Model)
end

local function removePlantProp(plantId)
    if spawnedPlants[plantId] then
        ox_target:removeLocalEntity(spawnedPlants[plantId], 'harvest_weed_' .. plantId)
        DeleteEntity(spawnedPlants[plantId])
        spawnedPlants[plantId] = nil
    end
end

-- Create points for each plant location
for id, coords in ipairs(Config.Plants.Locations) do
    local point = lib.points.new({
        coords = coords,
        distance = 50.0,
        plantId = id
    })

    function point:onEnter()
        local states = GlobalState.vtx_weed_plants
        if states and states[self.plantId] then
            spawnPlantProp(self.plantId, self.coords)
        end
    end

    function point:onExit()
        removePlantProp(self.plantId)
    end
end

-- Sync props instantly if state changes while player is inside the point radius
AddStateBagChangeHandler('vtx_weed_plants', 'global', function(bagName, key, value, _reserved, replicated)
    if not value then return end
    for id, coords in ipairs(Config.Plants.Locations) do
        local dist = #(GetEntityCoords(cache.ped) - coords)
        if dist <= 50.0 then
            if value[id] then
                spawnPlantProp(id, coords)
            else
                removePlantProp(id)
            end
        end
    end
end)

-- ==========================================
-- Processing Bench Logic
-- ==========================================
local benchObj = nil
local benchPoint = lib.points.new({
    coords = vec3(Config.Bench.Coords.x, Config.Bench.Coords.y, Config.Bench.Coords.z),
    distance = 50.0
})

local function openBenchUI()
    local state, err = lib.callback.await('vtx_weed:server:getBenchState', false)
    if state then
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "openMenu",
            data = state,
            config = {
                recipe = Config.Bench.Recipe,
                limits = { max = Config.Bench.MaxProcessesPerHour },
                theme = Config.ThemeColor
            }
        })
    else
        exports['vtx_weed']:SendCustomNotify('Access Denied', err or 'Cannot access bench.', 'error')
    end
end

function benchPoint:onEnter()
    lib.requestModel(Config.Bench.Model)
    benchObj = CreateObject(Config.Bench.Model, self.coords.x, self.coords.y, self.coords.z, false, false, false)
    SetEntityHeading(benchObj, Config.Bench.Coords.w)
    PlaceObjectOnGroundProperly(benchObj)
    FreezeEntityPosition(benchObj, true)
    
    ox_target:addLocalEntity(benchObj, {
        {
            name = 'use_weed_bench',
            icon = Config.Bench.TargetIcon,
            label = Config.Bench.TargetLabel,
            distance = 2.0,
            onSelect = function()
                openBenchUI()
            end
        }
    })
    SetModelAsNoLongerNeeded(Config.Bench.Model)
end

function benchPoint:onExit()
    if benchObj then
        ox_target:removeLocalEntity(benchObj, 'use_weed_bench')
        DeleteEntity(benchObj)
        benchObj = nil
    end
end

-- ==========================================
-- NUI Callbacks
-- ==========================================
RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('vtx_weed:server:closeBench')
    cb('ok')
end)

RegisterNUICallback('startProcessing', function(data, cb)
    local success, response = lib.callback.await('vtx_weed:server:startProcessing', false)
    if success then
        exports['vtx_weed']:SendCustomNotify('Success', 'Weed processing started.', 'success')
        cb({ success = true, state = response })
    else
        exports['vtx_weed']:SendCustomNotify('Error', response, 'error')
        cb({ success = false })
    end
end)

RegisterNUICallback('collectOutput', function(data, cb)
    local success, response = lib.callback.await('vtx_weed:server:collectOutput', false)
    if success then
        exports['vtx_weed']:SendCustomNotify('Collected', 'You received the processed weed.', 'success')
        cb({ success = true, state = response })
    else
        exports['vtx_weed']:SendCustomNotify('Error', response, 'error')
        cb({ success = false })
    end
end)