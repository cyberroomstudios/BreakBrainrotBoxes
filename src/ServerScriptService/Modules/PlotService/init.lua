local PlotService = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("PlotService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local ServerScriptService = game:GetService("ServerScriptService")

local BaseService = require(ServerScriptService.Modules.BaseService)
local Brainrots = require(ReplicatedStorage.Enums.Brainrots)
local BrainrotService = require(ServerScriptService.Modules.BrainrotService)
local MoneyService = require(ServerScriptService.Modules.MoneyService)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)

function PlotService:Init()
	PlotService:InitBridgeListener()
end

function PlotService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "GetMoney" then
			local plotNumber = data.data.PlotNumber
			return PlotService:GetMoneyFromBrainrotPlot(player, plotNumber)
		end

		if data[actionIdentifier] == "RemoveBrainrot" then
			local name = data.data.Name
			local plotNumber = data.data.PlotNumber
			PlotService:RemoveBrainrot(player, name, plotNumber)
		end
	end
end

function PlotService:RemoveBrainrot(player: Player, name: string, plotNumber)
	local runtimeFolder = workspace.Runtime
	local playerFolder = runtimeFolder[player.UserId]
	local brainrotsFolder = playerFolder.Brainrots

	for _, value in brainrotsFolder:GetChildren() do
		if value.Name == name and value:GetAttribute("SLOT_NUMBER") == plotNumber then
			local mutationType = value:GetAttribute("MUTATION_TYPE")
			value:Destroy()

			local base = BaseService:GetBase(player)
			local main = base:WaitForChild("Main")
			local slot = main.BrainrotPlots:FindFirstChild(plotNumber)
			slot:SetAttribute("BUSY", false)
			BrainrotService:RemoveBrainrotInMap(player, name, plotNumber)
			BrainrotService:SaveBrainrotInBackpack(player, name, mutationType)
		end
	end
end

function PlotService:RelesePlot(player: Player, plotNumber: number)
	local base = BaseService:GetBase(player)
	local main = base:WaitForChild("Main")

	local slotBase = main.BrainrotPlots:FindFirstChild(1)
	local slot = main.BrainrotPlots:FindFirstChild(plotNumber)

	if slot then
		slot:SetAttribute("BUSY", false)
		slot:SetAttribute("UNLOCK", true)
		slot.TouchPart.Color = slotBase.TouchPart.Color
		slot.StandingPart.BillboardGui.Enabled = false
	end
end

function PlotService:InitRebirth(player: Player)
	local releaseSlotIndex = PlayerDataHandler:Get(player, "releaseSlotIndex")

	if releaseSlotIndex > 10 then
		for i = 11, releaseSlotIndex do
			PlotService:RelesePlot(player, i)
		end
	end
end

function PlotService:RemoveAll(player: Player)
	local runtimeFolder = workspace.Runtime
	local playerFolder = runtimeFolder[player.UserId]
	local brainrotsFolder = playerFolder.Brainrots
	local base = BaseService:GetBase(player)
	local main = base:WaitForChild("Main")

	for plotNumber = 1, 20 do
		for _, value in brainrotsFolder:GetChildren() do
			if value:GetAttribute("SLOT_NUMBER") == plotNumber then
				value:Destroy()

				local slot = main.BrainrotPlots:FindFirstChild(plotNumber)
				slot:SetAttribute("BUSY", false)
			end
		end
	end
	BrainrotService:RemoveAll(player)
end

function PlotService:GetMoneyFromBrainrotPlot(player: Player, plotNumber: number)
	local base = BaseService:GetBase(player)
	local main = base:WaitForChild("Main")
	local slot = main.BrainrotPlots:FindFirstChild(plotNumber)

	local touchPart = slot:WaitForChild("TouchPart")
	local billBoard = touchPart:WaitForChild("BillBoard")
	billBoard.Cash.Text = "$0"

	local value = slot:GetAttribute("AMOUNT_MONEY") or 0
	slot:SetAttribute("AMOUNT_MONEY", 0)

	MoneyService:GiveMoney(player, value)

	return value
end

