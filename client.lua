-----------------------------------
--- Discord ACE Perms by Badger ---
-----------------------------------

--- Code ---

AddEventHandler('playerSpawned', function()
    local src = source
    TriggerServerEvent("DiscordAcePerms:GivePerms", src)
end)