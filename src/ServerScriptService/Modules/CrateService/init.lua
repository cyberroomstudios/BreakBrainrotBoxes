local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Crate = require(ReplicatedStorage.Enums.Crate)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local ToolService = require(ServerScriptService.Modules.ToolService)
local BrainrotService = require(ServerScriptService.Modules.BrainrotService)

local CrateService = {}

function CrateService:Init() end

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

function CrateService:DrawBrainrotFromCrate(crateType: string)
	local function chooseCategory(oddsTable)
		-- Soma total das probabilidades
		local total = 0
		for _, chance in pairs(oddsTable) do
			total += chance
		end

		-- Número aleatório entre 0 e total
		local randomValue = math.random()
		local cumulative = 0

		for category, chance in pairs(oddsTable) do
			cumulative += chance / total -- normaliza
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
			local raritiestypes = {}

			for categoryName, categoryOdd in cratesCategoryOdds do
				if categoryOdd > 0 then
					raritiestypes[categoryName] = categoryOdd
				end
			end

			local rarity = chooseCategory(raritiestypes)

			return BrainrotService:DrawBrainrotFromRarity(rarity)
		end
	end
end

return CrateService
