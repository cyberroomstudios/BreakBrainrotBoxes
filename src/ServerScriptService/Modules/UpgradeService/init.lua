local UpgradeService = {}

-- Init Bridg Net
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
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
local WorkerService = require(ServerScriptService.Modules.WorkerService)
local Breakers = require(ReplicatedStorage.Enums.Breakers)
local BaseService = require(ServerScriptService.Modules.BaseService)

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

		if data[actionIdentifier] == "BuyBreaker" then
			local breakerType = data.data.BreakerName
			return UpgradeService:BuyBreaker(player, breakerType, true)
		end

		if data[actionIdentifier] == "GetBreakers" then
			return UpgradeService:GetBreakersFromPlayer(player)
		end

		if data[actionIdentifier] == "EquipBreaker" then
			local breakerType = data.data.BreakerName

			return UpgradeService:EquipBreaker(player, breakerType)
		end
	end
end

function UpgradeService:EquipBreaker(player: Player, breakerType: string)
	local breakers = PlayerDataHandler:Get(player, "breakers")

	if not breakers[breakerType] then
		return false
	end

	PlayerDataHandler:Update(player, "crateBreaker", function(current)
		current.Equiped = breakerType
		return current
	end)

	UpgradeService:UpdateBreakers(player)
	return true
end
function UpgradeService:GetBreakersFromPlayer(player: Player)
	local data = {
		Equiped = PlayerDataHandler:Get(player, "crateBreaker").Equiped,
		Purchaseds = PlayerDataHandler:Get(player, "breakers"),
	}

	return data
end

function UpgradeService:BuyBreaker(player: Player, breakerType: string, checkMoney: boolean)
	local breaakerEnum = Breakers[breakerType]
	if not breaakerEnum then
		return
	end

	if checkMoney then
		-- Verifica se tem dinheiro
		if not MoneyService:HasMoney(player, breaakerEnum.Price) then
			return
		end

		MoneyService:ConsumeMoney(player, breaakerEnum.Price)
	end

	PlayerDataHandler:Update(player, "breakers", function(current)
		current[breakerType] = true
		return current
	end)

	PlayerDataHandler:Update(player, "crateBreaker", function(current)
		current.Equiped = breakerType
		return current
	end)

	UpgradeService:UpdateBreakers(player)

	-- Atualiza a interface automaticamente após a compra sem dinheiro, ou seja, com robux
	if not checkMoney then
		local oldIndex = player:GetAttribute("BUY_BREAKER_WITH_ROBUX_UPDATE_INDEX") or 1
		player:SetAttribute("BUY_BREAKER_WITH_ROBUX_UPDATE_INDEX", oldIndex + 1)
	end

	return true
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

	player:SetAttribute(upgradeType, newValue)

	if upgradeType == "Capacity" then
		UpgradeService:EnableCrates(player)
	end
	return newValue
end

function UpgradeService:InitPlayerUpgrade(player: Player)
	local crateBreaker = PlayerDataHandler:Get(player, "crateBreaker")
	local equipedBreaker = crateBreaker.Equiped

	local breakerPowerBost = Breakers[equipedBreaker].Boosts.Power
	local breakerSpeedBost = Breakers[equipedBreaker].Boosts.Speed

	player:SetAttribute("Power", (crateBreaker.Power * 10) + breakerPowerBost)
	player:SetAttribute("Speed", crateBreaker.Speed + breakerSpeedBost)
	player:SetAttribute("Capacity", crateBreaker.Capacity)

	UpgradeService:ConfigureWorkerCapacity(player)
end

function UpgradeService:ConfigureWorkerCapacity(player: Player)
	WorkerService:EnableWorker(player)
	UpgradeService:EnableCrates(player)
end

function UpgradeService:EnableCrates(player)
	local function getScale()
		local base = BaseService:GetBase(player)
		local main = base:FindFirstChild("Main")
		local breakersAreaFolder = main:WaitForChild("BreakersArea")
		local containersFolder = breakersAreaFolder:WaitForChild("Containers")
		local containersModel = containersFolder:WaitForChild("Container")
		local breakerFolder = containersModel:WaitForChild("Breaker")
		local breakerCapacity = PlayerDataHandler:Get(player, "crateBreaker").Capacity
		local scale = breakerFolder[breakerCapacity]:GetAttribute("SCALE")
		print(scale)
		return scale
	end

	local capacity = player:GetAttribute("Capacity")

	for i = 1, capacity do
		WorkerService:EnableCrate(player, i)
	end

	WorkerService:ScaleBreaker(player, getScale())
end

function UpgradeService:UpdateBreakers(player: Player)
	WorkerService:ChangeWorker(player)

	player:SetAttribute("CHANGE_BREAKER", true)

	local crateBreaker = PlayerDataHandler:Get(player, "crateBreaker")
	local equipedBreaker = crateBreaker.Equiped

	local breakerPowerBost = Breakers[equipedBreaker].Boosts.Power
	local breakerSpeedBost = Breakers[equipedBreaker].Boosts.Speed

	player:SetAttribute("Power", (crateBreaker.Power * 10) + breakerPowerBost)
	player:SetAttribute("Speed", crateBreaker.Speed + breakerSpeedBost)
end

return UpgradeService
