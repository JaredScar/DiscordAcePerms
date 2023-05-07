Citizen.CreateThread(function()
    updatePath = "/JaredScar/DiscordAcePerms" -- your git user/repo path
    resourceName = "DiscordAcePerms ("..GetCurrentResourceName()..")" -- the resource name
    
    function checkVersion(err,responseText, headers)
        curVersion = LoadResourceFile(GetCurrentResourceName(), "version.txt") -- make sure the "version" file actually exists in your resource root!
    
        if curVersion ~= responseText and tonumber(curVersion) < tonumber(responseText) then
            print("\n###############################")
            print("\n"..resourceName.." is outdated, should be:\n"..responseText.."is:\n"..curVersion.."\nplease update it from https://github.com"..updatePath.."")
            print("\n###############################")
        elseif tonumber(curVersion) > tonumber(responseText) then
            print("You somehow skipped a few versions of "..resourceName.." or the git went offline, if it's still online I advise you to update...")
        else
            print("\n"..resourceName.." is up to date!")
        end
    end
    
    PerformHttpRequest("https://raw.githubusercontent.com/JaredScar/DiscordAcePerms/master/version.txt", checkVersion, "GET")
end)