local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseService = require(ServerScriptService.Modules.BaseService)
local Brainrots = require(ReplicatedStorage.Enums.Brainrots)

local BrainrotService = {}

function BrainrotService:Init() end

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

return BrainrotService
