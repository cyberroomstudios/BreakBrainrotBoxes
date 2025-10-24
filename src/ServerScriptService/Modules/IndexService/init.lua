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
		if data[actionIdentifier] == "GetCommonIndex" then
			return PlayerDataHandler:Get(player, "commonIndex")
		end
	end
end

function IndexService:AddCommon(player: Player, itemName: string)
	local itemEnum = Brainrots[itemName]

	if not itemName then
		return
	end

	PlayerDataHandler:Update(player, "commonIndex", function(current)
		if current[itemName] then
			GameNotificationService:SendWarnNotification(player, "You Found The " .. itemEnum.GUI.Label)
			return current
		end

		current[itemName] = true
		GameNotificationService:SendSuccessNotification(player, "You Found The " .. itemEnum.GUI.Label)

		return current
	end)
end

return IndexService
