Config = Config or {}

Config.JobNeeded = false
Config.Target = 'qb' -- 'qb' for QBCore Target, 'ox' for Overextended Target
Config.ProgressBar = 'circle' -- 'circle' for progressCircle, 'rectangle' for progressBar
Config.JobName = 'Trucker'
Config.PedModel = `a_m_o_soucent_02`
Config.PedLocation = vector4(150.39, -3213.07, 5.86, 54.23)
Config.FuelScript = 'ps-fuel' -- cdn-fuel, ps-fuel, lj-fuel change to whatever fuel system you use

Config.Vehicles = { -- you can adjust below to balance out how you want the job to go
    [1] = {
        vehicle = 'hauler', -- hash of the truck for the job
        xpneeded = 0, -- amount of xp/reputation needed in order to have access to the vehicle
        payincrease = false, -- if to have a pay increase based on the vehicle that you are using
        amount = 0, -- amount the pay should be increased by 
        gaslevel = 100, -- gas level the truck is spawned with
        image = 'https://media.discordapp.net/attachments/1066215446400999454/1126645643784487023/hauler.jpg',
    },
    [2] = {
        vehicle = 'packer',
        xpneeded = 100,
        payincrease = false,
        amount = 0,
        gaslevel = 100,
        image = 'https://media.discordapp.net/attachments/1066215446400999454/1126645643532836954/packer.jpg',
    },
    [3] = {
        vehicle = 'phantom',
        xpneeded = 500,
        payincrease = false,
        amount = 0,
        gaslevel = 100,
        image = 'https://media.discordapp.net/attachments/1066215446400999454/1126645644610785391/phantom.jpg',
    },
    [4] = {
        vehicle = 'phantom3',
        xpneeded = 1000,
        payincrease = false,
        amount = 0,
        gaslevel = 100,
        image = 'https://media.discordapp.net/attachments/1066215446400999454/1126645644078096394/images_gta-5_vehicles_commercial_main_phantom-custom.jpeg',
    },
}
Config.Locations = {
    [1] = {
        trailerpos = vector4(1512.54, -2098.63, 77.01, 271.43), -- location of the trailer
        trailerhash = `trailers4`, -- hash of the trailer for the location
        pedpos = vector4(1515.81, -2094.87, 76.91, 200.99), -- location of the ped top sign for the trailer
        pedhash = `cs_floyd`, -- hash of the ped that you must sign to release the trailer
        droppos = { -- location to drop the trailer off to complete the job
            vector3(1112.32, 2125.39, 53.44),
            vector3(210.19, 2748.98, 43.66)
        },
        pay = 250,
        reputation = 10,
    },
    [2] = {
        trailerpos = vector4(-153.68, -2541.0, 6.26, 145.7), -- location of the trailer
        trailerhash = `trailers2`, -- hash of the trailer for the location
        pedpos = vector4(-145.73, -2535.58, 6.15, 139.17), -- location of the ped top sign for the trailer
        pedhash = `cs_floyd`, -- hash of the ped that you must sign to release the trailer
        droppos = { -- location to drop the trailer off to complete the job
            vector3(2702.02, 3451.4, 55.8),
        },
        pay = 250,
        reputation = 10,
    },
}

-- Config.Trailers = {
--     `trailers2`,
--     `freighttrailer`,
--     `armytrailer`,
--     `trailerlarge`,
--     `trailers3`,
--     `trailers`,
-- }

Config.SpawnLocations = {
    vector4(144.95, -3210.3, 6.09, 268.32),
    vector4(132.81, -3210.22, 6.09, 271.26),
    vector4(132.92, -3216.21, 6.09, 269.94),
}

QBCore = exports['qb-core']:GetCoreObject()