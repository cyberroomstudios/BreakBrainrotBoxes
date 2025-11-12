local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local MoneyService = require(ServerScriptService.Modules.MoneyService)

return function(context, player, amount)
	MoneyService:GiveMoney(player, amount, true)
	return "Success!"
end
