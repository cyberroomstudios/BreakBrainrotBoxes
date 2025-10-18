local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BaseService = require(ServerScriptService.Modules.BaseService)
local Brainrots = require(ReplicatedStorage.Enums.Brainrots)

local PlotService = {}

function PlotService:Init() end

function PlotService:GetNextAvailablePlot(player: Player)
	local base = BaseService:GetBase(player)
	local main = base:WaitForChild("Main")
	local slots = main.BrainrotPlots:GetChildren()

	for _, value in slots do
		if not value:GetAttribute("BUSY") then
			return value
		end
	end
end

function PlotService:Set(player: Player, brainrotType: string)
	local slot = PlotService:GetNextAvailablePlot(player)

	if slot then
		local slotNumber = tonumber(slot.Name)
		slot:SetAttribute("BUSY", true)
		PlotService:SetWithPlotNumber(player, slotNumber, brainrotType)
	end
end

function PlotService:SetWithPlotNumber(player: Player, slotNumber: number, brainrotType: string)
	local brainrotModel = ReplicatedStorage.Brainrots:FindFirstChild(brainrotType)

	if brainrotModel then
		local base = BaseService:GetBase(player)
		local main = base:WaitForChild("Main")
		local slot = main.BrainrotPlots:FindFirstChild(slotNumber)

		if slot then
			local newBrainrot = brainrotModel:Clone()

			-- Cria o nome, preço e o tipo
			local hrp = newBrainrot:WaitForChild("HumanoidRootPart")

			if hrp then
				local brainrotEnum = Brainrots[brainrotType]
				local billboard = hrp:WaitForChild("NPCBillBoard")

				local cashPerSecond = billboard:WaitForChild("CashPerSecond")
				local charName = billboard:WaitForChild("CharName")
				local rarity = billboard:WaitForChild("Rarity")

				cashPerSecond.Text = "$" .. brainrotEnum.MoneyPerSecond .. "/s"
				charName.Text = brainrotEnum.GUI.Label
				rarity.Text = brainrotEnum.Rarity
				rarity.TextColor3 = ReplicatedStorage.GUI.RarityColors:FindFirstChild(brainrotEnum.Rarity).Value
			end

			newBrainrot.Parent = workspace.Runtime[player.UserId].Brainrots
			newBrainrot:SetPrimaryPartCFrame(slot.Attachment.WorldCFrame)
		end
	end
end

return PlotService
