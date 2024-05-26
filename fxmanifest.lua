fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Your Name'
description 'NPC Robbing Script for FiveM'
version '1.0.0'

-- Shared scripts
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

-- Client scripts
client_scripts {
    'client.lua'
}

-- Server scripts
server_scripts {
    'server.lua'
}

dependencies {
    'ox_lib',
    'ox_inventory'
}