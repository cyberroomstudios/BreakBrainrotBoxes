local WorkerController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("WorkerService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local Players = game:GetService("Players")

local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)
local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)

local player = Players.LocalPlayer

local placeButtons
local placeAllButton
local placeThisButton

function WorkerController:Init()
	WorkerController:CreateReferences()
	WorkerController:InitButtonListerns()
end

function WorkerController:CreateReferences()
	placeButtons = UIReferences:GetReference("PLACE_BUTTONS")
	placeAllButton = UIReferences:GetReference("PLACE_ALL_BUTTON")
	placeThisButton = UIReferences:GetReference("PLACE_THIS_BUTTON")
end

function WorkerController:InitButtonListerns()
	placeAllButton.MouseButton1Click:Connect(function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "PlaceAll",
		})
	end)

	placeThisButton.MouseButton1Click:Connect(function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "PlaceThis",
		})
	end)
end

function WorkerController:InitProximityPrompt()
	local plot = ClientUtil:WaitForDescendants(workspace, "Map", "Plots", player:GetAttribute("BASE"))
	local proximyPart = ClientUtil:WaitForDescendants(plot, "Main", "BreakersArea", "ProximityPart")
	local proximity = ClientUtil:WaitForDescendants(proximyPart, "ProximityPrompt")

	proximity.PromptShown:Connect(function()
		placeButtons.Visible = true
	end)

	proximity.PromptHidden:Connect(function()
		placeButtons.Visible = false
	end)
end

return WorkerController
