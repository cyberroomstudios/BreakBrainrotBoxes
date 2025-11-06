local GameNotificationController = {}
-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("GameNotificationService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local UIStateManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.UIStateManager)

local notificationScreen
local notificationsTemplate

function GameNotificationController:Init()
	GameNotificationController:CreateReferences()
	GameNotificationController:InitListeners()
end

function GameNotificationController:CreateReferences()
	notificationScreen = UIReferences:GetReference("SYSTEM_NOTIFICATION")

	notificationsTemplate = {
		["WARN"] = ReplicatedStorage.GUI.Notifications.Warning,
		["ERROR"] = ReplicatedStorage.GUI.Notifications.Error,
		["SUCCESS"] = ReplicatedStorage.GUI.Notifications.Success,
	}
end

function GameNotificationController:InitListeners()
	bridge:Connect(function(response)
		if response[actionIdentifier] == "ShowWarnNotification" then
			GameNotificationController:ShowNotification("WARN", response.data.Message)
		end

		if response[actionIdentifier] == "ShowErrorNotification" then
			GameNotificationController:ShowNotification("ERROR", response.data.Message)
		end

		if response[actionIdentifier] == "ShowSuccessNotificaion" then
			GameNotificationController:ShowNotification("SUCCESS", response.data.Message)
		end

		if response[actionIdentifier] == "ShowNewBrainrotNotificaion" then
			GameNotificationController:ShowNewBrainrotNotification(response.data.BrainrotType)
		end
	end)
end

function GameNotificationController:ShowNewBrainrotNotification(brainrotType: string)
	local data = {
		BrainrotType = brainrotType,
	}
	UIStateManager:Open("NEW_GAME", data)
end

function GameNotificationController:ShowNotification(notificationType: string, message: string)
	if not notificationsTemplate[notificationType] then
		return
	end

	local template = notificationsTemplate[notificationType]:Clone()
	template.Text = message
	template.Parent = notificationScreen

	task.delay(1.5, function()
		template:Destroy()
	end)
end

return GameNotificationController
