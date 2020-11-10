# DiscordAcePerms
## Continued Documentation
https://docs.badger.store/fivem-discord-scripts/discordaceperms

## For all your hosting needs:
![Iceline Hosting](https://i.gyazo.com/24c65c27acc53ce0656cda7e7ed29230.gif)

### Use code `BADGER15` at https://iceline-hosting.com/billing/aff.php?aff=284 for `15% off` your first month of any service (excluding dedicated servers)

## Jared's Developer Community [Discord]
[![Developer Discord](https://discordapp.com/api/guilds/597445834153525298/widget.png?style=banner4)](https://discord.com/invite/WjB5VFz)

## Discontinued Documentation
### Version 1.0

#### Installation Information:

https://forum.fivem.net/t/discordaceperms-release/573044

This is another one of my discord scripts! :) If used properly along with my other scripts, you can fully make your server use only discord roles for permissions and chat roles ;)

You must set up IllusiveTea’s discord_perms script for this to work properly:

https://forum.fivem.net/t/discord-roles-for-permissions-im-creative-i-know/233805

The permissions for a user update after every restart when they first login (so long as they have the discord role ID associated with the group in the list).

#### How to set it up:


The 1s should be replaced with IDs of the respective roles in your discord server. The quotes with groups should represent the groups in your permissions.cfg or server.cfg.
```lua
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
