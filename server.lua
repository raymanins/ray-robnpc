local QBCore = exports['qb-core']:GetCoreObject()

local items = {
    {item = 'bread', minAmount = 1, maxAmount = 2},
    {item = 'water', minAmount = 1, maxAmount = 3},
    {item = 'phone', minAmount = 1, maxAmount = 1},
    {item = 'lockpick', minAmount = 1, maxAmount = 1},
    {item = 'money', minAmount = 100, maxAmount = 500}
}

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
    for _, item in pairs(items) do
        totalWeight = totalWeight + (item.maxAmount - item.minAmount + 1) -- Adding the range of possible amounts as weight
    end

    local randomNumber = math.random(0, totalWeight)
    local weightSum = 0

    for _, item in pairs(items) do
        weightSum = weightSum + (item.maxAmount - item.minAmount + 1)
        if randomNumber <= weightSum then
            return item
        end
    end

    return nil
end
