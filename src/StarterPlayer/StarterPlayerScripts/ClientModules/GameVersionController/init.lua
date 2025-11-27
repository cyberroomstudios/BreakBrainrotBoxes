local GameVersionController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("GameVersion")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local gameVersionTextLabel

function GameVersionController:Init()
	GameVersionController:CreateReferences()
	GameVersionController:SetVersion()
end

function GameVersionController:CreateReferences()
	local ClientModulesFolder = script.Parent
	local StarterPlayerScripts = ClientModulesFolder.Parent
	local UIReferences = require(StarterPlayerScripts.Util.UIReferences)

	gameVersionTextLabel = UIReferences:GetReference("GAME_VERSION")
end

function GameVersionController:SetVersion()
	local result = bridge:InvokeServerAsync({
		[actionIdentifier] = "GetVersion",
	})

	gameVersionTextLabel.Text = "Version: " .. result
end

return GameVersionController
