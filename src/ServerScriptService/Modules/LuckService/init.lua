local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)

local LuckService = {}

function LuckService:Init() end

function LuckService:GetLuckFromPlayer(player: Player)
	local luck = PlayerDataHandler:Get(player, "luck")
	return luck
end

function LuckService:AddPlayerLuck(player: Player, newLuck: number)
	PlayerDataHandler:Update(player, "luck", function(current)
		return current + newLuck
	end)
end

return LuckService
