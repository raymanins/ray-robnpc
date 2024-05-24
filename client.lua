local QBCore = exports['qb-core']:GetCoreObject()
local robbing = false
local progress = false
local robbedPeds = {}
local aimedAtPed = nil
local lastNotificationTime = 0

-- Function to check if the ped is blacklisted
function isPedBlacklisted(ped)
    local model = GetEntityModel(ped)
    for _, blacklistedPed in ipairs(Config.BlacklistPeds) do
        if model == blacklistedPed then
            return true
        end
    end
    return false
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsPlayerFreeAiming(PlayerId()) then
            local playerPed = PlayerPedId()
            local _, targetEntity = GetEntityPlayerIsFreeAimingAt(PlayerId())

            if DoesEntityExist(targetEntity) and IsEntityAPed(targetEntity) and not IsPedAPlayer(targetEntity) then
                local targetPed = targetEntity

                -- Check if the ped is blacklisted
                if isPedBlacklisted(targetPed) then
                    if aimedAtPed ~= targetPed then
                        local currentTime = GetGameTimer()
                        if currentTime - lastNotificationTime > Config.NotificationCooldown then
                            QBCore.Functions.Notify("This NPC cannot be robbed!", "error")
                            lastNotificationTime = currentTime
                        end
                        aimedAtPed = targetPed
                    end
                elseif not robbedPeds[targetPed] then
                    if IsPedArmed(playerPed, 4) then
                        if aimedAtPed ~= targetPed then
                            local currentTime = GetGameTimer()
                            if currentTime - lastNotificationTime > Config.NotificationCooldown then
                                if not progress then
                                    SetBlockingOfNonTemporaryEvents(targetPed, true)
                                    TaskHandsUp(targetPed, -1, playerPed, -1, true) -- Keep hands up indefinitely
                                    FreezeEntityPosition(targetPed, true) -- Freeze NPC position
                                    SetPedFleeAttributes(targetPed, 0, false) -- Prevent NPC from fleeing
                                    QBCore.Functions.Notify("Press E to rob the NPC", "primary")
                                    lastNotificationTime = currentTime
                                end
                                aimedAtPed = targetPed
                            end
                        end
                        if IsControlJustPressed(1, 51) and not progress then -- E key
                            local playerCoords = GetEntityCoords(playerPed)
                            local targetCoords = GetEntityCoords(targetPed)
                            local distance = #(playerCoords - targetCoords)

                            if distance <= Config.MaxDistance then
                                robbing = true
                                progress = true

                                local label = "Robbing NPC"
                                local duration = 5000

                                QBCore.Functions.Progressbar('robbing_npc', label, duration, false, true, {
                                    disableMovement = false,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = false,
                                }, {}, {}, {}, function() -- Success callback
                                    if robbing then
                                        local playerCoords = GetEntityCoords(playerPed)
                                        local targetCoords = GetEntityCoords(targetPed)
                                        local distance = #(playerCoords - targetCoords)

                                        if distance <= Config.MaxDistance then
                                            progress = false
                                            robbing = false
                                            robbedPeds[targetPed] = true
                                            TriggerServerEvent('qb-npcrob:server:rewardPlayer')
                                            FreezeEntityPosition(targetPed, false) -- Unfreeze NPC position after robbery
                                            Citizen.Wait(Config.RobberyCooldown) -- Wait before allowing notification
                                            TaskSmartFleePed(targetPed, playerPed, 100.0, -1, true, true) -- Make NPC flee after robbery
                                        else
                                            QBCore.Functions.Notify('You are too far from the NPC!', 'error')
                                            progress = false
                                            robbing = false
                                            TaskSmartFleePed(targetPed, playerPed, 100.0, -1, true, true)
                                        end
                                    end
                                end, function() -- Cancel callback
                                    progress = false
                                    robbing = false
                                    TaskSmartFleePed(targetPed, playerPed, 100.0, -1, true, true)
                                    QBCore.Functions.Notify('Robbery cancelled!', 'error')
                                end)

                                -- Distance check during progress
                                Citizen.CreateThread(function()
                                    while progress do
                                        Citizen.Wait(500) -- Check distance every 500ms
                                        playerCoords = GetEntityCoords(playerPed)
                                        targetCoords = GetEntityCoords(targetPed)
                                        distance = #(playerCoords - targetCoords)
                                        if distance > Config.MaxDistance then
                                            QBCore.Functions.Notify('You are too far from the NPC!', 'error')
                                            progress = false
                                            robbing = false
                                            TaskSmartFleePed(targetPed, playerPed, 100.0, -1, true, true)
                                            break
                                        end
                                    end
                                end)

                            else
                                QBCore.Functions.Notify('You are too far from the NPC!', 'error')
                            end
                        elseif IsControlJustPressed(1, 51) and progress then
                            QBCore.Functions.Notify("You are already robbing an NPC!", "error")
                        end
                    end
                else
                    if aimedAtPed ~= targetPed then
                        local currentTime = GetGameTimer()
                        if currentTime - lastNotificationTime > Config.NotificationCooldown then
                            if not progress and (currentTime - lastNotificationTime > Config.RobberyCooldown) then
                                QBCore.Functions.Notify("This NPC has already been robbed!", "error")
                                lastNotificationTime = currentTime
                            end
                            aimedAtPed = targetPed
                        end
                    end
                end
            else
                aimedAtPed = nil
            end
        else
            aimedAtPed = nil
        end
    end
end)

RegisterNetEvent('qb-npcrob:client:rewardPlayer')
AddEventHandler('qb-npcrob:client:rewardPlayer', function()
    local chance = math.random(1, 5) -- 20% chance of getting nothing
    if chance == 1 then
        QBCore.Functions.Notify('You received nothing...', 'error')
    else
        QBCore.Functions.Notify('You received your reward.', 'success')
    end
end)
