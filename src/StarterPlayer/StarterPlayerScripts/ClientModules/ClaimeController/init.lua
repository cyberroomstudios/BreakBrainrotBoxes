local ClaimeController = {}

local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("RewardService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local screen
local getReward

function ClaimeController:Init(data)
	ClaimeController:CreateReferences()
	ClaimeController:InitButtonListerns()
end

function ClaimeController:CreateReferences()
	screen = UIReferences:GetReference("CLAIME")
	getReward = UIReferences:GetReference("GET_GROUP_REWARD")
end

function ClaimeController:InitButtonListerns()
	local UIStateManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.UIStateManager)

	getReward.MouseButton1Click:Connect(function()
		UIStateManager:Close("CLAIME")
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "GetGroupReward",
			data = {},
		})
	end)
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
