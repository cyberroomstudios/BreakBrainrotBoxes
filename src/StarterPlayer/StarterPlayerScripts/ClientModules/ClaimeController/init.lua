local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)

local ClaimeController = {}

local screen

function ClaimeController:Init(data)
	ClaimeController:CreateReferences()
end

function ClaimeController:CreateReferences()
	screen = UIReferences:GetReference("CLAIME")
end

function ClaimeController:Open(data)
	screen.Visible = true
end

function ClaimeController:Close()
	screen.Visible = false
end

function ClaimeController:GetScreen()
	return screen
end

return ClaimeController
