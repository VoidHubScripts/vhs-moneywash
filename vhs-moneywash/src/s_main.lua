function logDiscord(title, message, color)
    local data = { username = "vhs-moneywash",  avatar_url = "https://i.imgur.com/E2Z3mDO.png", embeds = { { ["color"] = color, ["title"] = title, ["description"] = message, ["footer"] = { ["text"] = "Installation Support - [ESX, QBCore, Qbox] -  https://discord.gg/CBSSMpmqrK" },} } } PerformHttpRequest(WebhookConfig.URL, function(err, text, headers) end, 'POST', json.encode(data), {['Content-Type'] = 'application/json'})
end

function getMoneys(source)
    local data = { cash = 0, illegal = 0 }
    if GetResourceState('es_extended') == 'started' then
        local player = ESX.GetPlayerFromId(source)
        if player then
            data.cash = player.getMoney()
            data.illegal = player.getAccount('black_money').money
        end
    elseif GetResourceState('qbx_core') == 'started' then    
         local player = exports.qbx_core:GetPlayer(source)
         data.cash = player.PlayerData.money.cash
         local item = exports.ox_inventory:GetItem(source, 'black_money')
        if item then
            data.illegal = item.count
        end
    elseif GetResourceState('qb-core') == 'started' then
        local player = QBCore.Functions.GetPlayer(source)
        if player then
            data.cash = player.PlayerData.money.cash

            local illegal = player.Functions.GetItemsByName('markedbills')
            for _, bill in ipairs(illegal) do
                data.illegal = data.illegal + bill.info.worth
            end
        end
    else
        print("unsupported framework")
    end
    return data
end

function addMoney(source, amount)
    if GetResourceState('es_extended') == 'started' then
        local player = ESX.GetPlayerFromId(source)
        if player then
            player.addMoney(amount)
        end
    elseif GetResourceState('qbx_core') == 'started' then
        local player = exports.qbx_core:GetPlayer(source)
        if player then 
            player.Functions.AddMoney('cash', amount)
        end 
       
    elseif GetResourceState('qb-core') == 'started' then
        local player = QBCore.Functions.GetPlayer(source)
        if player then
            player.Functions.AddMoney('cash', amount)
        else
        end
    else
        print("unsupported framework.")
    end
end

function removeMoneys(source, amount, reason)
    if GetResourceState('es_extended') == 'started' then
        local player = ESX.GetPlayerFromId(source)
        if player then
            player.removeAccountMoney('black_money', amount)
        end
    elseif GetResourceState('ox_inventory') == 'started' then    
        local success = exports.ox_inventory:RemoveItem(source, 'black_money', amount)
    elseif GetResourceState('qb-core') == 'started' then
        local player = QBCore.Functions.GetPlayer(source)
        if player then
            local markedBills = player.Functions.GetItemsByName('markedbills')
            local amountToRemove = amount
            for _, bill in ipairs(markedBills) do
                if amountToRemove <= 0 then
                    break
                end
                local billWorth = bill.info.worth
                if billWorth <= amountToRemove then
                    player.Functions.RemoveItem('markedbills', 1, bill.slot)
                    amountToRemove = amountToRemove - billWorth
                else
                    local newInfo = bill.info
                    newInfo.worth = billWorth - amountToRemove
                    player.Functions.AddItem('markedbills', 1, false, newInfo)
                    player.Functions.RemoveItem('markedbills', 1, bill.slot)
                    amountToRemove = 0
                end
            end
            if amountToRemove < amount then
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['markedbills'], 'remove')
            end
        end
    end
end

function getName(source)
    if GetResourceState('es_extended') == 'started' then 
        local player = ESX.GetPlayerFromId(source)
        return player.getName()
    elseif GetResourceState('qb-core') == 'started' or GetResourceState('qb-core') == 'started' then 
        local player = QBCore.Functions.GetPlayer(source)
        if player then
            return player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
        end
    end 
end

function getItem(source, item)
    if GetResourceState('es_extended') == 'started' then
        local Player = ESX.GetPlayerFromId(source)
        if Player then
            local esxItem = Player.getInventoryItem(item)
            if esxItem and esxItem.count > 0 then
                return { count = esxItem.count, label = esxItem.label }
            end
        end
    elseif GetResourceState('ox_inventory') == 'started' then
        local OxItem = exports.ox_inventory:GetItem(source, item)
        return { count = OxItem.count, label = OxItem.label }
    elseif GetResourceState('qb-inventory') == 'started' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            local qItem = exports['qb-inventory']:GetItemByName(source, item)
            if qItem and qItem.amount then
                return { count = qItem.amount, label = qItem.label }
            end
        end
    end
    return nil
end

lib.callback.register('vhs-moneywash:check', function(source, zone)
    local data = Locations[zone]
    local bills = getMoneys(source)
    if data.keys.useKeys then
        if getItem(source, data.keys.keyItem).count > 0 then
            if bills.illegal > 0 then
                return true 
            else
                Notify('info', 'No Bills', "You don't have any bills to clean!", source)
                return false 
            end
        else
            Notify('info', 'Missing Key', "You don't have the key for this!", source)
            return false 
        end
    else
        if bills.illegal > 0 then
            return true 
        else
            Notify('info', 'No Bills', "You don't have any bills to clean!", source)
            return false 
        end
    end
end)

lib.callback.register('vhs-moneywash:wash', function(source, zone)
    local data = Locations[zone]
    local bills = getMoneys(source)
    if bills.illegal > 0 then 
        local percent = data.percent / 100 
        local add = math.floor(bills.illegal * (1 - percent))
        removeMoneys(source, bills.illegal, 'moneywash') 
        addMoney(source, add)
        logDiscord('Money Cleaned', '**'..getName(source).. ' Cleaned x(' .. bills.illegal .. ") markedbills for  $" ..add.."**", 45280)
        Notify('info', 'Money Cleaned', 'Cleaned x(' .. bills.illegal .. ") markedbills for  $" ..add, source)
    else 
        Notify('info', 'No Bills', "You don't have any bills to clean!", source)
        return false 
    end 
end)