local sphere = nil
local trailerPos, trailerHash, pedPos, pedHash
local jobVehicle = nil
local jobTrailer = nil
local locationBlip = nil
local locationPed = nil
local destBlip = nil
local trailerBlip = nil
local delivered = false
local signed = false
local payIncrease = false
local payIncAmt = 0
local player = cache.ped
local progressBar = Config.ProgressBar == 'circle' and lib.progressCircle or lib.progressBar

CreateThread(function()
    lib.requestModel(Config.PedModel)
    local coords = Config.PedLocation
    local truckerPed = CreatePed(0, Config.PedModel, Config.PedLocation.x, Config.PedLocation.y, Config.PedLocation.z-1.0, Config.PedLocation.w, false, false)
	TaskStartScenarioInPlace(truckerPed, 'WORLD_HUMAN_CLIPBOARD', 0, true)
	FreezeEntityPosition(truckerPed, true)
	SetEntityInvincible(truckerPed, true)
	SetBlockingOfNonTemporaryEvents(truckerPed, true)

    local PedBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    local blip = { blip = PedBlip, sprite = 739, color = 24, alpha = 255, route = false, scale = 0.7, shortRange = true, label = 'RoadRunner Logistics'}
    CreateBlip(blip)

    if Config.Target == 'ox' then
        exports.ox_target:addLocalEntity(truckerPed, {
            {
                name = 'kevin_trucker:getDelivery',
                icon = 'fas fa-circle',
                label = 'Get Delivery',
                onSelect = function()
                    lib.callback('kevin-trucker:getreputation', false, function(rep)
                        if rep then
                            VehicleMenu(rep)
                        end
                    end)
                end,
                canInteract = function()
                    return not DoesEntityExist(jobVehicle)
                end,
                distance = 2.0
            },
            {
                name = 'kevin_trucker:collectPayment',
                icon = 'fas fa-dollar-sign',
                label = 'Collect Payment',
                onSelect = function()
                    ReturnCollect()
                end,
                canInteract = function()
                    return not DoesEntityExist(jobTrailer) and delivered
                end,
                distance = 2.0
            },
            {
                name = 'kevin_trucker:checkExperience',
                icon = 'fas fa-circle',
                label = 'Check Experience',
                onSelect = function()
                    lib.callback('kevin-trucker:getreputation', false, function(rep)
                        if rep then
                            QBCore.Functions.Notify('Job Experience: '..rep, 'primary', 6000)
                        end
                    end)
                end,
                distance = 2.0
            },
        })
    elseif Config.Target == 'qb' then
        exports['qb-target']:AddTargetEntity(truckerPed, {
            options = {
                {
                    icon = 'fas fa-circle',
                    label = 'Get Delivery',
                    action = function()
                        lib.callback('kevin-trucker:getreputation', false, function(rep)
                            if rep then
                                VehicleMenu(rep)
                            end
                        end)
                    end,
                    canInteract = function()
                        return not DoesEntityExist(jobVehicle)
                    end,
                },
                {
                    icon = 'fas fa-dollar-sign',
                    label = 'Collect Payment',
                    action = function()
                        ReturnCollect()
                    end,
                    canInteract = function()
                        return not DoesEntityExist(jobTrailer) and delivered
                    end,
                },
                {
                    icon = 'fas fa-circle',
                    label = 'Check Experience',
                    action = function()
                        lib.callback('kevin-trucker:getreputation', false, function(rep)
                            if rep then
                                QBCore.Functions.Notify('Job Experience: '..rep, 'primary', 6000)
                            end
                        end)
                    end,
                },
            },
            distance = 2.0
        })
    end
end)

function ReturnCollect()
    local truckCoords = GetEntityCoords(jobVehicle)
    local wCoords = vector3(Config.PedLocation.x, Config.PedLocation.y, Config.PedLocation.z)

    local dist = #(truckCoords - wCoords)
    if dist < 15.0 then
        TriggerServerEvent('kevin-trucker:collectpayment', delivered, pay, reputation, payIncrease, payIncAmt)
        if DoesEntityExist(jobVehicle) then
            SetEntityAsMissionEntity(jobVehicle, true, true)
            NetworkRequestControlOfEntity(jobVehicle)
            Wait(500)
            DeleteEntity(jobVehicle)
        end
        delivered = false
        jobVehicle = nil
        jobTrailer = nil
        locationBlip = nil
        locationPed = nil
        destBlip = nil
        trailerBlip = nil
        delivered = false
        signed = false
        payIncrease = false
        payIncAmt = 0
    else
        QBCore.Functions.Notify('Truck is not nearby..', 'error')
    end
end

