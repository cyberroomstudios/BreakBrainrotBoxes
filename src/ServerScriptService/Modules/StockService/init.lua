local StockService = {}

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("StockService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local Crate = require(ReplicatedStorage.Enums.Crate)
local ToolService = require(ServerScriptService.Modules.ToolService)
local MoneyService = require(ServerScriptService.Modules.MoneyService)
local CrateService = require(ServerScriptService.Modules.CrateService)
local GameNotificationService = require(ServerScriptService.Modules.GameNotificationService)

local globalStock = {}
local playerStock = {}
local playerRestockIntention = {}

local TIME_TO_RESTOCK = 60 * 5
local currentTime = TIME_TO_RESTOCK
local stockUpdateIndex = 1

function StockService:Init()
	StockService:InitBridgeListener()
	StockService:Start()
end

function StockService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "GetStock" then
			return StockService:GetStockFromPlayer(player)
		end

		if data[actionIdentifier] == "BuyItem" then
			return StockService:BuyItem(player, data.data.ItemName)
		end

		if data[actionIdentifier] == "AddRestockItention" then
			return StockService:AddRestockIntention(player, data.data.ItemName)
		end
	end
end

function StockService:Start()
	task.spawn(function()
		StockService:RestockAll()
		stockUpdateIndex = stockUpdateIndex + 1
		workspace:SetAttribute("STOCK_UPDATE_INDEX", stockUpdateIndex)

		while true do
			if currentTime <= 0 then
				
				StockService:RestockAll()
				stockUpdateIndex = stockUpdateIndex + 1
				workspace:SetAttribute("STOCK_UPDATE_INDEX", stockUpdateIndex)
				currentTime = TIME_TO_RESTOCK
				GameNotificationService:SendCrateStoreRestockedNotification()
			end

			currentTime = currentTime - 1
			workspace:SetAttribute("CURRENT_TIME_STOCK", currentTime)
			task.wait(1)
		end
	end)
end

function StockService:AddRestockIntention(player: Player, item: string)
	playerRestockIntention[player] = item
end

function StockService:RestockThis(player: Player)
	if not playerRestockIntention[player] then
		warn("RESTOCK INTENTION NOT FOUND FOR: " .. player.Name)
		return false
	end

	local stock = playerStock[player]
	local itemName = playerRestockIntention[player]
	local crateEnum = Crate.CRATES[itemName]
	local amount = math.random(crateEnum.Stock.Min, crateEnum.Stock.Max)
	local restockIndex = player:GetAttribute("RESTOCK_UPDATE_INDEX") or 0

	playerStock[player][itemName] = amount

	player:SetAttribute("RESTOCK_UPDATE_INDEX", restockIndex + 1)

	return true
end

function StockService:BuyRestockAll()
	currentTime = 0
end

function StockService:RestockAll()
	-- Verifica quais categoria vão sair

	local function drawAndGetRarities()
		local rarities = {}

		for rarityName, rarity in Crate.RARITIES do
			local odd = rarity.Odd * 100
			local randomNumber = math.random(1, 100)

			if randomNumber <= odd then
				table.insert(rarities, rarityName)
			end
		end
		return rarities
	end

	local function getCrateFromRarity(rarityName: string)
		local crates = {}
		for name, value in Crate.CRATES do
			if value.Rarity == rarityName then
				table.insert(crates, value)
			end
		end

		return crates
	end

	--
	local drawnCrates = {}

	-- Obtem todas as raridades sorteadas
	local rarities = drawAndGetRarities()

	for _, rarity in rarities do
		-- Obtem todas as caixas daquela raridade
		local crates = getCrateFromRarity(rarity)

		for _, crate in crates do
			-- Verifica se vai ser sorteada
			local odd = crate.Odd * 100
			local randomNumber = math.random(1, 100)

			if randomNumber <= odd then
				-- Sorteia a quantidade
				local amount = math.random(crate.Stock.Min, crate.Stock.Max)
				drawnCrates[crate.Name] = amount
			end
		end
	end

	-- Reinicializa o stock Global
	globalStock = {}

	-- Reinicializa o stock individual
	playerStock = {}
	globalStock = drawnCrates
end

function StockService:GetStockFromPlayer(player: Player)
	if not playerStock[player] then
		playerStock[player] = globalStock
	end

	return playerStock[player]
end

function StockService:BuyItem(player: Player, itemName: string)
	local crateEnum = Crate.CRATES[itemName]

	-- Verifica se o Enum existe
	if not crateEnum then
		return
	end

	-- Verifica se tem informação de stock pro jogador
	if not playerStock[player] then
		return
	end

	-- Verifica se o jogador tem o item
	if not playerStock[player][itemName] then
		return
	end

	-- Verifica se tem stock
	if playerStock[player][itemName] == 0 then
		return
	end

	-- Verifica se o jogador tem dinheiro
	if not MoneyService:HasMoney(player, crateEnum.Price) then
		return
	end

	-- Consumindo o Stock
	playerStock[player][itemName] = playerStock[player][itemName] - 1
	MoneyService:ConsumeMoney(player, crateEnum.Price)
	CrateService:Give(player, itemName)

	return playerStock[player][itemName]
end

return StockService
