local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)

local FTUEController = {}

local PADDING = 5 -- aumenta 10 pixels em cada lado

local myBaseButton
local crateShopButton
local upgradeShopButton

function FTUEController:Init()
	FTUEController:CreateReferences()
	FTUEController:FocusOnTarget(crateShopButton)
end

function FTUEController:CreateReferences()
	myBaseButton = UIReferences:GetReference("MY_BASE_BUTTON")
	crateShopButton = UIReferences:GetReference("CRATE_SHOP_BUTTON")
	upgradeShopButton = UIReferences:GetReference("UPGRADES_SHOP_BUTTON")
end

function FTUEController:FocusOnTarget(targetUI: GuiObject) end

return FTUEController
