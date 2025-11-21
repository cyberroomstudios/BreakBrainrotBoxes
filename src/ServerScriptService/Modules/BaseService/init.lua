local BaseService = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local UtilService = require(ServerScriptService.Modules.UtilService)

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("StartGameService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local positionYFloor = 26

local allocating = false

function BaseService:Init() end

function BaseService:Allocate(player: Player)
	while not workspace:GetAttribute("CONFIGURED_PLOTS") do
		task.wait(1)
	end

	if allocating then
		return false
	end
	allocating = true

	-- Obtem todas as places
	local places = workspace.Map.Plots:GetChildren()

	-- Embaralha a tabela
	for i = #places, 2, -1 do
		local j = math.random(i)
		places[i], places[j] = places[j], places[i]
	end

	-- Procura uma base não ocupada
	for _, place in ipairs(places) do
		if not place:GetAttribute("BUSY") then
			-- Inicializa os atributos da base
			place:SetAttribute("BUSY", true)
			place:SetAttribute("OWNER", player.UserId)

			player:SetAttribute("BASE", place.Name)
			player:SetAttribute("BASE_CFRAME", place.Spawn.CFrame)
			player:SetAttribute("BASE_LOOK_POSITION", place.Spawn.LookPart.Position)

			BaseService:CreateCrateShopCFrameAttribute(player)
			BaseService:CreateUpgradesCFrameAttribute(player)
			--	BaseService:MoveToBase(player, place.Spawn)

			break
		end
	end

	allocating = false

	return true
end

function BaseService:GetBase(player: Player)
	local places = workspace.Map.Plots:GetChildren()

	for _, value in places do
		if value.Name == player:GetAttribute("BASE") then
			return value
		end
	end
end

function BaseService:CreateCrateShopCFrameAttribute(player: Player)
	local crateAndSell = UtilService:WaitForDescendants(workspace, "Map", "Booths", "CrateAndSell")

	if crateAndSell then
		player:SetAttribute("CRATE_SHOP_CFRAME", crateAndSell.Spawn.CFrame)
		player:SetAttribute("CRATE_SHOP_LOOK_POSITION", crateAndSell.Spawn.LookPart.Position)
	end
end

function BaseService:CreateUpgradesCFrameAttribute(player: Player)
	local upgradeShops = UtilService:WaitForDescendants(workspace, "Map", "Booths", "Upgrades")

	if upgradeShops then
		player:SetAttribute("UPGRADE_SHOP_CFRAME", upgradeShops.Spawn.CFrame)
	end
end

function BaseService:CleanBase(player: Player)
	local function cleanInfoBase(base: Model)
		local main = base:WaitForChild("Main")
		-- Desligando o Your Base
		local yourBase = main:WaitForChild("YourBase"):WaitForChild("Attachment"):WaitForChild("BillboardGui")
		yourBase.Enabled = false

		-- Desligando o Waiting For Crate
		local waitingCrate = main:WaitForChild("BreakersArea"):WaitForChild("NextHit"):WaitForChild("Waiting")
		waitingCrate.Enabled = false

		-- Desligando o Cash Multiplier
		local cashMultiplier = main:WaitForChild("MultiplierZone"):WaitForChild("CashMultiplierBillboardGui")
		cashMultiplier.Enabled = false
	end

	local runtimeFolder = workspace.Runtime[player.UserId]
	if runtimeFolder then
		runtimeFolder:Destroy()
	end

	local base = BaseService:GetBase(player)

	local newBase = ReplicatedStorage.Model.Plot.PlotBase:Clone()
	newBase.Parent = base.Parent
	newBase.Name = base.Name
	newBase:SetPrimaryPartCFrame(base.PrimaryPart.CFrame)
	base:Destroy()

	task.spawn(function()
		cleanInfoBase(newBase)
	end)
end

function BaseService:UpdatePlotsFromNewPlayer(fromPlayer: Player)
	task.spawn(function()
		for _, player in Players:GetPlayers() do
			if player == fromPlayer then
				continue
			end

			bridge:Fire(player, {
				[actionIdentifier] = "UpdatePlotsFromNewPlayer",
			})
		end
	end)
end
return BaseService
