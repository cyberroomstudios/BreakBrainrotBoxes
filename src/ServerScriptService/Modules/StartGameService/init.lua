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
local ThreadService = require(ServerScriptService.Modules.ThreadService)
local UpgradeService = require(ServerScriptService.Modules.UpgradeService)
local RebirthService = require(ServerScriptService.Modules.RebirthService)
local WorkerService = require(ServerScriptService.Modules.WorkerService)
local OfflineMoneyService = require(ServerScriptService.Modules.OfflineMoneyService)

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
			BrainrotService:InitBrainrotInMap(player)
			BrainrotService:InitBrainrotInBackpack(player)
			ThreadService:StartFromPlayer(player)
			UpgradeService:InitPlayerUpgrade(player)
			RebirthService:InitRebirth(player)
			WorkerService:StartCratesFromOffline(player)
			OfflineMoneyService:StartOfflineMoney(player)
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
