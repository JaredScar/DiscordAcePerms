-----------------------------------
--- Discord ACE Perms by Badger ---
-----------------------------------

--- Code ---
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

DiscordDetector = {}

InDiscordDetector = {}

PermTracker = {}

roleList = Config.roleList;

AddEventHandler('playerDropped', function (reason) 
	local src = source;
	local discord = ExtractIdentifiers(src).discord:gsub("discord:", "");
	local license = ExtractIdentifiers(src).license;
	if PermTracker[discord] ~= nil then 
		-- They have perms that need to be removed:
		local list = PermTracker[discord];
		for i = 1, #list do 
			local permGroup = list[i];
			ExecuteCommand('remove_principal identifier.discord:' .. discord .. " " .. permGroup);
			if (Config.Print_Perm_Grants_And_Removals) then
				print("[DiscordAcePerms] (playerDropped) Removed " 
					.. GetPlayerName(src) .. " from role group " .. permGroup)
			end
		end
		PermTracker[discord] = nil;
	end
	DiscordDetector[license] = nil;
end)
debugScript = Config.DebugScript;

permThrottle = {};

Citizen.CreateThread(function()
	while true do 
		for discord, count in pairs(permThrottle) do 
			permThrottle[discord] = (permThrottle[discord] - 1);
			if (permThrottle[discord] <= 0) then 
				permThrottle[discord] = nil;
			end
		end
		Wait(1000);
	end
end)

prefix = '^9[^5DiscordAcePerms^9] ^3'
function sendMsg(src, msg) 
	TriggerClientEvent('chatMessage', src, prefix .. msg);
end

if (Config.Allow_Refresh_Command) then 
	RegisterCommand('refreshPerms', function(src, args, rawCommand)
		local discordIdentifier = ExtractIdentifiers(src).discord;
		if (discordIdentifier ~= nil) then 
			local discord = discordIdentifier:gsub("discord:", "");
			if (permThrottle[discord] == nil) then 
				permThrottle[discord] = Config.Refresh_Throttle;
				sendMsg(src, "Your permissions have been refreshed ^2successfully^3...");
				RegisterPermissions(src, 'refreshPerms');
				TriggerEvent('vMenu:RequestPermissions', src);
			else 
				local currentThrottle = permThrottle[discord];
				sendMsg(src, "^1ERR: You cannot refresh your permissions since you are on a cooldown. You can refresh in ^3" .. currentThrottle .. " ^1seconds...");
			end
		else 
			sendMsg(src, "^1ERR: Your discord identifier was not found...");
		end
	end)
end 

function sendDbug(msg, eventLocation)
	if (debugScript) then 
		print("[DiscordAcePerms DEBUG] (" .. eventLocation .. ") " .. msg);
	end 
end

ROLE_CACHE = {};
function convertRolesToMap(roleIds)
	roleMap = {};
	for i = 1, #roleIds do 
		roleMap[tostring(roleIds[i])] = true;
	end
	return roleMap;
end

