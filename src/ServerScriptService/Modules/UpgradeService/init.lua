local UpgradeService = {}

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local bridge = BridgeNet2.ReferenceBridge("UpgradeService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net
function UpgradeService:Init()
	UpgradeService:InitBridgeListener()
end

function UpgradeService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "BuyPower" then
			return UpgradeService:BuyPower(player)
		end
		if data[actionIdentifier] == "BuySpeed" then
			return UpgradeService:BuySpeed(player)
		end

		if data[actionIdentifier] == "BuyCapacity" then
			return UpgradeService:BuyCapacity(player)
		end
	end
end

function UpgradeService:BuyPower(player: Player)
	local newValue = 0
	PlayerDataHandler:Update(player, "crateBreaker", function(current)
		current.Power = current.Power + 1
		newValue = current.Power
		return current
	end)
	return newValue
end

function UpgradeService:BuySpeed(player: Player)
	local newValue = 0
	PlayerDataHandler:Update(player, "crateBreaker", function(current)
		current.Speed = current.Speed + 1
		newValue = current.Speed
		return current
	end)
	return newValue
end

function UpgradeService:BuyCapacity(player: Player)
	local newValue = 0
	PlayerDataHandler:Update(player, "crateBreaker", function(current)
		current.Capacity = current.Capacity + 1
		newValue = current.Capacity
		return current
	end)
	return newValue
end

return UpgradeService
