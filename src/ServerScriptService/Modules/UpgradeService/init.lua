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

local Upgrades = require(ReplicatedStorage.Enums.Upgrades)
local MoneyService = require(ServerScriptService.Modules.MoneyService)

function UpgradeService:Init()
	UpgradeService:InitBridgeListener()
end

function UpgradeService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "BuyPower" then
			return UpgradeService:Buy(player, "Power")
		end
		if data[actionIdentifier] == "BuySpeed" then
			return UpgradeService:Buy(player, "Speed")
		end

		if data[actionIdentifier] == "BuyCapacity" then
			return UpgradeService:Buy(player, "Capacity")
		end
	end
end

function UpgradeService:Buy(player: Player, upgradeType: string)
	-- Verifica se tem dinheiro
	local currentUpgrade = PlayerDataHandler:Get(player, "crateBreaker")[upgradeType]

	if not Upgrades[upgradeType] then
		return
	end
	if not Upgrades[upgradeType][currentUpgrade + 1] then
		return
	end

	local buyValue = Upgrades[upgradeType][currentUpgrade + 1]

	if not MoneyService:HasMoney(player, buyValue) then
		return
	end

	MoneyService:ConsumeMoney(player, buyValue)

	local newValue = 0
	PlayerDataHandler:Update(player, "crateBreaker", function(current)
		current[upgradeType] = current[upgradeType] + 1
		newValue = current[upgradeType]
		return current
	end)

	return newValue
end

return UpgradeService