function RegisterPermissions(src, eventLocation)
	local license = ExtractIdentifiers(src).license;
	local discord = ExtractIdentifiers(src).discord:gsub("discord:", "");
	if (discord) then
		sendDbug("Player " .. GetPlayerName(src) .. " had their Discord identifier found...", eventLocation);
		exports['Badger_Discord_API']:ClearCache(discord);
		PermTracker[discord] = nil;
		local permAdd = "add_principal identifier.discord:" .. discord .. " ";
		local roleIDs = exports.Badger_Discord_API:GetDiscordRoles(src);
		if not (roleIDs == false) then
			local ROLE_MAP = convertRolesToMap(roleIDs);
			sendDbug("Player " .. GetPlayerName(src) .. " had a valid roleIDs... Length: " .. tostring(#roleIDs), eventLocation);
			for i = 1, #roleList do
				local discordRoleId = nil;
				if (ROLE_CACHE[roleList[i][1]] ~= nil) then 
					discordRoleId = ROLE_CACHE[roleList[i][1]];
				else
					discordRoleId = exports.Badger_Discord_API:FetchRoleID(roleList[i][1]);
					if (discordRoleId ~= nil) then 
						ROLE_CACHE[roleList[i][1]] = discordRoleId; 
					end 
				end
				sendDbug("Checking to add permission: " .. roleList[i][2] .. " => Player " .. GetPlayerName(src) .. " has role " .. tostring(discordRoleId) .. " and it was compared against " .. roleList[i][1], eventLocation);
				if ROLE_MAP[tostring(discordRoleId)] ~= nil then
					if (Config.Print_Perm_Grants_And_Removals) then 
						print("[DiscordAcePerms] (" .. eventLocation .. ") Added " .. GetPlayerName(src) .. " to role group " .. roleList[i][2]);
					end
					ExecuteCommand(permAdd .. roleList[i][2])
					-- Track the permission node given: 
					if PermTracker[discord] ~= nil then 
						-- Has them, we add to list 
						local list = PermTracker[discord];
						table.insert(list, roleList[i][2]);
						PermTracker[discord] = list;
					else 
						-- Doesn't have them, give them a list 
						local list = {};
						table.insert(list, roleList[i][2]);
						PermTracker[discord] = list;
					end
				end
			end
			if (debugScript) then 
				print("[DiscordAcePerms DEBUG] (" .. eventLocation .. ") Player " .. GetPlayerName(src) .. " has been granted their permissions...");
			end 
			return true;
		else
			if (debugScript) then 
				print("[DiscordAcePerms DEBUG] (" .. eventLocation .. ")" .. GetPlayerName(src) .. " has not gotten permissions because we could not find their roles...");
			end
			return false;
		end
	end
	return false;
end

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
	deferrals.defer();
	local src = source;
	local license = ExtractIdentifiers(src).license;
	local discord = ExtractIdentifiers(src).discord:gsub("discord:", "");
		local permAdd = "add_principal identifier.discord:" .. discord .. " ";
		if discord then
			if (not RegisterPermissions(src, 'playerConnecting')) then
				if InDiscordDetector[license] == nil then 
					-- Notify them they are not in the Discord 
					InDiscordDetector[license] = true;
					local clicked = false;
					while not clicked do 
						deferrals.presentCard(card,
						function(data, rawData)
							if (data.submitId == 'played') then 
								clicked = true;
								deferrals.done()
							end
						end)
						Citizen.Wait((1000 * 13));
					end
					return;
				end
			else
				TriggerEvent('vMenu:RequestPermissions', src); 
			end
		else 
			if DiscordDetector[license] == nil then 
				-- Kick with we couldn't find their discord, try to restart it whilst fivem is closed 
				DiscordDetector[license] = true;
				print('[DiscordAcePerms] Discord was not found for player ' .. GetPlayerName(src) .. "...")
				local clicked = false;
				while not clicked do 
					deferrals.presentCard(card,
					function(data, rawData)
						if (data.submitId == 'played') then 
							clicked = true;
							deferrals.done()
						end
					end)
					Citizen.Wait((1000 * 13));
				end
				return;
			end
		end
	deferrals.done();
end)

-- IMPORTANT
-- 		BEFORE EDITING:
--			 Do not take out my credit... Out of respect for my resources, do not remove my credit. Thank you.
card = '{"type":"AdaptiveCard","$schema":"http://adaptivecards.io/schemas/adaptive-card.json","version":"1.2","body":[{"type":"Container","items":[{"type":"TextBlock","text":"Welcome to ' .. Config.Server_Name .. '","wrap":true,"fontType":"Default","size":"ExtraLarge","weight":"Bolder","color":"Light"},{"type":"TextBlock","text":"You were not detected in our Discord!","wrap":true,"size":"Large","weight":"Bolder","color":"Light"},{"type":"TextBlock","text":"Please join below, then press play! Have fun!","wrap":true,"color":"Light","size":"Medium"},{"type":"ColumnSet","height":"stretch","minHeight":"100px","bleed":true,"horizontalAlignment":"Center","selectAction":{"type":"Action.OpenUrl"},"columns":[{"type":"Column","width":"stretch","items":[{"type":"ActionSet","actions":[{"type":"Action.OpenUrl","title":"Discord","url":"' .. Config.Discord_Link .. '","style":"positive"}]}]},{"type":"Column","width":"stretch","items":[{"type":"ActionSet","actions":[{"type":"Action.Submit","title":"Play","style":"positive", "id":"played"}]}]},{"type":"Column","width":"stretch","items":[{"type":"ActionSet","actions":[{"type":"Action.OpenUrl","title":"Website","style":"positive","url":"' .. Config.Website_Link .. '"}]}]}]},{"type":"ActionSet","actions":[{"type":"Action.OpenUrl","title":"DiscordAcePerms created by Badger","style":"destructive","iconUrl":"https://i.gyazo.com/c629f37bb1aeed2c1bc1768fdc93bc1a.gif","url":"https://discord.com/invite/WjB5VFz"}]}],"style":"default","bleed":true,"height":"stretch","isVisible":true}]}'
