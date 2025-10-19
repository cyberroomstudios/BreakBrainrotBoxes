local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local TeleportController = require(Players.LocalPlayer.PlayerScripts.ClientModules.TeleportController)

local HudController = {}

local myBaseButton
local crateShopButton
local upgradeShopButton

function HudController:Init()
	HudController:CreateReferences()
	HudController:InitButtonListerns()
end

function HudController:CreateReferences()
	myBaseButton = UIReferences:GetReference("MY_BASE_BUTTON")
	crateShopButton = UIReferences:GetReference("CRATE_SHOP_BUTTON")
	upgradeShopButton = UIReferences:GetReference("UPGRADES_SHOP_BUTTON")
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
end

return HudController
