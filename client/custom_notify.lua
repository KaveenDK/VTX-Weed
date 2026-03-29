-- ==========================================
-- Default Server Notification System Bridge
-- ==========================================

local function SendCustomNotify(title, message, notifyType)
    local nType = notifyType or 'info'
    
    -- Using a hardcoded duration since the config was removed, but you can adjust this as needed
    lib.notify({
        title = title,
        description = message,
        type = nType,
        duration = 5000 -- Hardcoded duration since config was removed
    })
end

exports('SendCustomNotify', SendCustomNotify)

RegisterNetEvent('vtx_weed:client:notify', function(title, message, notifyType)
    SendCustomNotify(title, message, notifyType)
end)