local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Crate = require(ReplicatedStorage.Enums.Crate)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local ToolService = require(ServerScriptService.Modules.ToolService)

local CrateService = {}

function CrateService:Init() end

function CrateService:Give(player: Player, crateName: string)
	if not Crate.CRATES[crateName] then
		warn("CRATE NOT FOUND: " .. crateName)
		return
	end

	PlayerDataHandler:Update(player, "cratesBackpack", function(current)
		if current[crateName] then
			current[crateName] = current[crateName] + 1
			return current
		end

		current[crateName] = 1
		return current
	end)

	ToolService:Give(player, "CRATE", crateName, 1)
end

function CrateService:Consume(player: Player, crateName: string)
	if not Crate.CRATES[crateName] then
		warn("CRATE NOT FOUND: " .. crateName)
		return
	end

	PlayerDataHandler:Update(player, "cratesBackpack", function(current)
		if current[crateName] > 0 then
			current[crateName] = current[crateName] - 1
		end

		return current
	end)
end

return CrateService
