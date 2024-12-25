fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'vhs-moneywash'
version 'v0.1'

client_scripts {
    'src/c_main.lua',
}

server_scripts {
    'src/s_webhook.lua',
    'configs/s_config.lua',
    'src/s_main.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'configs/config.lua', 
    'configs/utils.lua' 
    
}

escrow_ignore {
    'src/s_webhook.lua', 
    'configs/config.lua',
    'configs/s_config.lua',
    'configs/utils.lua'

}