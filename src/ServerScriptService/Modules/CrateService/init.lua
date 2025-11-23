local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Crate = require(ReplicatedStorage.Enums.Crate)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local ToolService = require(ServerScriptService.Modules.ToolService)
local BrainrotService = require(ServerScriptService.Modules.BrainrotService)
local LuckService = require(ServerScriptService.Modules.LuckService)

local CrateService = {}

local mutationOdds = {
	["NORMAL"] = 0.97,
	["GOLDEN"] = 0.02,
	["DIAMOND"] = 0.01,
}
function CrateService:Init()
	math.randomseed(tick() * 10000 % 1 * 1e7)
end

function CrateService:Give(player: Player, crateName: string)
	if not Crate.CRATES[crateName] then
		warn("CRATE NOT FOUND: " .. crateName)
		return
	end

	PlayerDataHandler:Update(player, "cratesBackpack", function(current)
		if current[crateName] then
			current[crateName] = current[crateName] + 1
			return current
		end

		current[crateName] = 1
		return current
	end)

	ToolService:Give(player, "CRATE", crateName, 1)
end

function CrateService:Consume(player: Player, crateName: string)
	if not Crate.CRATES[crateName] then
		warn("CRATE NOT FOUND: " .. crateName)
		return
	end

	PlayerDataHandler:Update(player, "cratesBackpack", function(current)
		if current[crateName] > 0 then
			current[crateName] = current[crateName] - 1
		end

		return current
	end)
end

function CrateService:ConsumeAllInHand(player: Player)
	PlayerDataHandler:Update(player, "cratesBackpack", function(current)
		return {}
	end)

	ToolService:ConsumeAllCrates(player, "CRATE")
end

function CrateService:DrawBrainrotFromCrate(player: Player, crateType: string)
	local luck = LuckService:GetLuckFromPlayer(player) or 1

	local function chooseMutation()
		local adjustedChances = {}
		local total = 0

		-- Ajusta as chances das mutações pelo luck
		for rarity, chance in pairs(mutationOdds) do
			local adjustedChance = chance ^ (1 / luck)
			adjustedChances[rarity] = adjustedChance
			total += adjustedChance
		end

		-- Número aleatório proporcional ao total ajustado
		local randomValue = math.random() * total
		local cumulative = 0

		for rarity, adjustedChance in pairs(adjustedChances) do
			cumulative += adjustedChance
			if randomValue <= cumulative then
				return rarity
			end
		end

		-- Fallback
		return "COMMON"
	end

	local function chooseCategory(oddsTable)
		-- Ajusta as probabilidades com base na sorte
		local adjustedChances = {}
		local total = 0

		for category, chance in pairs(oddsTable) do
			-- Quanto maior o luck, mais as raridades menores são favorecidas
			local adjustedChance = chance ^ (1 / luck)
			adjustedChances[category] = adjustedChance
			total += adjustedChance
		end

		-- Número aleatório proporcional ao total ajustado
		local randomValue = math.random() * total
		local cumulative = 0

		for category, adjustedChance in pairs(adjustedChances) do
			cumulative += adjustedChance
			if randomValue <= cumulative then
				return category
			end
		end

		-- Caso algo dê errado
		return "COMMON"
	end

	local crateDef = Crate.CRATES[crateType]

	if crateType then
		-- Pega a definição de todas as raridades
		local crateRarity = crateDef.Rarity

		-- Pega a definição da raridade da caixa
		local rarityDef = Crate.RARITIES[crateRarity]

		if rarityDef then
			-- Pega as Odds da caixa
			local cratesCategoryOdds = rarityDef.CratesCategoryOdds

			-- Somente as raridades acima de 0
			local raritiesTypes = {}

			for categoryName, categoryOdd in pairs(cratesCategoryOdds) do
				if categoryOdd > 0 then
					raritiesTypes[categoryName] = categoryOdd
				end
			end

			local rarity = chooseCategory(raritiesTypes)
			local mutation = chooseMutation()

			return BrainrotService:DrawBrainrotFromRarity(player, rarity), mutation
		end
	end
end

return CrateService
