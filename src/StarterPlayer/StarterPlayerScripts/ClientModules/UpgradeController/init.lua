local UpgradesController = {}

local Players = game:GetService("Players")

local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)
local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)

local screen

function UpgradesController:Init()
	UpgradesController:CreateReferences()
end

function UpgradesController:CreateReferences()
	screen = UIReferences:GetReference("UPGRADES_SCREEN")
end

function UpgradesController:ConfigureProximityPrompt()
	local proximityPart = ClientUtil:WaitForDescendants(workspace, "Map", "Upgrade", "ProximityPromptPart")

	local proximityPrompt = proximityPart.ProximityPrompt

	proximityPrompt.PromptShown:Connect(function()
		screen.Visible = true

		--CrateShopScreenController:BuildScreen(result)
	end)

	proximityPrompt.PromptHidden:Connect(function()
		screen.Visible = false
	end)
end

return UpgradesController
