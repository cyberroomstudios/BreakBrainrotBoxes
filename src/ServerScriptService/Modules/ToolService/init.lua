local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolService = {}

function ToolService:Init() end

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

	newToll.Name = brainrotName
	newToll.Parent = player.Backpack
end

return ToolService
