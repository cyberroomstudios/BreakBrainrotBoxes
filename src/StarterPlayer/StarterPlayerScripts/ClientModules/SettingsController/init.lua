local SettingsController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("SettingsService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local SoundManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.SoundManager)

local screen

local backgroundMusicButtons = {}
local soundEffectButtons = {}
local acceptGift = {}

local settingsFrame
local updateLogFrame

local settingsButton
local updateLogButton

function SettingsController:Init(data)
	SettingsController:CreateReferences()
	SettingsController:InitButtonListerns()
	SettingsController:ConfigureView(data)
	SettingsController:InitAttributeListener()
end

function SettingsController:CreateReferences()
	screen = UIReferences:GetReference("SETTINGS")
	backgroundMusicButtons[true] = UIReferences:GetReference("BACKGROUND_MUSIC_ON")
	backgroundMusicButtons[false] = UIReferences:GetReference("BACKGROUND_MUSIC_OFF")

	soundEffectButtons[true] = UIReferences:GetReference("SOUND_EFFECT_ON")
	soundEffectButtons[false] = UIReferences:GetReference("SOUND_EFFECT_OFF")

	acceptGift[true] = UIReferences:GetReference("ACCEPT_GIFT_ON")
	acceptGift[false] = UIReferences:GetReference("ACCEPT_GIFT_OFF")

	settingsFrame = UIReferences:GetReference("SETTINGS_FRAME")
	updateLogFrame = UIReferences:GetReference("UPDATE_LOG_FRAME")

	settingsButton = UIReferences:GetReference("SETTINGS_BUTTON")
	updateLogButton = UIReferences:GetReference("UPDATE_LOG_BUTTON")
end

function SettingsController:ConfigureView(data)
	local gameSettings = data.gameSettings

	backgroundMusicButtons[true].Visible = gameSettings.backgroundMusic
	backgroundMusicButtons[false].Visible = not backgroundMusicButtons[true].Visible

	soundEffectButtons[true].Visible = gameSettings.soundEffect
	soundEffectButtons[false].Visible = not soundEffectButtons[true].Visible

	acceptGift[true].Visible = gameSettings.acceptGift
	acceptGift[false].Visible = not acceptGift[true].Visible
end

function SettingsController:InitAttributeListener()
	player:GetAttributeChangedSignal("SETTINGS_BACKGROUND_MUSIC"):Connect(function()
		SoundManager:StartOrPauseBGM()
	end)
end

function SettingsController:InitButtonListerns()
	local function configureAcceptGift()
		acceptGift[true].Button.MouseButton1Click:Connect(function()
			acceptGift[true].Visible = false
			acceptGift[false].Visible = true

			local result = bridge:InvokeServerAsync({
				[actionIdentifier] = "ToggleAcceptGift",
			})
		end)

		acceptGift[false].Button.MouseButton1Click:Connect(function()
			acceptGift[true].Visible = true
			acceptGift[false].Visible = false

			local result = bridge:InvokeServerAsync({
				[actionIdentifier] = "ToggleAcceptGift",
			})
		end)
	end

	local function configureBackgroudButtons()
		backgroundMusicButtons[true].Button.MouseButton1Click:Connect(function()
			backgroundMusicButtons[true].Visible = false
			backgroundMusicButtons[false].Visible = true

			local result = bridge:InvokeServerAsync({
				[actionIdentifier] = "ToggleBackgroundMusic",
			})
		end)

		backgroundMusicButtons[false].Button.MouseButton1Click:Connect(function()
			backgroundMusicButtons[true].Visible = true
			backgroundMusicButtons[false].Visible = false

			local result = bridge:InvokeServerAsync({
				[actionIdentifier] = "ToggleBackgroundMusic",
			})
		end)
	end

	local function configureSoundEffectButtons()
		soundEffectButtons[true].Button.MouseButton1Click:Connect(function()
			soundEffectButtons[true].Visible = false
			soundEffectButtons[false].Visible = true

			local result = bridge:InvokeServerAsync({
				[actionIdentifier] = "ToggleSoundEffect",
			})
		end)

		soundEffectButtons[false].Button.MouseButton1Click:Connect(function()
			soundEffectButtons[true].Visible = true
			soundEffectButtons[false].Visible = false

			local result = bridge:InvokeServerAsync({
				[actionIdentifier] = "ToggleSoundEffect",
			})
		end)
	end

	local function configureButtons()
		settingsButton.MouseButton1Click:Connect(function()
			settingsFrame.Visible = true
			updateLogFrame.Visible = false
		end)

		updateLogButton.MouseButton1Click:Connect(function()
			settingsFrame.Visible = false
			updateLogFrame.Visible = true
		end)
	end

	configureButtons()
	configureBackgroudButtons()
	configureSoundEffectButtons()
	configureAcceptGift()
end

function SettingsController:Open(data)
	screen.Visible = true
end

function SettingsController:Close()
	screen.Visible = false
end

function SettingsController:GetScreen()
	return screen
end

return SettingsController
