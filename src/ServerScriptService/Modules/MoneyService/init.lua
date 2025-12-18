local MoneyService = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("MoneyService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local BaseService = require(ServerScriptService.Modules.BaseService)
local UtilService = require(ServerScriptService.Modules.UtilService)
local GameSoundService = require(ServerScriptService.Modules.GameSoundService)

local playerAutoCollect = {}

function MoneyService:Init()
	MoneyService:InitBridgeListener()
end

function MoneyService:InitBridgeListener()
	bridge.OnServerInvoke = function(player, data)
		if data[actionIdentifier] == "ToggleAutoCollect" then
			MoneyService:ToggleAutoCollect(player)
		end
	end
end

function MoneyService:GiveMoney(player: Player, amount: number, withSound: boolean)
	PlayerDataHandler:Update(player, "money", function(current)
		local newMoney = current + amount

		player:SetAttribute("MONEY", newMoney)

		if withSound then
			GameSoundService:Play(player, "MONEY_COMING_IN")
		end

		return newMoney
	end)
end

function MoneyService:ConsumeMoney(player: Player, amount: number)
	PlayerDataHandler:Update(player, "money", function(current)
		local newMoney = current - amount

		player:SetAttribute("MONEY", newMoney)
		GameSoundService:Play(player, "MONEY_COMING_OUT")

		return newMoney
	end)
end

function MoneyService:ConsumeAllMoney(player: Player)
	PlayerDataHandler:Set(player, "money", 0)
	player:SetAttribute("MONEY", 0)
end

function MoneyService:HasMoney(player: Player, amount: number)
	local currentMoney = PlayerDataHandler:Get(player, "money")

	return amount <= currentMoney
end

function MoneyService:GiveInitialMoney(player: Player)
	if PlayerDataHandler:Get(player, "totalPlaytime") == 0 then
		MoneyService:GiveMoney(player, 150, false)
	end
end

function MoneyService:GiveCashMultiplier(player: Player, incrementValue: number)
	PlayerDataHandler:Update(player, "cashMultiplier", function(current)
		return current + incrementValue
	end)

	local mult = PlayerDataHandler:Get(player, "cashMultiplier")
	local formatted = string.format("%.2f", mult)
	player:SetAttribute("CASH_MULTIPLIER", formatted)
end

function MoneyService:GiveBrainrotCashMultiplier(player: Player)
	PlayerDataHandler:Update(player, "hasBrainrotCashMultiplier", function(current)
		player:SetAttribute("HAS_BRAINROT_CASH_MULTIPLIER", true)
		return true
	end)
end

function MoneyService:GiveOpAutoCollect(player: Player)
	PlayerDataHandler:Set(player, "opAutoCollect", true)
	player:SetAttribute("HAS_OP_AUTO_COLLECT", true)
end

function MoneyService:CollectBrainrotMoney(player: Player, base)
	local main = base:WaitForChild("Main")
	local slots = main.BrainrotPlots:GetChildren()

	for _, slot in slots do
		local amountMoney = slot:GetAttribute("AMOUNT_MONEY") or 0

		if amountMoney > 0 then
			slot:SetAttribute("AMOUNT_MONEY", 0)
			local touchPart = slot:WaitForChild("TouchPart")
			local billBoard = touchPart:WaitForChild("BillBoard")
			billBoard.Cash.Text = UtilService:FormatToUSD(0)
			MoneyService:GiveMoney(player, amountMoney, false)
		end
	end
end

function MoneyService:ToggleAutoCollect(player)
	if not playerAutoCollect[player] then
		playerAutoCollect[player] = player
		task.spawn(function()
			local base = BaseService:GetBase(player)
			player:SetAttribute("TIME_TO_AUTO_COLLECT", player:GetAttribute("HAS_OP_AUTO_COLLECT") and 3 or 8)

			while playerAutoCollect[player] do
				local timeToAutoCollect = player:GetAttribute("TIME_TO_AUTO_COLLECT")
				timeToAutoCollect = timeToAutoCollect - 1

				player:SetAttribute("TIME_TO_AUTO_COLLECT", timeToAutoCollect)

				if timeToAutoCollect == 0 then
					MoneyService:CollectBrainrotMoney(player, base)

					player:SetAttribute("TIME_TO_AUTO_COLLECT", player:GetAttribute("HAS_OP_AUTO_COLLECT") and 3 or 8)
					continue
				end

				task.wait(1)
			end
		end)
		return
	end

	player:SetAttribute("TIME_TO_AUTO_COLLECT", player:GetAttribute("HAS_OP_AUTO_COLLECT") and 1 or 7)
	playerAutoCollect[player] = nil
end

return MoneyService
