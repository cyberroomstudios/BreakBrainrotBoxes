local ToolService = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Init Bridg Net
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local Brainrots = require(ReplicatedStorage.Enums.Brainrots)
local UtilService = require(ServerScriptService.Modules.UtilService)
local Mutations = require(ReplicatedStorage.Enums.Mutations)
local bridge = BridgeNet2.ReferenceBridge("BackpackService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local mutationMultipliers = {
	["NORMAL"] = 1,
	["GOLDEN"] = 1.25,
	["DIAMOND"] = 1.5,
}

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
		if not ReplicatedStorage.CratesTools:FindFirstChild(toolName) then
			return
		end
	end

	player:SetAttribute("TOOL_ID", (player:GetAttribute("TOOL_ID") or 0) + 1)
	local newToll = ReplicatedStorage.CratesTools:FindFirstChild(toolName):Clone()
	newToll:SetAttribute("ORIGINAL_NAME", toolName)
	newToll:SetAttribute("AMOUNT", amount)
	newToll:SetAttribute("TOOL_TYPE", toolType)
	newToll:SetAttribute("ID", player:GetAttribute("TOOL_ID"))

	newToll.Name = toolName
	newToll.Parent = player.Backpack
	ToolService:UpdateBackpack(player)
end

function ToolService:GiveBrainrotTool(player: Player, brainrotId: number, brainrotName: string, mutationType: string)
	player:SetAttribute("TOOL_ID", (player:GetAttribute("TOOL_ID") or 0) + 1)
	local newToll = ReplicatedStorage.Tools.Brainrots:FindFirstChild(brainrotName):Clone()
	local brainrotEnum = Brainrots[brainrotName]

	for _, value in newToll:GetDescendants() do
		if value:GetAttribute("Color") and Mutations.Colors[mutationType] then
			value.Color = Mutations.Colors[mutationType][value:GetAttribute("Color")]
		end
	end

	-- Atualizando Nome das Tools
	pcall(function()
		local handler = newToll:WaitForChild("Handle")
		local attachment = handler:WaitForChild("Attachment")
		local billBoard = attachment:WaitForChild("NPCBillBoard")
		billBoard.CharName.Text = brainrotEnum.GUI.Label

		local rarityType = billBoard:WaitForChild("RarityType")

		if mutationType == "NORMAL" then
			rarityType.Visible = false
			billBoard.Rarity.Text = brainrotEnum.Rarity
			billBoard.Rarity.TextColor3 = ReplicatedStorage.GUI.RarityColors:FindFirstChild(brainrotEnum.Rarity).Value
		end

		if mutationType == "CANDY_CANE" then
			rarityType.TextColor3 = ReplicatedStorage.GUI.MutationsColors["CANDY_CANE"].Value
			rarityType.Visible = true
			rarityType.Text = "[CANDY CANE]"

			billBoard.Rarity.Text = "Exclusive"
			billBoard.Rarity.TextColor3 = ReplicatedStorage.GUI.RarityColors:FindFirstChild("EXCLUSIVE").Value
		end

		if mutationType == "GOLDEN" then
			rarityType.TextColor3 = ReplicatedStorage.GUI.MutationsColors["GOLDEN"].Value

			rarityType.Visible = true
			rarityType.Text = "[GOLDEN]"

			billBoard.Rarity.Text = brainrotEnum.Rarity
			billBoard.Rarity.TextColor3 = ReplicatedStorage.GUI.RarityColors:FindFirstChild(brainrotEnum.Rarity).Value

			if newToll:FindFirstChild("ParticleHolder") then
				local particleHolder = newToll:FindFirstChild("ParticleHolder")

				if particleHolder:FindFirstChild("GOLD_ATT") then
					local goldAtt = particleHolder:FindFirstChild("GOLD_ATT")

					if goldAtt:FindFirstChild("GOLD_SHINE") then
						local goldShine = goldAtt:FindFirstChild("GOLD_SHINE")
						goldShine.Enabled = true
					end
				end

				if particleHolder:FindFirstChild("GOLD_SPARKS") then
					local goldSparks = particleHolder:FindFirstChild("GOLD_SPARKS")
					goldSparks.Enabled = true
				end
			end
		end

		if mutationType == "DIAMOND" then
			rarityType.TextColor3 = ReplicatedStorage.GUI.MutationsColors["DIAMOND"].Value
			rarityType.Visible = true
			rarityType.Text = "[DIAMOND]"

			billBoard.Rarity.Text = brainrotEnum.Rarity
			billBoard.Rarity.TextColor3 = ReplicatedStorage.GUI.RarityColors:FindFirstChild(brainrotEnum.Rarity).Value

			if newToll:FindFirstChild("ParticleHolder") then
				local particleHolder = newToll:FindFirstChild("ParticleHolder")

				if particleHolder:FindFirstChild("DIAMOND_ATT") then
					local diamondAtt = particleHolder:FindFirstChild("DIAMOND_ATT")

					if diamondAtt:FindFirstChild("DIAMOND_SHINE") then
						local diamondShine = diamondAtt:FindFirstChild("DIAMOND_SHINE")
						diamondShine.Enabled = true
					end
				end

				if particleHolder:FindFirstChild("DIAMOND_SPARKS") then
					local diamondSparks = particleHolder:FindFirstChild("DIAMOND_SPARKS")
					diamondSparks.Enabled = true
				end
			end
		end
		billBoard.CashPerSecond.Text = UtilService:FormatToUSD(
			brainrotEnum.MoneyPerSecond * mutationMultipliers[mutationType]
		) .. "/s"
	end)

	newToll:SetAttribute("ORIGINAL_NAME", brainrotName)
	newToll:SetAttribute("TOOL_TYPE", mutationType .. "_BRAINROT")
	newToll:SetAttribute("MUTATION_TYPE", mutationType)
	newToll:SetAttribute("BRAINROT_ID", brainrotId)
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

function ToolService:ConsumeThisTool(player: Player, tool: Tool)
	tool:Destroy()
	ToolService:UpdateBackpack(player)
end

return ToolService
