local StartGameService = {}

-- Init Bridg Net
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("StartGameService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local BaseService = require(ServerScriptService.Modules.BaseService)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local BackpackService = require(ServerScriptService.Modules.BackpackService)
local BrainrotService = require(ServerScriptService.Modules.BrainrotService)
local PlotService = require(ServerScriptService.Modules.PlotService)

local playerInitializer = {}

function StartGameService:Init()
	StartGameService:InitBridgeListener()

	Players.PlayerRemoving:Connect(function(player)
		playerInitializer[player] = nil
	end)
end

function StartGameService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "Start" then
			-- Segurança para evitar que seja inicializado mais de uma vez
			if playerInitializer[player] then
				return false
			end

			playerInitializer[player] = true
			StartGameService:CreatePlayerFolder(player)

			BaseService:Allocate(player)
			BackpackService:GiveFromInit(player)
			StartGameService:InitPlayerAttributes(player)

			--PlotService:SetWithPlotNumber(player, 1, "CocofantoElefanto")
			--PlotService:SetWithPlotNumber(player, 2, "Fluriflura")
			--PlotService:SetWithPlotNumber(player, 3, "FrigoCamelo")
			--PlotService:SetWithPlotNumber(player, 4, "GangsterFootera")
			--PlotService:SetWithPlotNumber(player, 5, "GlorboFruttodrillo")
			--PlotService:SetWithPlotNumber(player, 6, "LaVaccaSaturnoSaturnita")
			--PlotService:SetWithPlotNumber(player, 7, "LirilìLarilà")
			--PlotService:SetWithPlotNumber(player, 8, "OdinDinDinDun")

			PlotService:SetWithPlotNumber(player, 1, "BananitaDolphinita")
			PlotService:SetWithPlotNumber(player, 2, "BanditoBobritto")
			PlotService:SetWithPlotNumber(player, 3, "BombardiroCrocodilo")
			PlotService:SetWithPlotNumber(player, 4, "SpioniroGolubiro")
			PlotService:SetWithPlotNumber(player, 5, "BombombiniGusini")
			PlotService:SetWithPlotNumber(player, 6, "SvininaBombardino")
			PlotService:SetWithPlotNumber(player, 7, "TaTaTaSahur")
			PlotService:SetWithPlotNumber(player, 8, "BonecaAmbalabu")
			PlotService:SetWithPlotNumber(player, 9, "BrrBrrPatapim")
			PlotService:SetWithPlotNumber(player, 10, "BubarolliLuliloli")
			PlotService:SetWithPlotNumber(player, 11, "CactoHipopotamo")
			PlotService:SetWithPlotNumber(player, 12, "TimCheese")
			PlotService:SetWithPlotNumber(player, 13, "TralaleroTralala")
			PlotService:SetWithPlotNumber(player, 14, "CappuccinoAssassino")
			PlotService:SetWithPlotNumber(player, 15, "CavalloVirtuoso")
			PlotService:SetWithPlotNumber(player, 16, "ChefCrabracadabra")
			PlotService:SetWithPlotNumber(player, 17, "TrippiTroppi")
			PlotService:SetWithPlotNumber(player, 18, "TrulimeroTrulicina")
			PlotService:SetWithPlotNumber(player, 19, "TungTungSahur")
			PlotService:SetWithPlotNumber(player, 20, "ChimpanziniBananini")
		end
	end
end

function StartGameService:InitPlayerAttributes(player: Player)
	local money = PlayerDataHandler:Get(player, "money")
	player:SetAttribute("MONEY", money)
end

function StartGameService:CreatePlayerFolder(player: Player)
	local playerFolder = Instance.new("Folder")
	playerFolder.Name = player.UserId
	playerFolder.Parent = workspace.Runtime

	local crateFolder = Instance.new("Folder")
	crateFolder.Name = "Crates"
	crateFolder.Parent = playerFolder

	local brainrotsFolder = Instance.new("Folder")
	brainrotsFolder.Name = "Brainrots"
	brainrotsFolder.Parent = playerFolder

	local BrainrotsFromCrateFolder = Instance.new("Folder")
	BrainrotsFromCrateFolder.Name = "BrainrotsFromCrate"
	BrainrotsFromCrateFolder.Parent = playerFolder
end

return StartGameService
