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
local requerimentsFrame
local rewardsFrame
local getRebirthButton
local infoCurrentRebirth

function RebirthController:Init()
	RebirthController:CreateReferences()
	RebirthController:InitButtonListerns()
end

function RebirthController:CreateReferences()
	screen = UIReferences:GetReference("REBIRTH")
	requerimentsFrame = UIReferences:GetReference("REQUERIMENTS_REBIRTH")
	rewardsFrame = UIReferences:GetReference("REWARDS_REBIRTH")
	getRebirthButton = UIReferences:GetReference("GET_REBIRTH")
	infoCurrentRebirth = UIReferences:GetReference("INFO_CURRENT_REBIRTH")
end

function RebirthController:Show()
	screen.Visible = not screen.Visible
	RebirthController:BuildScreen()
end

function RebirthController:InitButtonListerns()
	getRebirthButton.MouseButton1Click:Connect(function()
		screen.Visible = false

		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "GetRebirth",
		})
	end)
end

function RebirthController:ClearRebirthScreen()
	for _, value in requerimentsFrame:GetChildren() do
		if value.Name == "Item" then
			value:Destroy()
		end
	end

	for _, value in rewardsFrame:GetChildren() do
		if value.Name == "Item" then
			value:Destroy()
		end
	end
end
function RebirthController:BuildScreen()
	RebirthController:ClearRebirthScreen()
	local nextRebirthNumber = player:GetAttribute("CURRENT_REBIRTH") + 1
	local rebirthEnum = Rebirths[nextRebirthNumber]

	local function buildRequirements()
		local requeriments = rebirthEnum.Requirements

		for _, value in requeriments do
			if value.Type == "MONEY" then
				local newItem = requerimentsFrame.Money:Clone()
				newItem.Visible = true
				newItem.Name = "Item"
				newItem.TextLabel.Text = ClientUtil:FormatToUSD(value.Amount)
				newItem.Parent = requerimentsFrame
			end

			if value.Type == "BRAINROT" then
				local newItem = requerimentsFrame.Brainrot:Clone()
				newItem.Visible = true
				newItem.Name = "Item"
				newItem.Parent = requerimentsFrame
			end
		end
	end

	local function buildAwards()
		local awards = rebirthEnum.Awards

		for _, value in awards do
			if value.Type == "PLOT" then
				local newItem = rewardsFrame.Slot:Clone()
				newItem.Visible = true
				newItem.Name = "Item"
				newItem.Parent = rewardsFrame
			end

			if value.Type == "MONEY" then
				local newItem = rewardsFrame.Money:Clone()
				newItem.Visible = true
				newItem.Name = "Item"
				newItem.TextLabel.Text = "+" .. ClientUtil:FormatToUSD(value.Amount)
				newItem.Parent = rewardsFrame
			end

			if value.Type == "CASH_MULTIPLIER" then
				local newItem = rewardsFrame.CashMultiplier:Clone()
				newItem.Visible = true
				newItem.Name = "Item"
				newItem.TextLabel.Text = "+" .. value.Amount .. "x"
				newItem.Parent = rewardsFrame
			end
		end
	end

	if not rebirthEnum then
		screen.Main.Main.Visible = false
		screen.Main.NoRebirth.Visible = true
	end

	infoCurrentRebirth.Text = "Rebirth: " .. player:GetAttribute("CURRENT_REBIRTH")
	screen.Main.Main.Visible = true
	screen.Main.NoRebirth.Visible = false
	buildRequirements()
	buildAwards()
end

return RebirthController
