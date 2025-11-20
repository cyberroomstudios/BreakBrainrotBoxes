local StartGameController = {}
-- Init Bridg Net
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("StartGameService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local player = Players.LocalPlayer
local WorkerController = require(Players.LocalPlayer.PlayerScripts.ClientModules.WorkerController)
local PlotController = require(Players.LocalPlayer.PlayerScripts.ClientModules.PlotController)
local UpgradeController = require(Players.LocalPlayer.PlayerScripts.ClientModules.UpgradeController)
local OfflineMoneyController = require(Players.LocalPlayer.PlayerScripts.ClientModules.OfflineMoneyController)
local TeleportController = require(Players.LocalPlayer.PlayerScripts.ClientModules.TeleportController)
local SoundManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.SoundManager)
local FTUEController = require(Players.LocalPlayer.PlayerScripts.ClientModules.FTUEController)

function StartGameController:Init(data)
	local result = bridge:InvokeServerAsync({
		[actionIdentifier] = "Start",
		data = {},
	})
	TeleportController:ToBase(false)
	StartGameController:DeleteLoadingScreen()

	WorkerController:InitProximityPrompt()
	UpgradeController:ConfigureProximityPrompt()
	PlotController:StartTouchGetMoney()
	PlotController:ConfigureInsertItemProximityPrompt()
	OfflineMoneyController:Open()
	PlotController:ConfigureGamepasses()
	PlotController:DeleteCashMultiplier()
	PlotController:DeleteYourBaseIndicator()
	PlotController:UpdateCashMultiplier(player:GetAttribute("CASH_MULTIPLIER") or 1)
	PlotController:DeleteWaitingForCrate()
	SoundManager:StartOrPauseBGM()
	PlotController:ConfigureClaimeProximity()
	FTUEController:StartFTUE(data)
end

function StartGameController:DeleteLoadingScreen()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	local loadingScreen = playerGui:WaitForChild("LoadingScreen")
	loadingScreen:Destroy()
end
return StartGameController
