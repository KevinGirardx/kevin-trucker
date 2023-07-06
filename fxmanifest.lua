fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'kevin-trucker'
description 'Trucking Script for QBCore'
author 'KevinGirardx'
version '1.0.1'

shared_script {
	'config.lua',
	'@ox_lib/init.lua'
}

client_scripts {
	'client/*.lua',
}

server_scripts {
	'server/*.lua',
}