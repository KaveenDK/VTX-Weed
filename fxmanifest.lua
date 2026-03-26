fx_version 'cerulean'
game 'gta5'

author 'KaveeNDK'
description 'Advanced Zero-Lag Weed Processing for Qbox'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

client_scripts {
    'client/main.lua',
    'client/custom_notify.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/discord.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/script.js',
    'html/images/*.png'
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_target',
    'ox_inventory'
}