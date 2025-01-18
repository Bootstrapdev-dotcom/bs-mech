-- Resource Metadata
fx_version 'cerulean'
games {'gta5' }

author 'Bootstrap Development'
description 'Simple Ai Mechanic Script For Your Server '
version '1.0.0'

lua54 'yes'


name 'bs-mech'


client_scripts {
    'client/main.lua',
}

server_script {
    'server/main.lua',
}

shared_scripts {
    '/config/shared.lua',
}

dependiences {
    'qb-core',
    'qb-phone',
    'qb-target'
}