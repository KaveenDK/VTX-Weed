-- ==========================================
-- Advanced Discord Logging System
-- ==========================================

local LogoURL = "https://res.cloudinary.com/dkivbxrr1/image/upload/v1774208765/vclogo_ddmpms.png" 

-- Convert Hex color (from config) to Decimal for Discord Embeds
local function hexToDecimal(hex)
    hex = hex:gsub("#", "")
    return tonumber(hex, 16) or 1349604 -- Default to #1497e4 if conversion fails
end

-- Helper to extract identifiers
local function getIdentifier(src, idType)
    local num = GetNumPlayerIdentifiers(src)
    for i = 0, num - 1 do
        local id = GetPlayerIdentifier(src, i)
        if string.find(id, idType) then
            return id
        end
    end
    return "Not Found"
end

RegisterNetEvent('vtx_weed:server:discordLog', function(action, src, data)
    local WebhookURL = ""
    local Title = ""
    local Description = ""
    local Color = hexToDecimal(Config.ThemeColor)

    -- Fetch Player Data via Qbox
    local player = exports.qbx_core:GetPlayer(src)
    local charName = "Unknown"
    if player and player.PlayerData and player.PlayerData.charinfo then
        charName = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
    end

    -- Fetch Identifiers
    local rawDiscord = getIdentifier(src, "discord:")
    local discordId = string.gsub(rawDiscord, "discord:", "")
    local discordMention = discordId ~= "Not Found" and ("<@" .. discordId .. ">") or "Not Linked"
    local steamId = getIdentifier(src, "steam:")

    -- Determine Log Type
    if action == 'harvest' then
        WebhookURL = Config.Webhooks.Harvest
        Title = "🌿 Weed Harvested"
        Description = string.format("**Action:** Harvested a Weed Plant\n**Plant ID:** %s\n**Received:** %sx %s", data.plantId, data.amount, Config.Plants.HarvestItem)
        
    elseif action == 'crush' then
        WebhookURL = Config.Webhooks.Crush 
        Title = "🔨 Weed Crushed"
        Description = string.format("**Action:** Crushed Weed Leaves\n**Input Used:** %sx %s\n**Received:** %sx %s", Config.Crushing.Recipe.InputAmount, Config.Crushing.Recipe.InputItem, Config.Crushing.Recipe.OutputAmount, Config.Crushing.Recipe.OutputItem)
        
    elseif action == 'process_start' then
        WebhookURL = Config.Webhooks.Process
        Title = "⚙️ Weed Processing Started"
        
        -- Dynamically fetch the selected recipe (Package or Joint)
        local recipeKey = data.recipeKey
        local selectedRecipe = Config.Bench.Recipes[recipeKey]
        local inputStr = ""
        
        if selectedRecipe then
            for _, req in pairs(selectedRecipe.InputItems) do
                inputStr = inputStr .. string.format("%sx %s\n", req.amount, req.item)
            end
        end
        
        Description = string.format("**Action:** Started Processing Bench (%s)\n**Inputs Used:**\n%s", recipeKey or "Unknown", inputStr)
        
    elseif action == 'process_collect' then
        WebhookURL = Config.Webhooks.Process
        Title = "📦 Processed Goods Collected"
        
        -- Fetch the specific recipe output
        local recipeKey = data.recipeKey
        local selectedRecipe = Config.Bench.Recipes[recipeKey]
        
        if selectedRecipe then
            Description = string.format("**Action:** Collected Output from Bench\n**Received:** %sx %s", selectedRecipe.OutputAmount, selectedRecipe.OutputItem)
        else
            Description = "**Action:** Collected Output from Bench\n**Received:** Unknown Item"
        end
        
    elseif action == 'exploit' then
        WebhookURL = Config.Webhooks.Exploit
        Title = "⚠️ Possible Exploit Detected"
        Description = string.format("**Action:** Attempted unauthorized action\n**Details:** %s", data.reason or "Unknown")
        Color = 16711680 -- Red color for exploits
    end

    if WebhookURL == nil or WebhookURL == "" then return end

    -- Prepare Footer Data
    local currentDate = os.date("%Y-%m-%d %H:%M:%S")
    local footerText = string.format("Player: %s | Server ID: %s • %s", charName, tostring(src), currentDate)

    -- Build Payload
    local embedData = {
        {
            ["title"] = Title,
            ["color"] = Color,
            ["description"] = Description,
            ["fields"] = {
                { ["name"] = "Character Name", ["value"] = charName, ["inline"] = true },
                { ["name"] = "Server ID", ["value"] = tostring(src), ["inline"] = true },
                { ["name"] = "Discord", ["value"] = discordMention, ["inline"] = true },
                { ["name"] = "Steam ID", ["value"] = steamId, ["inline"] = false }
            },
            ["footer"] = {
                ["text"] = footerText,
                ["icon_url"] = LogoURL
            }
        }
    }

    -- Send Request to Discord
    PerformHttpRequest(WebhookURL, function(err, text, headers) end, 'POST', json.encode({username = "VC Weed Logs", embeds = embedData}), { ['Content-Type'] = 'application/json' })
end)