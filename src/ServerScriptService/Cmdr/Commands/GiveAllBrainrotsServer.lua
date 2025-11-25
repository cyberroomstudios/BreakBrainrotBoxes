local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Brainrots = require(ReplicatedStorage.Enums.Brainrots)
local BrainrotService = require(ServerScriptService.Modules.BrainrotService)
local IndexService = require(ServerScriptService.Modules.IndexService)

return function(context, player)
	for name, value in Brainrots do
		local success = pcall(function()
			BrainrotService:SaveBrainrotInBackpack(player, name, "NORMAL")
			IndexService:Add(player, name, "NORMAL")
		end)
		if not success then
			print(name .. "-" .. tostring(success))
		end
	end
	return "Success!"
end
