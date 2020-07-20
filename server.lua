-----------------------------------
--- Discord ACE Perms by Badger ---
-----------------------------------

--- Code ---

roleList = {
{1, "group.tc"}, -- Trusted Civ
{1, "group.ems"}, -- EMS
{1, "group.discord"}, -- DISCORD MEMBER
{1, "group.co"}, -- Community Cop
{1, "group.nitro"}, -- Nitro Booster
{1, "group.faaheli"}, --[[ FAA heli --- ]]
{1, "group.faacommercial"}, --[[ FAA planes--- ]]
{1, "group.donatormenu2"}, --[[ Donator Menu 2--- ]]
{1, "group.donatormenu1"}, --[[ Donator Menu 1--- ]]
{1, "group.trialmoderator"}, --[[ T-Mod --- ]] 
{1, "group.moderator"}, --[[ Moderator --- ]]
{1, "group.admin"}, --[[ Admin --- ]]
{1, "group.management"}, --[[ Management --- ]]
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
discordDetector = {}

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
	deferrals.defer();
	local src = source; 
	if not has_value(hasPermsAlready, PlayerIdentifier('discord', src)) then
		local dis = string.sub(tostring(PlayerIdentifier("discord", src)), 7)
		permAdd = "add_principal identifier.discord:" .. dis .. " "
		for k, v in ipairs(GetPlayerIdentifiers(src)) do
				if string.sub(v, 1, string.len("discord:")) == "discord:" then
					identifierDiscord = v
				end
		end
		if identifierDiscord then
			if not has_value(hasPermsAlready, PlayerIdentifier('steam', src)) then
				local roleIDs = exports.discord_perms:GetRoles(src)
				if not (roleIDs == false) then
					for i = 1, #roleList do
						for j = 1, #roleIDs do
							if (tostring(roleList[i][1]) == tostring(roleIDs[j])) then
								print("[DiscordAcePerms] Added " .. GetPlayerName(src) .. " to role group " .. roleList[i][2] .. " with discordRole ID: " .. roleIDs[j])
								ExecuteCommand(permAdd .. roleList[i][2])
							end
						end
					end
					table.insert(hasPermsAlready, PlayerIdentifier('discord', src))
				else
					print("[DiscordAcePerms] " .. GetPlayerName(src) .. " has not gotten their permissions cause roleIDs == false")
				end
			end
		else 
			if not has_value(discordDetector, PlayerIdentifier('discord', src)) then 
				-- Kick with we couldn't find their discord, try to restart it whilst fivem is closed 
				deferrals.done('[DiscordAcePerms] DISCORD NOT FOUND... Try restarting Discord application whilst FiveM is closed! ' ..
					'This notice will not be displayed to you upon next connect.')
				table.insert(discordDetector, PlayerIdentifier('discord', src));
				print('[DiscordAcePerms] Discord was not found for player ' .. GetPlayerName(src) .. "...")
				CancelEvent();
				return;
			end
		end
	end
	deferrals.done();
end)


-- @Deprecated 
RegisterServerEvent("DiscordAcePerms:GivePerms")
AddEventHandler("DiscordAcePerms:GivePerms", function()
	local src = source
	if not has_value(hasPermsAlready, PlayerIdentifier('discord', src)) then
		local dis = string.sub(tostring(PlayerIdentifier("discord", src)), 7)
		permAdd = "add_principal identifier.discord:" .. dis .. " "
		for k, v in ipairs(GetPlayerIdentifiers(src)) do
				if string.sub(v, 1, string.len("discord:")) == "discord:" then
					identifierDiscord = v
				end
		end
		if identifierDiscord then
			if not has_value(hasPermsAlready, PlayerIdentifier('discord', src)) then
				local roleIDs = exports.discord_perms:GetRoles(src)
				if not (roleIDs == false) then
					for i = 1, #roleList do
						for j = 1, #roleIDs do
							if (tostring(roleList[i][1]) == tostring(roleIDs[j])) then
								print("[DiscordAcePerms] Added " .. GetPlayerName(src) .. " to role group " .. roleList[i][2] .. " with discordRole ID: " .. roleIDs[j])
								ExecuteCommand(permAdd .. roleList[i][2])
							end
						end
					end
					table.insert(hasPermsAlready, PlayerIdentifier('discord', src))
				else
					print("[DiscordAcePerms] " .. GetPlayerName(src) .. " has not gotten their permissions cause roleIDs == false")
				end
			end
		end
	end
end)
			