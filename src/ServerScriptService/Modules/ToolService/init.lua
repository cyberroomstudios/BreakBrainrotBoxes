local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolService = {}

function ToolService:Init() end

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
end

function ToolService:Consume(player: Player, toolType: string, toolName: string)
	if player.Backpack:FindFirstChild(toolName) then
		local item = player.Backpack:FindFirstChild(toolName)

		if item then
			local amount = item:GetAttribute("AMOUNT") or 0
			local newAmount = amount - 1

			if newAmount == 0 then
				item:Destroy()
			end

			item:SetAttribute("AMOUNT", newAmount)
			return
		end
	end

	local character = player.Character
	if character then
		local item = player.Character:FindFirstChild(toolName)

		if item then
			local amount = item:GetAttribute("AMOUNT") or 0
			local newAmount = amount - 1

			if newAmount == 0 then
				item:Destroy()
			end

			item:SetAttribute("AMOUNT", newAmount)
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

	if player.Backpack:FindFirstChild(toolName) then
		local item = player.Backpack:FindFirstChild(toolName)

		if item then
			local amount = item:GetAttribute("AMOUNT") or 0
			item:SetAttribute("AMOUNT", amount + 1)
			return
		end
		return
	end

	local character = player.Character
	if character then
		local item = player.Character:FindFirstChild(toolName)

		if item then
			local amount = item:GetAttribute("AMOUNT") or 0
			item:SetAttribute("AMOUNT", amount + 1)
			return
		end
	end

	local newToll = ReplicatedStorage.Tools.Crates:FindFirstChild(toolName):Clone()
	newToll:SetAttribute("ORIGINAL_NAME", toolName)
	newToll:SetAttribute("AMOUNT", amount)
	newToll:SetAttribute("TOOL_TYPE", toolType)

	newToll.Name = toolName
	newToll.Parent = player.Backpack
end

function ToolService:GiveBrainrotTool(player: Player, brainrotName: string)
	local newToll = ReplicatedStorage.Tools.Brainrots:FindFirstChild(brainrotName):Clone()
	newToll:SetAttribute("ORIGINAL_NAME", brainrotName)
	newToll:SetAttribute("TOOL_TYPE", "BRAINROT")
	newToll.Name = brainrotName
	newToll.Parent = player.Backpack
end

function ToolService:ConsumeBrainrotTool(player: Player, brainrotName: string)
	if player.Backpack:FindFirstChild(brainrotName) then
		local item = player.Backpack:FindFirstChild(brainrotName)

		if item then
			item:Destroy()
			return
		end
	end

	local character = player.Character
	if character then
		local item = player.Character:FindFirstChild(brainrotName)

		if item then
			item:Destroy()
			return
		end
	end
end

return ToolService
