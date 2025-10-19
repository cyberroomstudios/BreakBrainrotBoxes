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

local WorkerController = require(Players.LocalPlayer.PlayerScripts.ClientModules.WorkerController)
local PlotController = require(Players.LocalPlayer.PlayerScripts.ClientModules.PlotController)
local UpgradeController = require(Players.LocalPlayer.PlayerScripts.ClientModules.UpgradeController)


function StartGameController:Init(data)
	local result = bridge:InvokeServerAsync({
		[actionIdentifier] = "Start",
		data = {},
	})

	WorkerController:InitProximityPrompt()
	UpgradeController:ConfigureProximityPrompt()
	PlotController:StartTouchGetMoney()
end

return StartGameController
