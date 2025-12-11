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

local mutationColors = {
	["GOLDEN"] = {
		[1] = Color3.fromRGB(237, 178, 0),
		[2] = Color3.fromRGB(237, 194, 86),
		[3] = Color3.fromRGB(215, 111, 1),
		[4] = Color3.fromRGB(139, 74, 0),
		[5] = Color3.fromRGB(237, 194, 86), -- Lucky Block wings
		[6] = Color3.fromRGB(255, 251, 131), -- Lucky Block question mark
		[7] = Color3.fromRGB(255, 178, 0), -- Lucky Block main color
		[8] = Color3.fromRGB(215, 111, 1), -- Brainrot God Lucky Block main color
	},

	["DIAMOND"] = {
		[1] = Color3.fromRGB(37, 196, 254),
		[2] = Color3.fromRGB(116, 212, 254),
		[3] = Color3.fromRGB(28, 137, 254),
		[4] = Color3.fromRGB(21, 64, 254),
		[5] = Color3.fromRGB(116, 212, 254), -- Lucky Block wings
		[6] = Color3.fromRGB(116, 212, 254), -- Lucky Block question mark
		[7] = Color3.fromRGB(37, 196, 254), -- Lucky Block main color
		[8] = Color3.fromRGB(28, 137, 254), -- Brainrot God Lucky Block main color	},
	},
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
		if value:GetAttribute("Color") and mutationColors[mutationType] then
			value.Color = mutationColors[mutationType][value:GetAttribute("Color")]
		end
	end

	-- Atualizando Nome das Tools
	pcall(function()
		local handler = newToll:WaitForChild("Handle")
		local attachment = handler:WaitForChild("Attachment")
		local billBoard = attachment:WaitForChild("NPCBillBoard")
		billBoard.CharName.Text = brainrotEnum.GUI.Label
		billBoard.Rarity.Text = brainrotEnum.Rarity
		billBoard.Rarity.TextColor3 = ReplicatedStorage.GUI.RarityColors:FindFirstChild(brainrotEnum.Rarity).Value

		local isGolden = billBoard:WaitForChild("IsGolden")
		local isDiamond = billBoard:WaitForChild("IsDiamond")

		if mutationType == "NORMAL" then
			isGolden.Visible = false
			isDiamond.Visible = false
		end

		if mutationType == "GOLDEN" then
			isGolden.Visible = true
			isDiamond.Visible = false

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
			isGolden.Visible = false
			isDiamond.Visible = true

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
