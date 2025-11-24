local RebirthController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("RebirthService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local Rebirths = require(ReplicatedStorage.Enums.Rebirths)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)

local screen

function RebirthController:Init()
	RebirthController:CreateReferences()
end

function RebirthController:CreateReferences()
	screen = UIReferences:GetReference("REBIRTH")
end

function RebirthController:Open(data)
	screen.Visible = true
end

function RebirthController:Close()
	screen.Visible = false
end

function RebirthController:GetScreen()
	return screen
end

return RebirthController
