local ToolService = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("BackpackService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

function ToolService:Init() end

function ToolService:UpdateBackpack(player: Player)
	bridge:Fire(player, {
		[actionIdentifier] = "UpdateBackpack",
	})
end

function ToolService:ConsumeAllCrates(player: Player, toolType)
	local items = player.Backpack:GetChildren()

	for _, valeu in items do
		if valeu:GetAttribute("TOOL_TYPE") == toolType then
			valeu:Destroy()
		end
	end

	local itemsFromCharecter = player.Character:GetChildren()

	for _, value in itemsFromCharecter do
		if value:GetAttribute("TOOL_TYPE") == toolType then
			value:Destroy()
		end
	end

	ToolService:UpdateBackpack(player)
end

function ToolService:Consume(player: Player, toolType: string, toolName: string)
	local character = player.Character
	if character then
		local item = player.Character:FindFirstChild(toolName)

		if item then
			item:Destroy()

			ToolService:UpdateBackpack(player)
			return
		end
	end

	if player.Backpack:FindFirstChild(toolName) then
		local item = player.Backpack:FindFirstChild(toolName)

		if item then
			item:Destroy()
			ToolService:UpdateBackpack(player)
			return
		end
	end
end

function ToolService:Give(player: Player, toolType: string, toolName: string, amount: number)
	if toolType == "CRATE" then
		if not ReplicatedStorage.Tools.Crates:FindFirstChild(toolName) then
			return
		end
	end

	player:SetAttribute("TOOL_ID", (player:GetAttribute("TOOL_ID") or 0) + 1)
	local newToll = ReplicatedStorage.Tools.Crates:FindFirstChild(toolName):Clone()
	newToll:SetAttribute("ORIGINAL_NAME", toolName)
	newToll:SetAttribute("AMOUNT", amount)
	newToll:SetAttribute("TOOL_TYPE", toolType)
	newToll:SetAttribute("ID", player:GetAttribute("TOOL_ID"))

	newToll.Name = toolName
	newToll.Parent = player.Backpack
	ToolService:UpdateBackpack(player)
end

function ToolService:GiveBrainrotTool(player: Player, brainrotName: string, mutationType: string)
	player:SetAttribute("TOOL_ID", (player:GetAttribute("TOOL_ID") or 0) + 1)
	local newToll = ReplicatedStorage.Tools.Brainrots:FindFirstChild(brainrotName):Clone()
	newToll:SetAttribute("ORIGINAL_NAME", brainrotName)
	newToll:SetAttribute("TOOL_TYPE", mutationType .. "_BRAINROT")
	newToll.Name = brainrotName
	newToll.Parent = player.Backpack
	newToll:SetAttribute("ID", player:GetAttribute("TOOL_ID"))
	ToolService:UpdateBackpack(player)
end

function ToolService:ConsumeBrainrotTool(player: Player, brainrotName: string)
	if player.Backpack:FindFirstChild(brainrotName) then
		local item = player.Backpack:FindFirstChild(brainrotName)

		if item then
			item:Destroy()
			ToolService:UpdateBackpack(player)
			return
		end
	end

	local character = player.Character
	if character then
		local item = player.Character:FindFirstChild(brainrotName)

		if item then
			item:Destroy()
			ToolService:UpdateBackpack(player)
			return
		end
	end
end

return ToolService
