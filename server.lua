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
function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }

    --Loop over all identifiers
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        --Convert it to a nice table.
        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end

    return identifiers
end

hasPermsAlready = {}
discordDetector = {}

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
	deferrals.defer();
	local src = source; 
	local identifierDiscord = false;
	local steam = ExtractIdentifiers(src).steam:gsub("steam:", "");
	if not has_value(hasPermsAlready, steam) then
		for k, v in ipairs(GetPlayerIdentifiers(src)) do
				if string.sub(v, 1, string.len("discord:")) == "discord:" then
					identifierDiscord = v
				end
		end
		local permAdd = "add_principal identifier.steam:" .. steam .. " "
		if identifierDiscord then
			if not has_value(hasPermsAlready, steam) then
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
					table.insert(hasPermsAlready, steam)
				else
					print("[DiscordAcePerms] " .. GetPlayerName(src) .. " has not gotten their permissions cause roleIDs == false")
				end
			end
		else 
			if not has_value(discordDetector, steam) then 
				-- Kick with we couldn't find their discord, try to restart it whilst fivem is closed 
				deferrals.done('[DiscordAcePerms] DISCORD NOT FOUND... Try restarting Discord application whilst FiveM is closed! ' ..
					'This notice will not be displayed to you upon next connect.')
				table.insert(discordDetector, steam);
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
	local identifierDiscord = "";
	if not has_value(hasPermsAlready, PlayerIdentifier('discord', src)) then
		for k, v in ipairs(GetPlayerIdentifiers(src)) do
				if string.sub(v, 1, string.len("discord:")) == "discord:" then
					identifierDiscord = v
				end
		end
		local dis = identifierDiscord;
		if identifierDiscord then
			permAdd = "add_principal identifier.discord:" .. identifierDiscord .. " "
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
			