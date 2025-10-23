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

local Upgrades = require(ReplicatedStorage.Enums.Upgrades)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)
local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local UIStateManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.UIStateManager)

local screen
local buyPowerButton
local buySpeedButton
local buyCapacityButton

-- Power
local currentPower
local nextPower
local maximumReachedPower
local numberInformationPower
local buyPowerFrame

-- Speed
local currentSpeed
local nextSpeed
local maximumReachedSpeed
local numberInformationSpeed
local buySpeedFrame

-- Capacity
local currentCapacity
local nextCapacity
local maximumReachedCapacity
local numberInformationCapacity
local buyCapacityFrame

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
	maximumReachedPower = UIReferences:GetReference("MAXIMUM_REACHED_POWER")
	numberInformationPower = UIReferences:GetReference("NUMBER_INFORMATION_POWER")
	buyPowerFrame = UIReferences:GetReference("BUY_POWER_FRAME")

	currentSpeed = UIReferences:GetReference("CURRENT_SPEED")
	nextSpeed = UIReferences:GetReference("NEXT_SPEED")
	maximumReachedSpeed = UIReferences:GetReference("MAXIMUM_REACHED_SPEED")
	numberInformationSpeed = UIReferences:GetReference("NUMBER_INFORMATION_SPEED")
	buySpeedFrame = UIReferences:GetReference("BUY_SPEED_FRAME")

	currentCapacity = UIReferences:GetReference("CURRENT_CAPACITY")
	nextCapacity = UIReferences:GetReference("NEXT_CAPACITY")
	maximumReachedCapacity = UIReferences:GetReference("MAXIMUM_REACHED_CAPACITY")
	numberInformationCapacity = UIReferences:GetReference("NUMBER_INFORMATION_CAPACITY")
	buyCapacityFrame = UIReferences:GetReference("BUY_CAPACITY_FRAME")
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
	local item = Upgrades["Power"][value + 1]

	if not item then
		maximumReachedPower.Visible = true
		numberInformationPower.Visible = false
		buyPowerFrame.Visible = false
		return
	end
	currentPower.Text = value
	nextPower.Text = value + 1
	buyPowerFrame.TextLabel.Text = ClientUtil:FormatToUSD(item)
end

function UpgradesController:UpdateSpeedText(value: number)
	local item = Upgrades["Speed"][value + 1]

	if not item then
		maximumReachedSpeed.Visible = true
		numberInformationSpeed.Visible = false
		buySpeedFrame.Visible = false
		return
	end

	currentSpeed.Text = value
	nextSpeed.Text = value + 1
	buySpeedFrame.TextLabel.Text = ClientUtil:FormatToUSD(item)
end

function UpgradesController:UpdateCapacityText(value: number)
	local item = Upgrades["Capacity"][value + 1]

	if not item then
		maximumReachedCapacity.Visible = true
		numberInformationCapacity.Visible = false
		buyCapacityFrame.Visible = false
		return
	end
	currentCapacity.Text = value
	nextCapacity.Text = value + 1
	buyCapacityFrame.TextLabel.Text = ClientUtil:FormatToUSD(item)
end

function UpgradesController:ConfigureProximityPrompt()
	local proximityPart = ClientUtil:WaitForDescendants(workspace, "Map", "Upgrade", "ProximityPromptPart")

	local proximityPrompt = proximityPart.ProximityPrompt

	proximityPrompt.PromptShown:Connect(function()
		UIStateManager:Open("UPGRADES")
	end)

	proximityPrompt.PromptHidden:Connect(function()
		UIStateManager:Close("UPGRADES")
	end)
end

function UpgradesController:Open()
	screen.Visible = true
end

function UpgradesController:Close()
	screen.Visible = false
end

function UpgradesController:GetScreen()
	return screen
end

return UpgradesController
