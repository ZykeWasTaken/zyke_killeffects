fx_version "cerulean"
game "gta5"
lua54 "yes"

client_script "client.lua"

shared_scripts {
    "shared.lua",
    "@ox_lib/init.lua",
}

server_scripts {
    "server.lua",
    "@oxmysql/lib/MySQL.lua",
    -- "@mysql-async/lib/MySQL.lua",
}