local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local MoneyService = require(ServerScriptService.Modules.MoneyService)
local BrainrotService = require(ServerScriptService.Modules.BrainrotService)

return function(context, player, brainrot, plotNumber)
	BrainrotService:SetInMap(player, plotNumber, brainrot)
	return "Success!"
end
