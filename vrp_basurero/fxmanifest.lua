fx_version "adamant"
games {"gta5"}

description "vRP Basurero"
--ui_page "ui/index.html"

dependency "vrp"

server_script "@vrp/lib/utils.lua"
server_script "server.lua"
