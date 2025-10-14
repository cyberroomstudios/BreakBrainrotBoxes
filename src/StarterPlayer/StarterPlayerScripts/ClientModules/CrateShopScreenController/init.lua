local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)

local CrateShopScreenController = {}

local screen
local restockTime

function CrateShopScreenController:Init()
	CrateShopScreenController:CreateReferences()
	CrateShopScreenController:ConfigureProximityPrompt()
	CrateShopScreenController:InitAttributeListener()
end

function CrateShopScreenController:CreateReferences()
	screen = UIReferences:GetReference("CRATE_SHOP_SCREEN")
	restockTime = UIReferences:GetReference("CRATE_SHOP_RESTOCK_TIME")
end

function CrateShopScreenController:ConfigureProximityPrompt()
	local proximityPart = ClientUtil:WaitForDescendants(workspace, "Map", "Booths", "Shop", "ProximityPromptPart")

	local proximityPrompt = proximityPart.ProximityPrompt

	proximityPrompt.PromptShown:Connect(function()
		screen.Visible = true
	end)

	proximityPrompt.PromptHidden:Connect(function()
		screen.Visible = false
	end)
end

function CrateShopScreenController:InitAttributeListener()
	Workspace:GetAttributeChangedSignal("CURRENT_TIME_STOCK"):Connect(function()
		local currentTimeStock = workspace:GetAttribute("CURRENT_TIME_STOCK")
		restockTime.Text = "Restock In: " .. ClientUtil:FormatSecondsToMinutes(currentTimeStock)
	end)
end
return CrateShopScreenController
