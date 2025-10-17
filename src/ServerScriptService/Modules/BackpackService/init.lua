local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local ToolService = require(ServerScriptService.Modules.ToolService)

local BackpackService = {}

function BackpackService:Init() end

function BackpackService:GiveFromInit(player: Player)
	local crates = PlayerDataHandler:Get(player, "cratesBackpack")

	for crateName, amount in crates do
		if amount > 0 then
			ToolService:Give(player, "CRATE", crateName, amount)
		end
	end
end

return BackpackService
