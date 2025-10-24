local IndexController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("IndexService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)

local screen

function IndexController:Init()
	IndexController:CreateReferences()
end

function IndexController:CreateReferences()
	screen = UIReferences:GetReference("INDEX")
end

function IndexController:Open()
	screen.Visible = true
	local result = bridge:InvokeServerAsync({
		[actionIdentifier] = "GetCommonIndex",
	})

	IndexController:BuildScreen(result)
end

function IndexController:Close()
	screen.Visible = false
end

function IndexController:GetScreen()
	return screen
end

function IndexController:BuildScreen(commonItems) end

return IndexController
