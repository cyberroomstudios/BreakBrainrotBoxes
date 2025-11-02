local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)

local LuckService = {}

function LuckService:Init() end

function LuckService:GetLuckFromPlayer(player: Player)
	local luck = PlayerDataHandler:Get(player, "luck")
	return luck
end

return LuckService
