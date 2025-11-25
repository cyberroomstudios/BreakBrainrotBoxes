local HudController = {}

local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local TeleportController = require(Players.LocalPlayer.PlayerScripts.ClientModules.TeleportController)
local RebirthController = require(Players.LocalPlayer.PlayerScripts.ClientModules.RebirthController)
local MoneyController = require(Players.LocalPlayer.PlayerScripts.ClientModules.MoneyController)

local UIStateManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.UIStateManager)

local myBaseButton
local crateShopButton
local upgradeShopButton

-- Botões lateral
local robuxShopButton
local indexButton
local rebirthButton
local settingsButton

-- Botões da Esquerda
local autoCollectButton

-- Label
local yourLuckText
local checkLuck
local infoLuck

function HudController:Init(data)
	HudController:CreateReferences()
	HudController:InitButtonListerns()
	HudController:UpdadeLabelLuck(data.luck)
end

function HudController:CreateReferences()
	myBaseButton = UIReferences:GetReference("MY_BASE_BUTTON")
	crateShopButton = UIReferences:GetReference("CRATE_SHOP_BUTTON")
	upgradeShopButton = UIReferences:GetReference("UPGRADES_SHOP_BUTTON")
	robuxShopButton = UIReferences:GetReference("ROBUX_SHOP_HUD")
	rebirthButton = UIReferences:GetReference("REBIRTH_HUD")
	indexButton = UIReferences:GetReference("INDEX_HUD")
	yourLuckText = UIReferences:GetReference("YOUR_LUCK")
	checkLuck = UIReferences:GetReference("CHECK_LUCK")
	infoLuck = UIReferences:GetReference("INFO_LUCK")
	autoCollectButton = UIReferences:GetReference("AUTO_COLLECT")
	settingsButton = UIReferences:GetReference("SETTINGS_HUD")
end

function HudController:UpdadeLabelLuck(luck: number)
	yourLuckText.Text = "Your Luck x" .. luck
end

function HudController:InitButtonListerns()
	myBaseButton.MouseButton1Click:Connect(function()
		TeleportController:ToBase(true)
	end)

	crateShopButton.MouseButton1Click:Connect(function()
		TeleportController:ToCrateStore()
	end)

	upgradeShopButton.MouseButton1Click:Connect(function()
		
		TeleportController:ToUpgradeShop()
	end)

	robuxShopButton.MouseButton1Click:Connect(function()
		UIStateManager:Open("ROBUX_SHOP")
	end)

	rebirthButton.MouseButton1Click:Connect(function()
		UIStateManager:Open("REBIRTH")
	end)

	indexButton.MouseButton1Click:Connect(function()
		UIStateManager:Open("INDEX")
	end)

	autoCollectButton.MouseButton1Click:Connect(function()
		MoneyController:ToggleAutoCollect()
	end)

	settingsButton.MouseButton1Click:Connect(function()
		UIStateManager:Open("SETTINGS")
	end)
end

return HudController
