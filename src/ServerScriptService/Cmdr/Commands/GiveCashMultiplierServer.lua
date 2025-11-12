local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local MoneyService = require(ServerScriptService.Modules.MoneyService)

return function(context, player, amount)
	MoneyService:GiveCashMultiplier(player, amount)
	return "Success!"
end
