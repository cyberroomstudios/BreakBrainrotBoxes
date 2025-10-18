local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Brainrots = require(ReplicatedStorage.Enums.Brainrots)
local BaseService = require(ServerScriptService.Modules.BaseService)
local UtilService = require(ServerScriptService.Modules.UtilService)

local ThreadService = {}

function ThreadService:Init() end

function ThreadService:StartFromPlayer(player: Player)
	local function updatePlotMoney(plotNumber: number, moneyPerSecond: number)
		local base = BaseService:GetBase(player)
		local main = base:WaitForChild("Main")
		local slot = main.BrainrotPlots:FindFirstChild(plotNumber)

		local amountMoney = slot:GetAttribute("AMOUNT_MONEY") or 0
		amountMoney = amountMoney + moneyPerSecond

		slot:SetAttribute("AMOUNT_MONEY", amountMoney)

		local touchPart = slot:WaitForChild("TouchPart")
		local billBoard = touchPart:WaitForChild("BillBoard")
		billBoard.Cash.Text = UtilService:FormatToUSD(amountMoney)
		billBoard.Enabled = true
	end

	task.spawn(function()
		while player.Parent do
			-- Obtem todos os brainrots do jogador
			local brainrotsFolder = workspace.Runtime[player.UserId].Brainrots

			if brainrotsFolder then
				for _, value in brainrotsFolder:GetChildren() do
					local brainrotName = value.Name
					local brainrotEnum = Brainrots[brainrotName]

					if brainrotEnum then
						local slotNumber = value:GetAttribute("SLOT_NUMBER")
						updatePlotMoney(slotNumber, brainrotEnum.MoneyPerSecond)
					end
				end
			end
			task.wait(1)
		end
	end)
end

return ThreadService