function VehicleMenu(rep)
    local resgisteredMenu = {
        id = 'vehiclemenu',
        title = 'Available Vehicles',
        options = {}
    }
    for i, v in ipairs(Config.Vehicles) do
        local vehiclename = QBCore.Shared.Vehicles[v.vehicle]['name']
        if rep >= v.xpneeded then
            resgisteredMenu.options[#resgisteredMenu.options+1] = {
                title = vehiclename,
                icon = 'fas fa-truck',
                description = 'XP Needed: '..v.xpneeded,
                image = v.image,
                arrow = true,
                progress = v.gaslevel,
                onSelect = function (data)
                    SpawnVehicle(data)
                end,
                args = { vehicle = v.vehicle, payIncrease = v.payincrease, amount = v.amount, gasLevel = v.gaslevel},
            }
        else
            resgisteredMenu.options[#resgisteredMenu.options+1] = {
                title = vehiclename,
                disabled = true,
                icon = 'fas fa-truck',
                description = 'XP Needed: '..v.xpneeded,
            }
        end
    end
    lib.registerContext(resgisteredMenu)
    lib.showContext('vehiclemenu')
end

function SpawnVehicle(data)
    local spawn
    local counter = 0
    payIncrease = data.payIncrease
    payIncAmt = data.amount
    repeat
        spawn = Config.SpawnLocations[math.random(#Config.SpawnLocations)]
        counter = counter + 1
        if counter > 10 then
            QBCore.Functions.Notify('Area is currently occupied with a vehicle', 'error')
            return
        end
    until not IsAnyVehicleNearPoint(spawn.x, spawn.y, spawn.z, 1.0)
    lib.requestModel(data.vehicle)
    jobVehicle = CreateVehicle(data.vehicle, spawn.x, spawn.y, spawn.z, spawn.w, true, true)
    if DoesEntityExist(jobVehicle) then
        AddTruckBlip()
        QBCore.Functions.Notify('Go to the location marked on your gps', 'primary', 8000)
        local VehiclePlate = QBCore.Functions.GetPlate(jobVehicle)
        networkID = NetworkGetNetworkIdFromEntity(jobVehicle)
        SetEntityAsMissionEntity(jobVehicle, true, true)
        SetNetworkIdExistsOnAllMachines(networkID, true)
        NetworkRegisterEntityAsNetworked(jobVehicle)
        SetNetworkIdCanMigrate(networkID, true)
        SetVehicleDirtLevel(jobVehicle, 0)
        SetVehicleEngineOn(jobVehicle, true, true, false)
        SetVehicleDoorsLocked(jobVehicle, 1)
        exports[Config.FuelScript]:SetFuel(jobVehicle, data.gasLevel)
        TriggerEvent('vehiclekeys:client:SetOwner', VehiclePlate)
        GetDestination()
    end
end

function AddTruckBlip()
    CreateThread(function ()
        while DoesEntityExist(jobVehicle) do
            if not IsPedInVehicle(player, jobVehicle, false) then
                if not DoesBlipExist(truckBlip) then
                    truckBlip = AddBlipForEntity(jobVehicle)
                    local blip = { blip = truckBlip, sprite = 477, color = 24, alpha = 255, route = true, scale = 0.7, label = 'Truck'}
                    CreateBlip(blip)
                end
            else
                if DoesBlipExist(truckBlip) then
                    RemoveBlip(truckBlip)
                end
            end
            Wait(1000)
        end
    end)
end

function DestinationProps()
    local data = Config.Locations[math.random(#Config.Locations)]
    trailerPos = data.trailerpos
    trailerHash = data.trailerhash
    pedPos = data.pedpos
    pedHash = data.pedhash
    dropLocation = data.droppos[math.random(#data.droppos)]
    pay = data.pay
    reputation = data.reputation
    return trailerPos, trailerHash, pedPos, pedHash, dropLocation
end

function GetDestination()
    if not DoesEntityExist(jobVehicle) then return end
    trailerPos, trailerHash, pedPos, pedHash = DestinationProps()
    locationBlip = AddBlipForCoord(trailerPos.x, trailerPos.y, trailerPos.z)

    local blip = { blip = locationBlip, sprite = 12, color = 24, alpha = 255, route = true, scale = 0.7, label = 'Trailer Location'}
    CreateBlip(blip)

    sphere = lib.zones.sphere({
        coords = vec3(trailerPos.x, trailerPos.y, trailerPos.z),
        radius = 30,
        debug = false,
        onEnter = SetupLocation,
    })
end

function SetupLocation()
    if DoesBlipExist(locationBlip) then
        RemoveBlip(locationBlip)
    end
    if not DoesEntityExist(jobTrailer) or DoesEntityExist(locationPed) then
        lib.requestModel(trailerHash)
        jobTrailer = CreateVehicle(trailerHash, trailerPos.x, trailerPos.y, trailerPos.z, trailerPos.w, true, true)
        FreezeEntityPosition(jobTrailer, true)
        SetEntityAsMissionEntity(jobTrailer, true, true)
        trailerID = NetworkGetNetworkIdFromEntity(jobTrailer)
        SetNetworkIdExistsOnAllMachines(trailerID, true)
        NetworkRegisterEntityAsNetworked(jobTrailer)

        trailerBlip = AddBlipForEntity(jobTrailer)
        local blip = { blip = trailerBlip, sprite = 479, color = 24, alpha = 255, route = true, scale = 0.7, label = 'Trailer'}
        CreateBlip(blip)

        lib.requestModel(pedHash)
        locationPed = CreatePed(0, pedHash, pedPos.x, pedPos.y, pedPos.z-1.0, pedPos.w, false, false)
        TaskStartScenarioInPlace(locationPed, 'WORLD_HUMAN_CLIPBOARD', 0, true)
        FreezeEntityPosition(locationPed, true)
        SetEntityInvincible(locationPed, true)
        SetBlockingOfNonTemporaryEvents(locationPed, true)

        if Config.Target == 'ox' then
            exports.ox_target:addLocalEntity(locationPed, {
                {
                    name = 'trucker_setup_ped',
                    icon = 'fas fa-pen-to-square',
                    label = 'Sign & Release',
                    onSelect = function()
                        ReleaseTrailer()
                    end,
                    canInteract = function()
                        return DoesEntityExist(jobTrailer) and not signed
                    end,
                    distance = 2.0
                },
            })
        elseif Config.Target == 'qb' then
            exports['qb-target']:AddTargetEntity(locationPed, {
                options = {
                    {
                        icon = 'fas fa-pen-to-square',
                        label = 'Sign & Release',
                        action = function()
                            ReleaseTrailer()
                        end,
                        canInteract = function()
                            return DoesEntityExist(jobTrailer) and not signed
                        end,
                    },
                },
                distance = 2.0
            })
        end

        sphere:remove()
    end
end

function ReleaseTrailer()
    signed = true
    if progressBar({
        duration = math.random(2500, 3000),
        label = 'Signing..',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = 'missheistdockssetup1clipboard@base', clip = 'base', flag = 1 }
    }) then
        ClearPedTasks(player)
        signed = true
        FreezeEntityPosition(locationPed, false)
        SetEntityAsNoLongerNeeded(locationPed)
        if DoesEntityExist(jobTrailer) then
            FreezeEntityPosition(jobTrailer, false)
            AttachTrailer()
            QBCore.Functions.Notify('Hook up trailer and get moving...', 'primary', 8000)
        end
    else
        ClearPedTasks(player)
        signed = false
        QBCore.Functions.Notify('Cancelled', 'error')
    end
end

function AttachTrailer()
    CreateThread(function ()
        while DoesEntityExist(jobTrailer) do
            local pCoords =  GetEntityCoords(player)
            local destCoords = vector3(dropLocation.x, dropLocation.y, dropLocation.z)
            local trailerCoords = GetEntityCoords(jobTrailer)

            if not IsEntityAttachedToEntity(jobVehicle, jobTrailer) then
                if not DoesBlipExist(trailerBlip) then
                    trailerBlip = AddBlipForEntity(jobTrailer)
                    local blip = {blip = trailerBlip, sprite = 479, color = 24, alpha = 255, route = true, scale = 0.7, label = 'Trailer'}
                    CreateBlip(blip)
                end
            else
                if DoesBlipExist(trailerBlip) then
                    RemoveBlip(trailerBlip)
                    destBlip = AddBlipForCoord(destCoords.x, destCoords.y, destCoords.z)
                    local blip = { blip = destBlip, sprite = 12, color = 24, alpha = 255, route = true, scale = 0.7, label = 'Destination'}
                    CreateBlip(blip)
                end
            end

            local dist = #(destCoords - trailerCoords)
            local dist2 = #(trailerCoords - pCoords)
            if dist < 10.0 then
                if not IsEntityAttachedToEntity(jobVehicle, jobTrailer) then
                    if dist2 > 60.0 then
                        SetEntityAsMissionEntity(jobTrailer, true, true)
                        NetworkRequestControlOfEntity(jobTrailer)
                        Wait(500)
                        DeleteEntity(jobTrailer)
                        if DoesBlipExist(destBlip) then
                            RemoveBlip(destBlip)
                        end
                        delivered = true
                        QBCore.Functions.Notify('Return to the warehouse', 'primary', 8000)
                    end
                end
            end
            Wait(1000)
        end
    end)
end


function CreateBlip(data)
    if not data then
        print('Invalid data was passed to the create blip event')
        return
    end

    SetBlipSprite(data.blip, data.sprite)
    SetBlipColour(data.blip, data.color)
    SetBlipAlpha(data.blip, data.alpha)
    SetBlipScale(data.blip, data.scale)

    if data.shortRange then
        SetBlipAsShortRange(data.blip, data.shortRange)
    end
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(data.label)
    EndTextCommandSetBlipName(data.blip)

    if data.route then
        SetBlipRoute(data.blip, data.route)
        if not data.routeColor then
            data.routeColor = data.color
            SetBlipRouteColour(data.blip, data.routeColor)
        end
    end
    SetBlipCategory(data.blip, 10)
    AddTextEntry('BLIP_PROPCAT', 'Trucking Job')
end
