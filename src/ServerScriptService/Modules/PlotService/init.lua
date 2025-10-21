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
			value:Destroy()

			local base = BaseService:GetBase(player)
			local main = base:WaitForChild("Main")
			local slot = main.BrainrotPlots:FindFirstChild(plotNumber)
			slot:SetAttribute("BUSY", false)
			BrainrotService:RemoveBrainrotInMap(player, name, plotNumber)
			BrainrotService:SaveBrainrotInBackpack(player, name)
		end
	end
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
		if not value:GetAttribute("BUSY") then
			return value
		end
	end
end

function PlotService:Set(player: Player, brainrotType: string)
	local slot = PlotService:GetNextAvailablePlot(player)
	
	if slot then
		local slotNumber = tonumber(slot.Name)

		BrainrotService:SaveBrainrotInMap(player, brainrotType, slotNumber)
		PlotService:SetWithPlotNumber(player, slotNumber, brainrotType)
	else
		BrainrotService:SaveBrainrotInBackpack(player, brainrotType)
	end
end

function PlotService:SetWithPlotNumber(player: Player, slotNumber: number, brainrotType: string)
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
			local track = humanoid:LoadAnimation(animation)
			track:Play()
		end
	end

	local function createPlotMoneyInformation(slot)
		local touchPart = slot:WaitForChild("TouchPart")
		local billBoard = touchPart:WaitForChild("BillBoard")
		billBoard.Cash.Text = "$0"
		billBoard.Enabled = true
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

				createInformations(newBrainrot)

				createAnimation(newBrainrot)

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
