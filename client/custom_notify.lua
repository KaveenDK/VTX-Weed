-- ==========================================
-- Default Server Notification System Bridge
-- ==========================================

local function SendCustomNotify(title, message, notifyType)
    local nType = notifyType or 'info'
    
    -- Using ox_lib's default notify. 
    -- Any global UI pack installed on the server will automatically intercept this!
    lib.notify({
        title = title,
        description = message,
        type = nType,
        duration = Config.Notify.DefaultDuration or 5000
    })
end

exports('SendCustomNotify', SendCustomNotify)

RegisterNetEvent('vtx_weed:client:notify', function(title, message, notifyType)
    SendCustomNotify(title, message, notifyType)
end)