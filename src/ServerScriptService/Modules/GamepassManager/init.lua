local GamepassManager = {}

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GamepassesFunctions = require(script.GamepassesFunctions)
local GamepassEnum = require(ReplicatedStorage.Enums.Gamepass)

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local Gamepass = require(ReplicatedStorage.Enums.Gamepass)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local bridge = BridgeNet2.ReferenceBridge("GamepassService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

function GamepassManager:Init()
	GamepassManager:StartListner()
	GamepassManager:InitBridgeListener()
end

function GamepassManager:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "HasGamePass" then
			local gamepassId = data.data.GamepassId
			return GamepassManager:HasGamePass(player, gamepassId)
		end
	end
end

function GamepassManager:StartListner()
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, purchasedPassID, wasPurchased)
		if wasPurchased then
			local grantPurchaseHandler = GamepassesFunctions[purchasedPassID]
			grantPurchaseHandler(player)
		end
	end)
end

function GamepassManager:HasGamePass(player, gamepassId)
	local success, hasPass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassId)
	end)

	return success and hasPass
end

function GamepassManager:InitGamePassesFromPlayer(player: Player)
	task.spawn(function()
		local gamepassesProcessed = PlayerDataHandler:Get(player, "gamepassesProcessed")
		for _, value in GamepassEnum.ENUM do
			local hasGamePass = GamepassManager:HasGamePass(player, value.Id)

			-- Se tem GamePass e ainda não foi processada, processa ele
			if hasGamePass and not gamepassesProcessed[value.Name] then
				local grantPurchaseHandler = GamepassesFunctions[value.Id]
				grantPurchaseHandler(player)
			end
		end
	end)
end

return GamepassManager
