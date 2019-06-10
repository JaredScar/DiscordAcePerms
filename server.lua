-----------------------------------
--- Discord ACE Perms by Badger ---
-----------------------------------

--- Code ---

roleList = {
{1, "group.tc"}, --[[ Trusted-Civ --- ]] 
{1, "group.faa"}, --[[ FAA --- ]]
{1, "group.donator"}, --[[ Donator --- ]]
{1, "group.trialModerator"}, --[[ T-Mod --- ]] 
{1, "group.moderator"}, --[[ Moderator --- ]]
{1, "group.admin"}, --[[ Admin --- ]]
{1, "group.admin"}, --[[ Management --- ]]
{1, "group.owner"}, --[[ Owner --- ]]
}
local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end
function PlayerIdentifier(type, id)
    local identifiers = {}
    local numIdentifiers = GetNumPlayerIdentifiers(id)

    for a = 0, numIdentifiers do
        table.insert(identifiers, GetPlayerIdentifier(id, a))
    end

    for b = 1, #identifiers do
        if string.find(identifiers[b], type, 1) then
            return identifiers[b]
        end
    end
    return false
end
function stringsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

hasPermsAlready = {}

AddEventHandler('playerConnecting', function()
	local src = source
	local hex = string.sub(tostring(PlayerIdentifier("steam", src)), 7)
	permAdd = "add_principal identifier.steam:" .. hex .. " "
	for k, v in ipairs(GetPlayerIdentifiers(src)) do
			if string.sub(v, 1, string.len("discord:")) == "discord:" then
				identifierDiscord = v
			end
	end
	if identifierDiscord then
		if not has_value(hasPermsAlready, GetPlayerName(src)) then
			local roleIDs = exports.discord_perms:GetRoles(src)
			for i = 1, #roleList do
				for j = 1, #roleIDs do
					if (tostring(roleList[i][1]) == tostring(roleIDs[j])) then
						print("Added " .. GetPlayerName(src) .. " to role group " .. roleList[i][2] .. " with discordRole ID: " .. roleIDs[j])
						ExecuteCommand(permAdd .. roleList[i][2])
					end
				end
			end
			table.insert(hasPermsAlready, GetPlayerName(src))
		end
	end
end)

RegisterServerEvent("DiscordAcePerms:GivePerms")
AddEventHandler("DiscordAcePerms:GivePerms", function(_source)
	-- Deprecated
end)
			