function PlotService:GetNextAvailablePlot(player: Player)
	local base = BaseService:GetBase(player)
	local main = base:WaitForChild("Main")
	local slots = main.BrainrotPlots:GetChildren()

	-- Ordena os slots pelo nome numérico
	table.sort(slots, function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)

	for _, value in slots do
		if value:GetAttribute("UNLOCK") and not value:GetAttribute("BUSY") then
			return value
		end
	end
end

function PlotService:Set(player: Player, brainrotType: string, mutationType: string)
	local slot = PlotService:GetNextAvailablePlot(player)

	if slot then
		local slotNumber = tonumber(slot.Name)

		BrainrotService:SaveBrainrotInMap(player, brainrotType, mutationType, slotNumber)
		PlotService:SetWithPlotNumber(player, slotNumber, brainrotType, mutationType)
	else
		BrainrotService:SaveBrainrotInBackpack(player, brainrotType, mutationType)
	end
end

function PlotService:SetWithPlotNumber(player: Player, slotNumber: number, brainrotType: string, mutationType: string)
	local mutationColors = {
		["GOLDEN"] = {
			[1] = Color3.fromRGB(237, 178, 0),
			[2] = Color3.fromRGB(237, 194, 86),
			[3] = Color3.fromRGB(215, 111, 1),
			[4] = Color3.fromRGB(139, 74, 0),
			[5] = Color3.fromRGB(255, 164, 164),
			[6] = Color3.fromRGB(255, 244, 190),
		},

		["DIAMOND"] = {
			[1] = Color3.fromRGB(37, 196, 254),
			[2] = Color3.fromRGB(116, 212, 254),
			[3] = Color3.fromRGB(28, 137, 254),
			[4] = Color3.fromRGB(21, 64, 254),
			[5] = Color3.fromRGB(160, 162, 254),
			[6] = Color3.fromRGB(176, 255, 252),
		},
	}

	local brainrotModel = ReplicatedStorage.Brainrots:FindFirstChild(brainrotType)

	local function createInformations(newBrainrot: Model)
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
	end

	local function createAnimation(newBrainrot: Model)
		local humanoid = newBrainrot:WaitForChild("Humanoid")
		local animation = ReplicatedStorage.Animations.Brainrots:FindFirstChild(newBrainrot.Name)
		if animation then
			--		local track = humanoid:LoadAnimation(animation)
			--		track:Play()
		end
	end

	local function createPlotMoneyInformation(slot)
		local touchPart = slot:WaitForChild("TouchPart")
		local billBoard = touchPart:WaitForChild("BillBoard")
		billBoard.Cash.Text = "$0"
		billBoard.Enabled = true
	end

	local function applyMutation(brainrot: Model)
		if mutationType == "GOLDEN" or mutationType == "DIAMOND" then
			for _, value in brainrot:GetDescendants() do
				if value:GetAttribute("Color") then
					value.Color = mutationColors[mutationType][value:GetAttribute("Color")]
				end
			end
		end
	end

	if brainrotModel then
		local base = BaseService:GetBase(player)
		local main = base:WaitForChild("Main")
		local slot = main.BrainrotPlots:FindFirstChild(slotNumber)

		if slot then
			pcall(function()
				slot:SetAttribute("BUSY", true)
				local newBrainrot = brainrotModel:Clone()
				newBrainrot:SetAttribute("AMOUNT_MONEY", 0)
				newBrainrot:SetAttribute("SLOT_NUMBER", slotNumber)
				newBrainrot:SetAttribute("MUTATION_TYPE", mutationType)

				createInformations(newBrainrot)

				createAnimation(newBrainrot)

				applyMutation(newBrainrot)

				newBrainrot.Parent = workspace.Runtime[player.UserId].Brainrots
				newBrainrot:SetPrimaryPartCFrame(slot.Attachment.WorldCFrame)

				createPlotMoneyInformation(slot)
			end)
		end

		bridge:Fire(player, {
			[actionIdentifier] = "CreateProximityPrompt",
			data = {
				Name = brainrotModel.Name,
				Plot = slotNumber,
			},
		})
	end
end

return PlotService
