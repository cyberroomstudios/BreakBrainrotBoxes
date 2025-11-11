local GamepassesFunctions = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Gamepass = require(ReplicatedStorage.Enums.Gamepass)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local LuckService = require(ServerScriptService.Modules.LuckService)
local MoneyService = require(ServerScriptService.Modules.MoneyService)

GamepassesFunctions[Gamepass:GetEnum("ULTRA_LUCK").Id] = function(player)
	LuckService:AddPlayerLuck(player, 3)
	GamepassesFunctions:AddGamepassesProcessed(player, "ULTRA_LUCK")
	return true
end

GamepassesFunctions[Gamepass:GetEnum("MEGA_LUCK").Id] = function(player)
	LuckService:AddPlayerLuck(player, 2)
	GamepassesFunctions:AddGamepassesProcessed(player, "MEGA_LUCK")

	return true
end

GamepassesFunctions[Gamepass:GetEnum("SUPER_LUCK").Id] = function(player)
	LuckService:AddPlayerLuck(player, 1.5)
	GamepassesFunctions:AddGamepassesProcessed(player, "SUPER_LUCK")

	return true
end

GamepassesFunctions[Gamepass:GetEnum("BASE_LUCK").Id] = function(player)
	LuckService:AddPlayerLuck(player, 1.2)
	GamepassesFunctions:AddGamepassesProcessed(player, "BASE_LUCK")

	return true
end

GamepassesFunctions[Gamepass:GetEnum("2X_CASH").Id] = function(player)
	MoneyService:GiveBrainrotCashMultiplier(player)
	return true
end

function GamepassesFunctions:AddGamepassesProcessed(player: Player, gamePassName: string)
	PlayerDataHandler:Update(player, "gamepassesProcessed", function(current)
		current[gamePassName] = true
		return current
	end)
end
return GamepassesFunctions
