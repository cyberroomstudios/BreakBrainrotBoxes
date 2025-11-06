local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseService = require(ServerScriptService.Modules.BaseService)
local Brainrots = require(ReplicatedStorage.Enums.Brainrots)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local ToolService = require(ServerScriptService.Modules.ToolService)
local LuckService = require(ServerScriptService.Modules.LuckService)

local BrainrotService = {}

function BrainrotService:Init() end

function BrainrotService:SaveBrainrotInMap(
	player: Player,
	brainrotName: string,
	mutationType: string,
	slotNumber: number
)
	local data = {
		BrainrotName = brainrotName,
		SlotNumber = slotNumber,
		MutationType = mutationType,
	}

	PlayerDataHandler:Update(player, "brainrotsMap", function(current)
		table.insert(current, data)
		return current
	end)
end

function BrainrotService:SaveBrainrotInBackpack(player: Player, brainrotName: string, mutationType: string)
	local data = {
		Id = PlayerDataHandler:Get(player, "brainrotsBackpackId"),
		BrainrotName = brainrotName,
		MutationType = mutationType,
	}

	PlayerDataHandler:Update(player, "brainrotsBackpack", function(current)
		table.insert(current, data)
		return current
	end)

	PlayerDataHandler:Set(player, "brainrotsBackpackId", data.Id + 1)
	ToolService:GiveBrainrotTool(player, data.Id, brainrotName, mutationType)
end

function BrainrotService:InitBrainrotInMap(player: Player)
	local PlotService = require(ServerScriptService.Modules.PlotService)

	for _, value in PlayerDataHandler:Get(player, "brainrotsMap") do
		local brainrotName = value.BrainrotName
		local slotNumber = value.SlotNumber
		local mutationType = value.MutationType
		PlotService:SetWithPlotNumber(player, slotNumber, brainrotName, mutationType)
	end
end

function BrainrotService:InitBrainrotInBackpack(player: Player)
	for _, value in PlayerDataHandler:Get(player, "brainrotsBackpack") do
		ToolService:GiveBrainrotTool(player,value.Id, value.BrainrotName, value.MutationType)
	end
end

function BrainrotService:GetBrainrotFromRarity(rarityType: string)
	local selectedBrainrots = {}

	for index, value in Brainrots do
		if value.Rarity == rarityType then
			selectedBrainrots[index] = value.Odd
		end
	end

	return selectedBrainrots
end

function BrainrotService:DrawBrainrotFromRarity(player: Player, rarityType: string)
	local luck = LuckService:GetLuckFromPlayer(player) or 1

	local function chooseCategory(oddsTable)
		-- Calcula o total ajustado com base na sorte
		local total = 0
		local adjustedChances = {}

		for item, chance in pairs(oddsTable) do
			-- Quanto maior o luck, mais a chance de itens raros aumenta
			local adjustedChance = chance ^ (1 / luck)
			adjustedChances[item] = adjustedChance
			total += adjustedChance
		end

		-- Gera um número aleatório proporcional ao total
		local randomValue = math.random() * total
		local cumulative = 0

		for item, adjustedChance in pairs(adjustedChances) do
			cumulative += adjustedChance
			if randomValue <= cumulative then
				return item
			end
		end
	end

	local brainrots = BrainrotService:GetBrainrotFromRarity(rarityType)
	return chooseCategory(brainrots)
end

function BrainrotService:RemoveBrainrotInMap(player: Player, name: string, plotNumber: string)
	PlayerDataHandler:Update(player, "brainrotsMap", function(current)
		local newCurrent = {}
		for _, value in current do
			if value.BrainrotName == name and value.SlotNumber == plotNumber then
				continue
			end
			table.insert(newCurrent, value)
		end
		return newCurrent
	end)
end

function BrainrotService:RemoveBrainrotInBackpack(player: Player, brainrotId: number)
	PlayerDataHandler:Update(player, "brainrotsBackpack", function(current)
		local newCurrent = {}
		for _, value in current do
			if value.Id == brainrotId then
				continue
			end
			table.insert(newCurrent, value)
		end
		return newCurrent
	end)
end

function BrainrotService:RemoveAll(player: Player)
	PlayerDataHandler:Set(player, "brainrotsMap", {})
end

function BrainrotService:ConsumeAllInHand(player: Player)
	PlayerDataHandler:Update(player, "brainrotsBackpack", function(current)
		return {}
	end)

	ToolService:ConsumeAllCrates(player, "BRAINROT")
end

return BrainrotService
