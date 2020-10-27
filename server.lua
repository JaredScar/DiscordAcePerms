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
			print("[DiscordAcePerms] (playerDropped) Removed " 
				.. GetPlayerName(src) .. " from role group " .. permGroup)
		end
		PermTracker[discord] = nil;
	end
	DiscordDetector[license] = nil;
	InDiscordDetector[license] = nil;
end)
debugScript = 0;
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
	deferrals.defer();
	local src = source; 
	local identifierDiscord = "";
	local license = ExtractIdentifiers(src).license;
	local discord = ExtractIdentifiers(src).discord:gsub("discord:", "");
		for k, v in ipairs(GetPlayerIdentifiers(src)) do
				if string.sub(v, 1, string.len("discord:")) == "discord:" then
					identifierDiscord = v
				end
		end
		local permAdd = "add_principal identifier.discord:" .. discord .. " "
		if identifierDiscord then
				if debugScript then 
					print("Gets past identifierDiscord statement");
				end
				local roleIDs = exports.Badger_Discord_API:GetDiscordRoles(src)
				if debugScript then 
					print("Value of roleIDs == " .. tostring(roleIDs));
				end
				if not (roleIDs == false) then
					if debugScript then 
						print("Gets past (not [roleIDs == false]) statement");
					end
					for i = 1, #roleList do
						for j = 1, #roleIDs do
							if exports.Badger_Discord_API:CheckEqual(roleList[i][1], roleIDs[j]) then
								print("[DiscordAcePerms] (playerConnecting) Added " .. GetPlayerName(src) .. " to role group " .. roleList[i][2]);
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
					end
					print("[DiscordAcePerms] (playerConnecting) Player " .. GetPlayerName(src) .. " has been granted their permissions...");
				else
					print("[DiscordAcePerms] " .. GetPlayerName(src) .. " has not gotten permissions because we could not find their roles...")
					if InDiscordDetector[license] == nil then 
						-- Notify them they are not in the Discord 
						InDiscordDetector[license] = true;
						deferrals.done('[DiscordAcePerms] You were not detected to be in our Discord server...' .. 
							' Either that or we could not find your roles ' ..
							'at this time. Please relog.');
						return;
					end
				end
		else 
			if DiscordDetector[license] == nil then 
				-- Kick with we couldn't find their discord, try to restart it whilst fivem is closed 
				DiscordDetector[license] = true;
				print('[DiscordAcePerms] Discord was not found for player ' .. GetPlayerName(src) .. "...")
				deferrals.done('[DiscordAcePerms] DISCORD NOT FOUND... Try restarting Discord application whilst FiveM is closed! ' ..
					'This notice will not be displayed to you upon next connect.')
				return;
			end
		end
	deferrals.done();
end)