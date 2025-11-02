local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local TeleportController = require(Players.LocalPlayer.PlayerScripts.ClientModules.TeleportController)
local RebirthController = require(Players.LocalPlayer.PlayerScripts.ClientModules.RebirthController)
local UIStateManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.UIStateManager)

local HudController = {}

local myBaseButton
local crateShopButton
local upgradeShopButton

-- Botões lateral
local rebirthButton
local indexButton

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
	rebirthButton = UIReferences:GetReference("REBIRTH_HUD")
	indexButton = UIReferences:GetReference("INDEX_HUD")
	yourLuckText = UIReferences:GetReference("YOUR_LUCK")
	checkLuck = UIReferences:GetReference("CHECK_LUCK")
	infoLuck = UIReferences:GetReference("INFO_LUCK")
end

function HudController:UpdadeLabelLuck(luck: number)
	yourLuckText.Text = "Your Luck x" .. luck
end

function HudController:InitButtonListerns()
	myBaseButton.MouseButton1Click:Connect(function()
		TeleportController:ToBase()
	end)

	crateShopButton.MouseButton1Click:Connect(function()
		TeleportController:ToCrateStore()
	end)

	upgradeShopButton.MouseButton1Click:Connect(function()
		TeleportController:ToUpgradeShop()
	end)

	rebirthButton.MouseButton1Click:Connect(function()
		RebirthController:Show()
	end)

	indexButton.MouseButton1Click:Connect(function()
		UIStateManager:Open("INDEX")
	end)

	checkLuck.MouseEnter:Connect(function()
		infoLuck.Visible = true
	end)

	checkLuck.MouseLeave:Connect(function()
		infoLuck.Visible = false
	end)
end

return HudController
