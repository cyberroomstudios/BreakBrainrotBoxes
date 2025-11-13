local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)

local RobuxShopController = {}

local screen

function RobuxShopController:Init()
	RobuxShopController:CreateReferences()
end

function RobuxShopController:CreateReferences()
	screen = UIReferences:GetReference("ROBUX_SHOP")
end

function RobuxShopController:Open(data)
	screen.Visible = true
end

function RobuxShopController:Close()
	screen.Visible = false
end

function RobuxShopController:GetScreen()
	return screen
end

return RobuxShopController
