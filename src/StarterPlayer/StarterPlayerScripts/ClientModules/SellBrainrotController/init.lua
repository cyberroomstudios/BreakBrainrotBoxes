local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local Brainrots = require(ReplicatedStorage.Enums.Brainrots)
local UIStateManager = require(Players.LocalPlayer.PlayerScripts.ClientModules.UIStateManager)
local bridge = BridgeNet2.ReferenceBridge("SellService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local SellBrainrotController = {}

local screen
local sellAllButton

function SellBrainrotController:Init()
	SellBrainrotController:CreateReferences()
	SellBrainrotController:InitProximity()
	SellBrainrotController:InitButtonListerns()
end

function SellBrainrotController:CreateReferences()
	screen = UIReferences:GetReference("SELL_SCREEN")
	sellAllButton = UIReferences:GetReference("SELL_ALL_BUTTON")
end

function SellBrainrotController:InitButtonListerns()
	sellAllButton.MouseButton1Click:Connect(function()
		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "SellAll",
		})

		SellBrainrotController:ClearScreen()
	end)
end

function SellBrainrotController:InitProximity()
	local proximityPart = ClientUtil:WaitForDescendants(workspace, "Map", "Booths", "Sell", "ProximityPromptPart")

	local proximityPrompt = proximityPart.ProximityPrompt

	proximityPrompt.PromptShown:Connect(function()
		UIStateManager:Open("SELL")
	end)

	proximityPrompt.PromptHidden:Connect(function()
		UIStateManager:Close("SELL")
	end)
end

function SellBrainrotController:Open()
	screen.Visible = true

	local result = bridge:InvokeServerAsync({
		[actionIdentifier] = "Get",
	})

	SellBrainrotController:BuildScreen(result)
end

function SellBrainrotController:Close()
	screen.Visible = false
end

function SellBrainrotController:GetScreen()
	return screen
end

function SellBrainrotController:ClearScreen()
	local itemsScrollingFrame = screen.Main.Items:GetChildren()

	for _, value in itemsScrollingFrame do
		if value.Name == "UIListLayout" or value.Name == "UIPadding" or value.Name == "Item" then
			continue
		end

		value:Destroy()
	end
end

function SellBrainrotController:BuildScreen(items)
	SellBrainrotController:ClearScreen()

	for _, item in items do
		local newFrame = screen.Main.Items.Item:Clone()
		newFrame.Visible = true
		newFrame.Name = item.Name

		newFrame.Content.Frame.ItemName.Text = Brainrots[item.Name].GUI.Label
		newFrame.Content.Frame.ItemPrice.Text = ClientUtil:FormatToUSD(item.Price)
		newFrame.Content.Button.Button.MouseButton1Click:Connect(function()
			local result = bridge:InvokeServerAsync({
				[actionIdentifier] = "SellThis",
				Data = {
					Id = item.Id,
				},
			})

			if result then
				newFrame:Destroy()
			end
		end)

		newFrame.Parent = screen.Main.Items
	end
end

return SellBrainrotController
