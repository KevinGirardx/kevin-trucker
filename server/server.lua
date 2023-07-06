lib.callback.register('kevin-trucker:getreputation', function(source, cb)
    local PlayerId = source
    local Player = QBCore.Functions.GetPlayer(PlayerId)
    local playerReputation = Player.PlayerData.metadata['trucking']
    if Config.JobNeeded then
        if Player.PlayerData.job.name == Config.JobName then
            return playerReputation
        else
            TriggerClientEvent('QBCore:Notify', PlayerId, 'You don\'t work here', 'error', 3000)
        end
    else
        return playerReputation
    end
end)

RegisterNetEvent('kevin-trucker:collectpayment', function (bool, payment, reputation, increase, increaseAmt)
    local PlayerId = source
    local Player =  QBCore.Functions.GetPlayer(PlayerId)
    if not Player and not bool then return end

    local playerReputation = Player.PlayerData.metadata.trucking
    local rep = playerReputation + reputation
	Player.Functions.SetMetaData('trucking', rep)

    local payment = payment
    if increase then
        payment = payment + increaseAmt
    end
    Player.Functions.AddMoney('cash', payment, 'Trucking Payment')
end)