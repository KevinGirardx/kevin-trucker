local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('kevin-trucker:getreputation', function(source, cb)
    local playerId = source
    local player = QBCore.Functions.GetPlayer(playerId)
    local playerReputation = player.PlayerData.metadata['jobrep']['trucker']
    cb(playerReputation)
end)

RegisterNetEvent('kevin-trucker:collectpayment', function (bool, payment, reputation, increase, increaseAmt)
    local playerId = source
    local player =  QBCore.Functions.GetPlayer(playerId)
    if not player and not bool then return end

    local playerReputation = player.PlayerData.metadata['jobrep']['trucker']
    local rep = playerReputation + reputation
	player.Functions.SetMetaData('trucker', rep)

    local payment = payment
    if increase then
        payment = payment + increaseAmt
    end
    player.Functions.AddMoney('cash', payment, 'Trucking Payment')
end)