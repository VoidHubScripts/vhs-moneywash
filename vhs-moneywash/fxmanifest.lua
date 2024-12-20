fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'vhs-moneywash'
version 'v0.1'

client_scripts {
    'config.lua',
    'src/c_main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'src/s_webhook.lua',
    'src/s_main.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'utils.lua', 
    'config.lua',
}