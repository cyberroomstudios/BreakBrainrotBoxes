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

function StartGameController:Init(data)
	local result = bridge:InvokeServerAsync({
		[actionIdentifier] = "Start",
		data = {},
	})

	WorkerController:InitProximityPrompt()
	UpgradeController:ConfigureProximityPrompt()
	PlotController:StartTouchGetMoney()
	PlotController:ConfigureInsertItemProximityPrompt()
	OfflineMoneyController:Open()
	PlotController:ConfigureGamepasses()
	PlotController:DeleteCashMultiplier()
	PlotController:UpdateCashMultiplier(player:GetAttribute("CASH_MULTIPLIER") or 1)
	TeleportController:ToBase()
end

return StartGameController
