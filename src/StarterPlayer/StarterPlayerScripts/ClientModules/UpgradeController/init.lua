local UpgradesController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("UpgradeService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local Players = game:GetService("Players")

local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)
local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)

local screen
local buyPowerButton
local buySpeedButton
local buyCapacityButton

-- Power
local currentPower
local nextPower

-- Speed
local currentSpeed
local nextSpeed

-- Capacity
local currentCapacity
local nextCapacity

function UpgradesController:Init(data)
	UpgradesController:CreateReferences()
	UpgradesController:InitButtonListerns()
	UpgradesController:FillScreen(data)
end

function UpgradesController:FillScreen(data)
	local crateBreaker = data.crateBreaker
	UpgradesController:UpdatePowerText(crateBreaker.Power)
	UpgradesController:UpdateSpeedText(crateBreaker.Speed)
	UpgradesController:UpdateCapacityText(crateBreaker.Capacity)
end

function UpgradesController:CreateReferences()
	screen = UIReferences:GetReference("UPGRADES_SCREEN")
	buyPowerButton = UIReferences:GetReference("BUY_POWER")
	buySpeedButton = UIReferences:GetReference("BUY_SPEED")
	buyCapacityButton = UIReferences:GetReference("BUY_CAPACITY")

	currentPower = UIReferences:GetReference("CURRENT_POWER")
	nextPower = UIReferences:GetReference("NEXT_POWER")

	currentSpeed = UIReferences:GetReference("CURRENT_SPEED")
	nextSpeed = UIReferences:GetReference("NEXT_SPEED")

	currentCapacity = UIReferences:GetReference("CURRENT_CAPACITY")
	nextCapacity = UIReferences:GetReference("NEXT_CAPACITY")
end

function UpgradesController:InitButtonListerns()
	buyPowerButton.MouseButton1Click:Connect(function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "BuyPower",
		})

		UpgradesController:UpdatePowerText(result)
	end)

	buySpeedButton.MouseButton1Click:Connect(function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "BuySpeed",
		})

		UpgradesController:UpdateSpeedText(result)
	end)

	buyCapacityButton.MouseButton1Click:Connect(function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "BuyCapacity",
		})

		UpgradesController:UpdateCapacityText(result)
	end)
end

function UpgradesController:UpdatePowerText(value: number)
	currentPower.Text = value
	nextPower.Text = value + 1
end

function UpgradesController:UpdateSpeedText(value: number)
	currentSpeed.Text = value
	nextSpeed.Text = value + 1
end

function UpgradesController:UpdateCapacityText(value: number)
	currentCapacity.Text = value
	nextCapacity.Text = value + 1
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
