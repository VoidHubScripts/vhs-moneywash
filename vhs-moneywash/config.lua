Config = Config or {}

Notifications = 'ox_lib'  -- qbcore, esx, ox_lib
Progress = 'ox_lib_circle' 

Target = { icon = '', label = 'Interact'}

Locations = {
    zone_1 = {
        blip = { useBlip = true, sprite = 108, scale = 0.8, color = 6, useRadius = true, label = 'Money Wash' },  -- Blip configs 
        ped = {loc = vec4(970.6849, -2405.5708, 30.4937, 265.4941), model = 'a_m_m_eastsa_01', scenario = 'WORLD_HUMAN_AA_SMOKE'},  -- Ped configs 
        keys = { useKeys = true, keyItem = 'blue_key'}, -- Use keys to restrict locations 
        progress = { time = 5000, label = 'Cleaning moneys' }, -- Progress bar configs  
        percent = 25,  -- 25 % Tax on cleaning 
        jobs = {'police', 'lspd'}  -- Blacklisted jobs 
    },
    zone_2 = {
        blip = { useBlip = false, sprite = 24, scale = 0.8, color = 3, useRadius = true, label = 'Money Wash' },
        ped = {loc = vec4(1533.7788, 6332.2549, 24.2403, 26.8210), model = 'a_m_m_eastsa_01', scenario = 'WORLD_HUMAN_AA_SMOKE'}, 
        keys = { useKeys = false, keyItem = 'blue_key'},
        progress = {time = 5000, label = 'Cleaning moneys'},
        percent = 30,  -- 25 % Tax on cleaning 
        jobs = {'police', 'lspd'}
    }



}