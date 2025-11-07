local IndexService = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local GameNotificationService = require(ServerScriptService.Modules.GameNotificationService)
local Brainrots = require(ReplicatedStorage.Enums.Brainrots)

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local GameSoundService = require(ServerScriptService.Modules.GameSoundService)
local bridge = BridgeNet2.ReferenceBridge("IndexService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

function IndexService:Init()
	IndexService:InitBridgeListener()
end

function IndexService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "GetNormalIndex" then
			return PlayerDataHandler:Get(player, "normalIndex")
		end

		if data[actionIdentifier] == "GetGoldenIndex" then
			return PlayerDataHandler:Get(player, "goldenIndex")
		end

		if data[actionIdentifier] == "GetDiamondIndex" then
			return PlayerDataHandler:Get(player, "diamondIndex")
		end
	end
end

function IndexService:Add(player: Player, itemName: string, mutationType: string)
	local itemEnum = Brainrots[itemName]

	local playerDataKey = {
		["NORMAL"] = "normalIndex",
		["GOLDEN"] = "goldenIndex",
		["DIAMOND"] = "diamondIndex",
	}

	if not itemName then
		return
	end

	PlayerDataHandler:Update(player, playerDataKey[mutationType], function(current)
		if current[itemName] then
			GameSoundService:Play(player, itemName)
			GameNotificationService:SendWarnNotification(player, "You Found The " .. itemEnum.GUI.Label)
			GameNotificationService:SendNewBrainrotNotification(player, itemName)

			return current
		end

		current[itemName] = true
		GameSoundService:Play(player, itemName)
		GameNotificationService:SendNewBrainrotNotification(player, itemName)

		return current
	end)
end

return IndexService
