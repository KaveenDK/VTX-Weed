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
-- Weed Plants Logic (Dynamic Stages & Zero-Lag)
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

local function removePlantProp(plantId)
    if spawnedPlants[plantId] then
        ox_target:removeLocalEntity(spawnedPlants[plantId], 'harvest_weed_' .. plantId)
        DeleteEntity(spawnedPlants[plantId])
        spawnedPlants[plantId] = nil
    end
end

local function spawnPlantProp(plantId, coords, stage)
    -- If stage is 0 (harvested/growing), just remove the prop and return
    if not stage or stage == 0 then
        removePlantProp(plantId)
        return
    end

    local model = Config.Plants.Stages[stage]
    if not model then return end

    -- Remove existing prop if it's transitioning to a new stage
    removePlantProp(plantId)

    lib.requestModel(model)
    local obj = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(obj, math.random(0, 360) + 0.0)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    
    spawnedPlants[plantId] = obj

    -- Only allow harvesting if the plant is fully grown (Stage 3)
    if stage == 3 then
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
    end
    SetModelAsNoLongerNeeded(model)
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
            spawnPlantProp(self.plantId, self.coords, states[self.plantId])
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
            local currentStage = value[id]
            spawnPlantProp(id, coords, currentStage)
        end
    end
end)

-- ==========================================
-- Crushing Table Logic
-- ==========================================
local crushingObj = nil
local crushingPoint = lib.points.new({
    coords = vec3(Config.Crushing.Coords.x, Config.Crushing.Coords.y, Config.Crushing.Coords.z),
    distance = 50.0
})

local function crushWeedLeaves()
    if lib.progressBar({
        duration = Config.Crushing.CrushTime,
        label = "Crushing Weed Leaves...",
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true },
        anim = { dict = Config.Crushing.Anim.dict, clip = Config.Crushing.Anim.clip },
    }) then
        local success, msg = lib.callback.await('vtx_weed:server:crushWeed', false)
        if success then
            exports['vtx_weed']:SendCustomNotify('Success', msg, 'success')
        else
            exports['vtx_weed']:SendCustomNotify('Error', msg, 'error')
        end
    else
        exports['vtx_weed']:SendCustomNotify('Cancelled', 'Crushing cancelled.', 'error')
    end
end

function crushingPoint:onEnter()
    lib.requestModel(Config.Crushing.Model)
    crushingObj = CreateObject(Config.Crushing.Model, self.coords.x, self.coords.y, self.coords.z, false, false, false)
    SetEntityHeading(crushingObj, Config.Crushing.Coords.w)
    PlaceObjectOnGroundProperly(crushingObj)
    FreezeEntityPosition(crushingObj, true)
    
    ox_target:addLocalEntity(crushingObj, {
        {
            name = 'use_weed_crusher',
            icon = Config.Crushing.TargetIcon,
            label = Config.Crushing.TargetLabel,
            distance = 2.0,
            onSelect = function()
                crushWeedLeaves()
            end
        }
    })
    SetModelAsNoLongerNeeded(Config.Crushing.Model)
end

function crushingPoint:onExit()
    if crushingObj then
        ox_target:removeLocalEntity(crushingObj, 'use_weed_crusher')
        DeleteEntity(crushingObj)
        crushingObj = nil
    end
end

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
                recipes = Config.Bench.Recipes, -- Send the array of all available recipes
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
    -- data.recipeKey will contain either "Package" or "Joint" sent from JS
    local success, response = lib.callback.await('vtx_weed:server:startProcessing', false, data.recipeKey)
    if success then
        exports['vtx_weed']:SendCustomNotify('Success', 'Processing started.', 'success')
        cb({ success = true, state = response })
    else
        exports['vtx_weed']:SendCustomNotify('Error', response, 'error')
        cb({ success = false })
    end
end)

RegisterNUICallback('collectOutput', function(data, cb)
    local success, response = lib.callback.await('vtx_weed:server:collectOutput', false)
    if success then
        exports['vtx_weed']:SendCustomNotify('Collected', 'You received the processed goods.', 'success')
        cb({ success = true, state = response })
    else
        exports['vtx_weed']:SendCustomNotify('Error', response, 'error')
        cb({ success = false })
    end
end)

-- ==========================================
-- Usable Items Logic (Joint)
-- ==========================================

RegisterNetEvent('vtx_weed:client:useJoint', function()
    -- Start ox_lib progress bar with smoking animation and prop
    if lib.progressBar({
        duration = 10000, -- 10 Seconds to smoke
        label = "Smoking a Joint...",
        useWhileDead = false,
        canCancel = true,
        disable = { car = false, move = false, combat = true },
        anim = {
            dict = "amb@world_human_smoking_weed@male@base",
            clip = "base"
        },
        prop = {
            model = `p_cs_joint_02`,
            bone = 28422,
            pos = vec3(0.015, 0.009, 0.003),
            rot = vec3(55.0, 0.0, 110.0)
        },
    }) then
        -- If successfully finished smoking:
        
        -- 1. Relieve Stress (Qbox/QBCore default event for stress)
        local stressRelief = math.random(20, 30) -- Reduces 20 to 30 stress
        TriggerServerEvent('hud:server:RelieveStress', stressRelief)
        
        -- 2. Play a cool screen effect for 15 seconds
        AnimpostfxPlay("WeedAlienNotches", 15000, false)
        
        exports['vtx_weed']:SendCustomNotify('Relaxed', 'You feel the stress fading away...', 'success')
    else
        -- If cancelled (player moved or pressed ESC):
        TriggerServerEvent('vtx_weed:server:returnJoint')
        exports['vtx_weed']:SendCustomNotify('Cancelled', 'You put the joint away.', 'error')
    end
end)