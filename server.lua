local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-npcrob:server:rewardPlayer')
AddEventHandler('qb-npcrob:server:rewardPlayer', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local reward = GetRandomReward()

    if reward then
        local amount = math.random(reward.minAmount, reward.maxAmount)
        Player.Functions.AddItem(reward.item, amount)
        TriggerClientEvent('QBCore:Notify', src, 'You received ' .. amount .. ' ' .. reward.item, 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'You received nothing...', 'error')
    end
end)

function GetRandomReward()
    local totalWeight = 0
    for _, item in pairs(Config.Items) do
        totalWeight = totalWeight + item.chance
    end

    local randomNumber = math.random(0, totalWeight)
    local weightSum = 0

    for _, item in pairs(Config.Items) do
        weightSum = weightSum + item.chance
        if randomNumber <= weightSum then
            return item
        end
    end

    return nil
end
