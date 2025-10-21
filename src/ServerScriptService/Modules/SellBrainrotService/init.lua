local SellBrainrotService = {}

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local MoneyService = require(ServerScriptService.Modules.MoneyService)
local Brainrots = require(ReplicatedStorage.Enums.Brainrots)
local ToolService = require(ServerScriptService.Modules.ToolService)
local bridge = BridgeNet2.ReferenceBridge("SellService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

function SellBrainrotService:Init()
	SellBrainrotService:InitBridgeListener()
end

function SellBrainrotService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "Get" then
			return SellBrainrotService:Get(player)
		end

		if data[actionIdentifier] == "SellAll" then
			return SellBrainrotService:SellAll(player)
		end

		if data[actionIdentifier] == "SellThis" then
			local id = data.Data.Id
			SellBrainrotService:SellThis(player, id)
			return true
		end
	end
end

function SellBrainrotService:SellAll(player: Player)
	local totalMoney = 0

	local brainrots = PlayerDataHandler:Get(player, "brainrotsBackpack")

	for _, value in brainrots do
		local sellPrice = Brainrots[value.BrainrotName].SellPrice
		totalMoney = totalMoney + sellPrice
		ToolService:ConsumeBrainrotTool(player, value.BrainrotName)
	end
	MoneyService:GiveMoney(player, totalMoney)
	PlayerDataHandler:Set(player, "brainrotsBackpack", {})
	return {}
end

function SellBrainrotService:SellThis(player: Player, brainrotId: number)
	PlayerDataHandler:Update(player, "brainrotsBackpack", function(current)
		local newCurrent = {}

		for _, value in current do
			if value.Id == brainrotId then
				local sellPrice = Brainrots[value.BrainrotName].SellPrice

				MoneyService:GiveMoney(player, sellPrice)
				ToolService:ConsumeBrainrotTool(player, value.BrainrotName)

				continue
			end

			table.insert(newCurrent, value)
		end

		return newCurrent
	end)

	return true
end

function SellBrainrotService:Get(player: Player)
	local dataList = {}
	local brainrots = PlayerDataHandler:Get(player, "brainrotsBackpack")

	for _, value in brainrots do
		local id = value.Id
		local sellPrice = Brainrots[value.BrainrotName].SellPrice

		local data = {
			Id = id,
			Price = sellPrice,
			Name = value.BrainrotName,
		}

		table.insert(dataList, data)
	end

	return dataList
end

return SellBrainrotService
