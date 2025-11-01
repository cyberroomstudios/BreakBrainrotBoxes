local OfflineMoneyController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("OfflineService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net
local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)

local player = Players.LocalPlayer

local screen
local offlineAmount
local getMoneyButton

function OfflineMoneyController:Init()
	OfflineMoneyController:CreateReferences()
	OfflineMoneyController:InitButtonListerns()
end

function OfflineMoneyController:CreateReferences()
	screen = UIReferences:GetReference("OFFLINE")
	offlineAmount = UIReferences:GetReference("OFFLINE_AMOUNT")
	getMoneyButton = UIReferences:GetReference("GET_MONEY")
end

function OfflineMoneyController:Open()
	if player:GetAttribute("OFFLINE_MONEY") then
		offlineAmount.Text = ClientUtil:FormatToUSD(player:GetAttribute("OFFLINE_MONEY"))
		screen.Visible = true
	end
end

function OfflineMoneyController:InitButtonListerns()
	getMoneyButton.MouseButton1Click:Connect(function()
		screen.Visible = false

		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "GetOfflineMoney",
		})
	end)
end

return OfflineMoneyController
