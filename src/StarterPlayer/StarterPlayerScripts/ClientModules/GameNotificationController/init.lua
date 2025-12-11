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
local SoundManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.SoundManager)

local notificationScreen
local notificationsTemplate

local activeNotifications = {}

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
		["RESTOCKED"] = ReplicatedStorage.GUI.Notifications.Restocked,
	}
end

function GameNotificationController:InitListeners()
	bridge:Connect(function(response)
		if response[actionIdentifier] == "ShowWarnNotification" then
			GameNotificationController:ShowNotification("WARN", response.data.Message)
		end

		if response[actionIdentifier] == "ShowErrorNotification" then
			SoundManager:Play("NOTIFICATION_ERROR")
			GameNotificationController:ShowNotification("ERROR", response.data.Message)
		end

		if response[actionIdentifier] == "ShowSuccessNotificaion" then
			SoundManager:Play("NOTIFICATION_SUCCESS")
			GameNotificationController:ShowNotification("SUCCESS", response.data.Message)
		end

		if response[actionIdentifier] == "ShowNewBrainrotNotificaion" then
			SoundManager:Play("PARTY")
			GameNotificationController:ShowNewBrainrotNotification(
				response.data.MutationType,
				response.data.BrainrotType
			)
		end

		if response[actionIdentifier] == "ShowCrateStoreRestocked" then
			GameNotificationController:ShowNotification("RESTOCKED", "The Crate Store Has Been Restocked.")
		end
	end)
end

function GameNotificationController:ShowNewBrainrotNotification(mutationType: string, brainrotType: string)
	local data = {
		MutationType = mutationType,
		BrainrotType = brainrotType,
	}
	UIStateManager:Open("NEW_GAME", data)
end

function GameNotificationController:ShowNotification(notificationType: string, message: string)
	if not notificationsTemplate[notificationType] then
		return
	end

	-- Se a mesma mensagem já estiver ativa
	if activeNotifications[message] then
		local notif = activeNotifications[message]
		notif.count = notif.count + 1

		-- Atualizar texto com contador
		notif.gui.Text = string.format("%s (x%d)", message, notif.count)

		-- Reiniciar o timer
		notif.cancelDestroy() -- cancela o destroy anterior
		notif.cancelDestroy = self:_scheduleDestroy(notif.gui, message)

		return
	end

	-- Criar nova notificação
	local template = notificationsTemplate[notificationType]:Clone()
	template.Text = message
	template.Parent = notificationScreen

	-- Guardar como ativa
	activeNotifications[message] = {
		gui = template,
		count = 1,
		cancelDestroy = nil,
	}

	-- Agendar destruição
	activeNotifications[message].cancelDestroy = self:_scheduleDestroy(template, message)
end

-- Função auxiliar para remover com capacidade de cancelar
function GameNotificationController:_scheduleDestroy(guiObject, message)
	local alive = true

	task.delay(2, function()
		if alive then
			guiObject:Destroy()
			activeNotifications[message] = nil
		end
	end)

	-- Retorna função que cancela este destroy
	return function()
		alive = false
	end
end
return GameNotificationController
