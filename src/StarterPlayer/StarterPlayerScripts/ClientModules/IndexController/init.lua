local IndexController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("IndexService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local Brainrots = require(ReplicatedStorage.Enums.Brainrots)

local screen
local normalIndexScrolling
local goldenIndexScrolling
local diamondIndexScrolling

local normalButton
local goldenButton
local diamondButton

function IndexController:Init()
	IndexController:CreateReferences()
	IndexController:InitButtonListerns()
end

function IndexController:CreateReferences()
	screen = UIReferences:GetReference("INDEX")

	normalButton = UIReferences:GetReference("INDEX_NORMAL_BUTTON")
	goldenButton = UIReferences:GetReference("INDEX_GOLDEN_BUTTON")
	diamondButton = UIReferences:GetReference("INDEX_DIAMOND_BUTTON")

	normalIndexScrolling = UIReferences:GetReference("NORMAL_INDEX")
	goldenIndexScrolling = UIReferences:GetReference("GOLDEN_INDEX")
	diamondIndexScrolling = UIReferences:GetReference("DIAMOND_INDEX")
end

function IndexController:Open()
	screen.Visible = true
	normalIndexScrolling.Visible = true
	goldenIndexScrolling.Visible = false
	diamondIndexScrolling.Visible = false

	local result = bridge:InvokeServerAsync({
		[actionIdentifier] = "GetNormalIndex",
	})

	IndexController:BuildScreen(result, "NORMAL")
end

function IndexController:InitButtonListerns()
	local viewStates = {
		["NORMAL"] = normalIndexScrolling,
		["GOLDEN"] = goldenIndexScrolling,
		["DIAMOND"] = diamondIndexScrolling,
	}

	normalButton.MouseButton1Click:Connect(function()
		for viewName, view in viewStates do
			view.Visible = viewName == "NORMAL"
		end

		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "GetNormalIndex",
		})

		IndexController:BuildScreen(result, "NORMAL")
	end)

	goldenButton.MouseButton1Click:Connect(function()
		for viewName, view in viewStates do
			view.Visible = viewName == "GOLDEN"
		end

		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "GetGoldenIndex",
		})

		IndexController:BuildScreen(result, "GOLDEN")
	end)

	diamondButton.MouseButton1Click:Connect(function()
		for viewName, view in viewStates do
			view.Visible = viewName == "DIAMOND"
		end

		local result = bridge:InvokeServerAsync({
			[actionIdentifier] = "GetDiamondIndex",
		})

		IndexController:BuildScreen(result, "DIAMOND")
	end)
end

function IndexController:Close()
	screen.Visible = false
end

function IndexController:GetScreen()
	return screen
end

function IndexController:BuildScreen(items, viewType)
	local viewStates = {
		["NORMAL"] = normalIndexScrolling,
		["GOLDEN"] = goldenIndexScrolling,
		["DIAMOND"] = diamondIndexScrolling,
	}

	for _, value in viewStates[viewType]:GetChildren() do
		if value:IsA("Frame") and value.Name ~= "Item" then
			value:Destroy()
		end
	end

	for name, value in Brainrots do
		local newItem = viewStates[viewType].Item:Clone()
		newItem.Visible = true
		newItem.Name = name
		newItem.Parent = viewStates[viewType]

		if items[name] then
			newItem.Content.Visible = true
		else
			newItem.Content.Visible = false
		end
	end
end

return IndexController
