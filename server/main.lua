local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('my_repair_npc:repairComplete', function(cost)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.RemoveMoney('bank', cost) then
        -- Send a success email to the player
        TriggerClientEvent('qb-phone:client:CustomEmail', src, {
            sender = "Mechanic",
            subject = "Vehicle Repair Receipt",
            message = string.format("Your vehicle has been repaired.<br>Total: $%d<br>Thank you for your business!", cost),
            button = {} -- No button needed for this email
        })
        Player.Functions.Notify("Your vehicle has been repaired for $" .. cost, "success", 5000)
    else
        Player.Functions.Notify("You don't have enough money in the bank", "error", 5000)
    end
end)