local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseService = require(ServerScriptService.Modules.BaseService)
local Brainrots = require(ReplicatedStorage.Enums.Brainrots)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local ToolService = require(ServerScriptService.Modules.ToolService)

local BrainrotService = {}

function BrainrotService:Init() end

function BrainrotService:SaveBrainrotInMap(player: Player, brainrotName: string, slotNumber: number)
	local data = {
		BrainrotName = brainrotName,
		SlotNumber = slotNumber,
	}

	PlayerDataHandler:Update(player, "brainrotsMap", function(current)
		table.insert(current, data)
		return current
	end)
end

function BrainrotService:SaveBrainrotInBackpack(player: Player, brainrotName: string, slotNumber: number)
	local data = {
		BrainrotName = brainrotName,
		Id = PlayerDataHandler:Get(player, "brainrotsBackpackId"),
	}

	PlayerDataHandler:Update(player, "brainrotsBackpack", function(current)
		table.insert(current, data)
		return current
	end)

	PlayerDataHandler:Set(player, "brainrotsBackpackId", data.Id + 1)
	ToolService:GiveBrainrotTool(player, brainrotName)
end

function BrainrotService:InitBrainrotInMap(player: Player)
	local PlotService = require(ServerScriptService.Modules.PlotService)

	for _, value in PlayerDataHandler:Get(player, "brainrotsMap") do
		local brainrotName = value.BrainrotName
		local slotNumber = value.SlotNumber
		PlotService:SetWithPlotNumber(player, slotNumber, brainrotName)
	end
end

function BrainrotService:InitBrainrotInBackpack(player: Player)
	for _, value in PlayerDataHandler:Get(player, "brainrotsBackpack") do
		ToolService:GiveBrainrotTool(player, value.BrainrotName)
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

function BrainrotService:DrawBrainrotFromRarity(rarityType: string)
	local function chooseCategory(oddsTable)
		-- Soma total das probabilidades
		local total = 0
		for _, chance in pairs(oddsTable) do
			total += chance
		end

		-- Número aleatório entre 0 e total
		local randomValue = math.random()
		local cumulative = 0

		for item, chance in pairs(oddsTable) do
			cumulative += chance / total -- normaliza
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

return BrainrotService
