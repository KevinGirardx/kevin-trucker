local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('kevin-trucker:getreputation', function(source, cb)
    local playerId = source
    local player = QBCore.Functions.GetPlayer(playerId)
    local playerReputation = player.PlayerData.metadata['trucking']
    if Config.JobNeeded then
        if player.PlayerData.job.name == Config.JobName then
            cb(playerReputation)
        else
            TriggerClientEvent('QBCore:Notify', playerId, 'You don\'t work here', 'error', 3000)
        end
    else
        cb(playerReputation)
    end
end)

RegisterNetEvent('kevin-trucker:collectpayment', function (bool, payment, reputation, increase, increaseAmt)
    local playerId = source
    local player =  QBCore.Functions.GetPlayer(playerId)
    if not player and not bool then return end

    local playerReputation = player.PlayerData.metadata['trucking']
    local rep = playerReputation + reputation
	player.Functions.SetMetaData('trucking', rep)

    local payment = payment
    if increase then
        payment = payment + increaseAmt
    end
    player.Functions.AddMoney('cash', payment, 'Trucking Payment')
end)