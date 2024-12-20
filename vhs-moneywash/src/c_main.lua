function getJob()
    if GetResourceState('es_extended') == 'started' then
        local playerData = ESX.GetPlayerData()
        if playerData then
            return playerData.job.name, playerData.job.grade, playerData.job.grade_label
        end
    elseif GetResourceState('qb-core') == 'started' or GetResourceState('qbx-core') == 'started' then
        local playerData = QBCore.Functions.GetPlayerData()
        if playerData then
            return playerData.job.name, playerData.job.grade.level, playerData.job.grade.name
        end
    else
        print("Unsupported framework")
        return 'unemployed', 'unemployed', 0
    end
    return 'unemployed', 'unemployed', 0
end

function targetModel(model, name, options, interact, job, gang, distance)
    local targetOptions = {}
    for _, opt in ipairs(options) do
        table.insert(targetOptions, { name = name, icon = opt.icon, label = opt.label, event = opt.event, items = opt.item, groups = job,
            canInteract = function(entity, dist, coords, name, bone)
                local result = type(interact) == "function" and interact(entity, dist, coords, name, bone)
                if opt.canInteract then
                    return result and opt.canInteract(entity, dist, coords, name, bone)
                end
                return result
            end,
            onSelect = function(data)
                if type(opt.action) == "function" then
                    opt.action(data)
                end
        end })
    end
    if GetResourceState('ox_target') == 'started' then
        exports.ox_target:addModel(model, targetOptions)
    elseif GetResourceState('qb-target') == 'started' then
        local qbOptions = { options = {}, distance = distance }
        for _, opt in ipairs(options) do
            table.insert(qbOptions.options, { event = opt.event, icon = opt.icon, label = opt.label, item = opt.item, job = job, gang = gang,
                action = function(entity)
                    if type(opt.action) == "function" then
                        opt.action(entity)
                    end
                end,
                canInteract = function(entity, dist, data)
                    local result = type(interact) == "function" and interact(entity, dist, data)
                    if opt.canInteract then
                        return result and opt.canInteract(entity, dist, data)
                    end
                    return result
                end
            })
        end
        exports['qb-target']:AddTargetModel(model, qbOptions)
    else
        print('Neither ox_target nor qb-target is started.')
    end
end

Citizen.CreateThread(function()
    Peds()
    setupTarget()
    setupBlips()
end)

local spawnedPeds = {}

function Peds()
    for k, v in pairs(Locations) do
        local ped = v.ped
        lib.requestModel(ped.model, 10000)
        local npc = CreatePed(4, ped.model, ped.loc[1], ped.loc[2], ped.loc[3], ped.loc[4], false, true)
        TaskStartScenarioInPlace(npc, ped.scenario, 0, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        SetEntityInvincible(npc, true)
        FreezeEntityPosition(npc, true)
        table.insert(spawnedPeds, npc)
    end
end

function setupBlips()
    for k, v in pairs(Locations) do
        local location = v.ped.loc
        local blipz = v.blip
        if blipz.useBlip then
            local blip = AddBlipForCoord(location.x, location.y, location.z)
            SetBlipSprite(blip, blipz.sprite)
            SetBlipDisplay(blip, 4) 
            SetBlipScale(blip, blipz.scale)
            SetBlipColour(blip, blipz.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(blipz.label)
            EndTextCommandSetBlipName(blip)
        end
    end
end

function setupTarget()
    for k, v in pairs(Locations) do
        local storeOptions = {
            { icon = Target.iccon, label = Target.label, event = nil,
                action = function()
                    Interact(k)
                end,
                canInteract = function()
                    return true
                end
            },
        }
        targetModel(v.ped.model, k, storeOptions, 
            function(entity)
                local pCoords = GetEntityCoords(PlayerPedId())
                local sCoords = vector3(v.ped.loc.x, v.ped.loc.y, v.ped.loc.z)
                local disNPC = Vdist2(pCoords, sCoords)
                local maxD = 3.0^2
                local dist = disNPC <= maxD
                return dist
            end, 
        nil, nil, 3.0)  
    end
end

function Interact(k)
    local data = Locations[k]
    local jName, jGrade = getJob()
    for _, blacklisted in ipairs(data.jobs) do
        if jName == blacklisted then
            Notify('info', 'Your job cannot do this!')
            return false 
        end
    end
   local check = lib.callback.await('vhs-moneywash:check', false, k)     
   if check then 
    lib.requestAnimDict('misscarsteal4@actor', 500)
    TaskPlayAnim(PlayerPedId(), 'misscarsteal4@actor', 'actor_berating_loop', 8.0, -8.0, -1, 50, 0, false, false, false)
    local bar = ProgressBar(data.progress.time, data.progress.label)
    if bar == 'complete' then 
        StopAnimTask(PlayerPedId(), 'misscarsteal4@actor', 'actor_berating_loop', 1.0)
        lib.callback.await('vhs-moneywash:wash', false, k)
        elseif bar == 'cancelled' then 
        StopAnimTask(PlayerPedId(), 'misscarsteal4@actor', 'actor_berating_loop', 1.0) 
        end 
    end 
end










