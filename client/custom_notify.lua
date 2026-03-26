-- ==========================================
-- Custom Notification System (Client-Side)
-- ==========================================

-- Core notification function
local function SendCustomNotify(title, message, notifyType)
    -- Default to 'info' if no type is provided
    local nType = notifyType or 'info'
    
    -- Send data to the NUI (frontend)
    SendNUIMessage({
        action = 'showNotification',
        data = {
            title = title,
            message = message,
            type = nType,
            duration = Config.Notify.DefaultDuration,
            themeColor = Config.ThemeColor
        }
    })
end

-- Export the function for use in other client scripts
exports('SendCustomNotify', SendCustomNotify)

-- Register as a NetEvent in case the Server-side needs to trigger it directly
RegisterNetEvent('vtx_weed:client:notify', function(title, message, notifyType)
    SendCustomNotify(title, message, notifyType)
end)