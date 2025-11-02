local BackpackController = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("BackpackService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local UIReferences = require(Players.LocalPlayer.PlayerScripts.Util.UIReferences)
local ClientUtil = require(Players.LocalPlayer.PlayerScripts.ClientModules.ClientUtil)

local player = Players.LocalPlayer

local MAX_SLOTS = 7

local backpackButtons
local backpackExpanded
local expandedScrollingFrame

local updating = false
local backpack

function BackpackController:Init()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	BackpackController:CreateReferences()
	BackpackController:InitButtonListerns()
	BackpackController:InitBridgeListener()
	backpack = player:WaitForChild("Backpack")
end

function BackpackController:CreateReferences()
	backpackButtons = UIReferences:GetReference("BACKPACK_BUTTONS")
	backpackExpanded = UIReferences:GetReference("BACKPACK_EXPANDED")
	expandedScrollingFrame = UIReferences:GetReference("EXPANDED_SCROLLING_FRAME")
end

function BackpackController:InitBridgeListener()
	bridge:Connect(function(response)
		if response[actionIdentifier] == "UpdateBackpack" then
			BackpackController:UpdateBackpack()
		end
	end)
end

function BackpackController:EquipOrUniquipTool(toolId: number)
	local tool = nil

	for _, value in backpack:GetChildren() do
		if value:GetAttribute("ID") == toolId then
			tool = value
		end
	end

	if tool then
		player.Character.Humanoid:EquipTool(tool)
		return true
	end

	player.Character.Humanoid:UnequipTools()

	return false
end

function BackpackController:InitButtonListerns()
	local buttons = backpackButtons:GetChildren()

	for _, value in buttons do
		if value:IsA("Frame") then
			local button = value.Button
			button.MouseButton1Click:Connect(function()
				-- Botão de Expandir o Backpack
				if tostring(value.Name) == "6" then
					backpackExpanded.Visible = not backpackExpanded.Visible
					return
				end

				if value:GetAttribute("TOOL_ID") then
					local isEquip = BackpackController:EquipOrUniquipTool(value:GetAttribute("TOOL_ID"))

					if isEquip then
						BackpackController:DisableAllItems()
						value.BackgroundColor3 = ClientUtil:Color3(0, 170, 0)
					else
						BackpackController:DisableAllItems()
					end
				end
			end)
		end
	end
end

-- Pega o item que ta na mão do jogador
function BackpackController:GetItemFromCharacter(allItems)
	local character = player.Character
	if character then
		for _, item in ipairs(character:GetChildren()) do
			if item:IsA("Tool") then
				table.insert(allItems, item)
			end
		end
	end
end

function BackpackController:GetItemFromBackpack(allItems)
	for index, tool in backpack:GetChildren() do
		table.insert(allItems, tool)
	end
end

function BackpackController:DisableAllItems()
	local buttons = backpackButtons:GetChildren()
	for _, value in buttons do
		if value:IsA("Frame") then
			value.BackgroundColor3 = ClientUtil:Color3(112, 112, 112)
		end
	end

	for _, value in expandedScrollingFrame:GetChildren() do
		if value:IsA("Frame") then
			value.BackgroundColor3 = ClientUtil:Color3(112, 112, 112)
		end
	end
end

function BackpackController:UpdateBackpack()
	while updating do
		task.wait()
	end
	updating = true

	local buttons = backpackButtons:GetChildren()

	player.Character.Humanoid:UnequipTools()

	BackpackController:DisableAllItems()
	local allItems = {}

	-- Pega o item que ta na mão do jogador
	BackpackController:GetItemFromCharacter(allItems)

	-- Pega todos os itens do backpack
	BackpackController:GetItemFromBackpack(allItems)

	-- Limpa todos os itens do backpack
	BackpackController:CleanBackpack()

	for index, tool in allItems do
		local itemId = tool:GetAttribute("ID")
		local itemName = tool:GetAttribute("ORIGINAL_NAME")
		local itemType = tool:GetAttribute("TOOL_TYPE")

		local insertedIntoButtons = BackpackController:InsertIntoUI(itemId, itemType, itemName)

		if not insertedIntoButtons then
			BackpackController:InsertIntoExpanded(itemId, itemType, itemName)
		end
	end

	updating = false
end

function BackpackController:CleanBackpack()
	local buttons = backpackButtons:GetChildren()

	for _, value in buttons do
		if value:IsA("Frame") then
			value:SetAttribute("BUSY", false)
			value:SetAttribute("TOOL_ID", nil)
			local viewPort = value:FindFirstChild("viewPort")

			if viewPort then
				viewPort:Destroy()
			end
		end
	end

	for _, value in expandedScrollingFrame:GetChildren() do
		if value:IsA("Frame") then
			value:Destroy()
		end
	end
end

function BackpackController:InsertIntoExpanded(itemId: number, itemType: string, itemName: string)
	local validTypes = {
		NORMAL_BRAINROT = "NORMAL",
		DIAMOND_BRAINROT = "DIAMOND",
		GOLDEN_BRAINROT = "GOLDEN",
	}

	local item = ReplicatedStorage.GUI.Backpack.Template:Clone()
	item.Parent = expandedScrollingFrame
	item.Button.MouseButton1Click:Connect(function()
		if item:GetAttribute("TOOL_ID") then
			local isEquip = BackpackController:EquipOrUniquipTool(item:GetAttribute("TOOL_ID"))

			if isEquip then
				BackpackController:DisableAllItems()
				item.BackgroundColor3 = ClientUtil:Color3(0, 170, 0)
			else
				BackpackController:DisableAllItems()
			end
		end
	end)

	if itemType == "CRATE" then
		local viewPortFolder = ReplicatedStorage.GUI.ViewPortFrames.CRATES
		if viewPortFolder then
			local viewPortTemplate = viewPortFolder:FindFirstChild(itemName)

			local viewPort = viewPortTemplate:Clone()
			viewPort.Name = "viewPort"
			viewPort.Parent = item
			item:SetAttribute("TOOL_ID", itemId)
			item:SetAttribute("BUSY", true)
			return true
		end
	end

	local folderName = validTypes[itemType]
	if folderName then
		local viewPortFolder = ReplicatedStorage.GUI.ViewPortFrames:FindFirstChild(folderName)
		if viewPortFolder then
			local viewPortTemplate = viewPortFolder:FindFirstChild(itemName)
			if viewPortTemplate then
				local viewPort = viewPortTemplate:Clone()
				viewPort.Name = "viewPort"
				viewPort.Parent = item
				item:SetAttribute("TOOL_ID", itemId)
				item:SetAttribute("BUSY", true)
				return true
			end
		end
	end
end

function BackpackController:InsertIntoUI(itemId: number, itemType: string, itemName: string)
	local buttons = backpackButtons:GetChildren()
	local validTypes = {
		NORMAL_BRAINROT = "NORMAL",
		DIAMOND_BRAINROT = "DIAMOND",
		GOLDEN_BRAINROT = "GOLDEN",
	}

	table.sort(buttons, function(a, b)
		return a.Name < b.Name
	end)

	for _, value in buttons do
		if value:IsA("Frame") then
			if value:GetAttribute("BUSY") then
				continue
			end

			if tostring(value.Name) == "6" then
				continue
			end

			if itemType == "CRATE" then
				local viewPortFolder = ReplicatedStorage.GUI.ViewPortFrames.CRATES
				if viewPortFolder then
					local viewPortTemplate = viewPortFolder:FindFirstChild(itemName)

					local viewPort = viewPortTemplate:Clone()
					viewPort.Name = "viewPort"
					viewPort.Parent = value
					value:SetAttribute("TOOL_ID", itemId)
					value:SetAttribute("BUSY", true)
					return true
				end
			end

			local folderName = validTypes[itemType]
			if folderName then
				local viewPortFolder = ReplicatedStorage.GUI.ViewPortFrames:FindFirstChild(folderName)
				if viewPortFolder then
					local viewPortTemplate = viewPortFolder:FindFirstChild(itemName)
					if viewPortTemplate then
						local viewPort = viewPortTemplate:Clone()
						viewPort.Name = "viewPort"
						viewPort.Parent = value
						value:SetAttribute("TOOL_ID", itemId)
						value:SetAttribute("BUSY", true)
						return true
					end
				end
			end
		end
	end

	return false
end

return BackpackController
