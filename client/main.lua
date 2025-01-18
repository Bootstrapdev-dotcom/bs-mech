local QBCore = exports['qb-core']:GetCoreObject()

-- Function to request and load a ped model
local function RequestModelSync(model)
    if not IsModelInCdimage(model) or not IsModelValid(model) then
        print("[ERROR] Model does not exist: " .. model)
        return
    end

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
end

-- Function to create a blip for the NPC
local function createNPCBlip(location, blipName)
    local blip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(blip, 402) -- Wrench icon
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 3) -- Light blue color
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(blipName)
    EndTextCommandSetBlipName(blip)
end

-- Function to setup qb-target interaction
local function setupThirdEye(ped)
    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                label = "Repair Vehicle ($" .. Config.RepairCost .. ")",
                icon = "fas fa-tools",
                action = function(entity)
                    local playerPed = PlayerPedId()
                    local vehicle = GetVehiclePedIsIn(playerPed, false)
                    if vehicle ~= 0 then
                        -- Remove player from vehicle and send it to the repair location
                        TaskLeaveVehicle(playerPed, vehicle, 0)
                        Wait(1000) -- Ensure the player exits the vehicle
                        FreezeEntityPosition(vehicle, true)
                        SetEntityCoords(vehicle, Config.RepairLocation.x, Config.RepairLocation.y, Config.RepairLocation.z, false, false, false, true)
                        QBCore.Functions.Notify('Your vehicle is being repaired...', 'success', 5000)

                        -- Simulate repair duration
                        Wait(5000)

                        -- Repair the vehicle
                        SetVehicleFixed(vehicle)
                        SetVehicleDeformationFixed(vehicle)
                        SetVehicleDirtLevel(vehicle, 0)
                        SetVehicleEngineHealth(vehicle, 1000.0) -- Maximum engine health
                        SetVehicleBodyHealth(vehicle, 1000.0)   -- Maximum body health
                        SetVehiclePetrolTankHealth(vehicle, 1000.0) -- Max fuel tank health

                        -- Send the vehicle to the finish location
                        SetEntityCoords(vehicle, Config.FinishLocation.x, Config.FinishLocation.y, Config.FinishLocation.z, false, false, false, true)
                        FreezeEntityPosition(vehicle, false)

                        -- Notify the server to send an email
                        TriggerServerEvent('my_repair_npc:repairComplete', Config.RepairCost)
                    else
                        QBCore.Functions.Notify('You are not in a vehicle', 'error', 5000)
                    end
                end
            }
        },
        distance = 2.5,
    })
end


-- Event for receiving mail
RegisterNetEvent('qb-phone:client:CustomEmail', function(data)
    local mailSubject = data.subject
    local mailSender = data.sender
    local mailMessage = data.message

    -- Displaying the mail message using qb-phone mail system
    TriggerEvent('qb-phone:client:OpenMail', {
        sender = mailSender,
        subject = mailSubject,
        message = mailMessage
    })
end)

-- Example of opening the mail app from a menu or notification
RegisterCommand('openmail', function()
    TriggerEvent('qb-phone:client:OpenMailMenu')
end, false)

-- Example to show mail notification via HUD or custom display
RegisterNetEvent('qb-phone:client:ShowMailNotification', function(sender, subject, message)
    QBCore.Functions.Notify("New Mail from " .. sender .. ": " .. subject, "info", 5000)
end)

-- Function to spawn the NPC
local function spawnNPC()
    local npcData = Config.NPC
    local model = `a_m_m_farmer_01` -- Example ped model

    RequestModelSync(model)

    -- Create the NPC
    local ped = CreatePed(0, model, npcData.Location.x, npcData.Location.y, npcData.Location.z - 1.0, npcData.Location.w, false, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)

    -- Make the NPC play the clipboard animation
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)

    -- Add a blip and third-eye interaction
    createNPCBlip(npcData.Location, "Mechanic")
    setupThirdEye(ped)
end

-- Spawn NPC on resource start
CreateThread(function()
    spawnNPC()
end)

-- Cleanup NPC on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        local npcData = Config.NPC
        local ped = GetClosestPed(npcData.Location.x, npcData.Location.y, npcData.Location.z, 2.0, false, false, false, false, false, -1)
        if ped and DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
end)